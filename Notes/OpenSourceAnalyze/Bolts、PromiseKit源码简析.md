# Bolts、PromiseKit、Promises 源码简析
![哈咪.gif](https://ooo.0o0.ooo/2017/01/12/5876ed68b3b77.gif)

> `Promise`思想的开源库其实有很多，这里仅简单分析下[Bolts](https://github.com/BoltsFramework/Bolts-ObjC)、[PromiseKit](https://github.com/mxcl/PromiseKit)、[promises](https://github.com/google/promises)

### 一、 [Bolts](https://github.com/BoltsFramework/Bolts-ObjC):
> `Facebook`出品

`BFTask`原理：
每个`BFTask`自己都维护着一个任务数组，当task执行`continueWithBlock:`后（会生成一个新的`BFTask`），`continueWithBlock:`带的那个`block`会被加入到任务数组中，每当有结果返回时，会执行`trySetResult:`方法，这个方法中会拿到`task`它自己维护的那个任务数组，然后取出其中的所有任务`block`，然后遍历执行。

```objc
/// 内部维护的任务数组
@property (nonatomic, strong) NSMutableArray *callbacks;


/// `continueWithBlock:`方法
- (BFTask *)continueWithExecutor:(BFExecutor *)executor
                           block:(BFContinuationBlock)block
               cancellationToken:(nullable BFCancellationToken *)cancellationToken {
	 // 创建一个新的`BFTaskCompletionSource`，创建它时，它里面会`new`一个`task`对象，最后`return`的也是这个`task`
	 // 这个不是单例方法，所以此处创建的`task`是一个新对象
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource]; // (1)

    // 创建一个任务`block`，后面会把执行这个`block`的操作加入到数组中，当回调时会执行这个`block`里面的操作
    // P.S. 下面附一张把这个block折叠后的图片
    dispatch_block_t executionBlock = ^{                    //(N.0)
        if (cancellationToken.cancellationRequested) {
            [tcs cancel];
            return;
        }
		  
		   // 把当前类（`task`对象）作为参数进行回调               //(N.1)
        id result = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (BFTaskCatchesExceptions()) {
            @try {
                result = block(self);
            } @catch (NSException *exception) {
                NSLog(@"[Bolts] Warning: `BFTask` caught an exception in the continuation block."
                      @" This behavior is discouraged and will be removed in a future release."
                      @" Caught Exception: %@", exception);
                tcs.exception = exception;
                return;
            }
        } else {
            result = block(self);                          
        }
#pragma clang diagnostic pop
			// 如果回调结果返回的是`BFTask`类型
        if ([result isKindOfClass:[BFTask class]]) {
				 // 下面`block`中的`task`就是上面的`result`
            id (^setupWithTask) (BFTask *) = ^id(BFTask *task) {     //(N.3)
                if (cancellationToken.cancellationRequested || task.cancelled) {
                    [tcs cancel];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                } else if (task.exception) {
                    tcs.exception = task.exception;
#pragma clang diagnostic pop
                } else if (task.error) {
                    tcs.error = task.error;
                } else {
                    tcs.result = task.result;
                }
                return nil;
            };

            BFTask *resultTask = (BFTask *)result;
				 /// 如果`continueWithBlock:`中的`block`回调返回的`task`是`complete`状态，则直接到 (N.3)，把任务的结果传递到上面新创建的那个`BFTask`对象的`result`属性中,否则就继续执行`continueWithBlock:`来监测任务状态
            if (resultTask.completed) {
                setupWithTask(resultTask);                      //(N.2)
            } else {
                [resultTask continueWithBlock:setupWithTask];   //(N.4)
            }
        } else {
            tcs.result = result;
        }
    };
	
	  // 如果是未完成状态，则把操作加入到数组中，延后执行；否则就立即执行
    BOOL completed;
    @synchronized(self.lock) {	                        //(2.0)
        completed = self.completed;
        if (!completed) {
        		// 把任务添加到数组中
            [self.callbacks addObject:[^{
                [executor execute:executionBlock];
            } copy]];
        }
    }
    if (completed) {                                   //(2.1) 
        [executor execute:executionBlock];
    }

    return tcs.task;
}
```

![](http://olmn3rwny.bkt.clouddn.com/20180830114906_3C04kM_continueWithBlock.jpeg)


### 二、 [PromiseKit](https://github.com/mxcl/PromiseKit):
1. 首先，让我们看看创建`Promise`的源码

```objc
+ (instancetype)promiseWithResolver:(void (^)(PMKResolver))block {    // (2)
    PMKPromise *this = [self alloc];              // (3)  初始化promise
    this->_promiseQueue = PMKCreatePromiseQueue();
    this->_handlers = [NSMutableArray new];

    @try {
        block(^(id result){           // (4)  立即开始原始任务（它传过去的参数还是一个`PMKResolver`类型的block，这个block会在PMKRejecter或者PMKFulfiller类型的block执行回调时执行） "void (^PMKResolver)(id)"
            if (PMKGetResult(this))
                return PMKLog(@"PromiseKit: Warning: Promise already resolved");

            PMKResolve(this, result); // (7) result为用户在`new:`方法中返回的数据结果,而this则是上面一开始时初始化的那个promise. 执行到这里后接下来会到(8),回调到(9)那个block,这个block中会遍历`handlers`数组中的`handler()` block, 
        });
    } @catch (id e) {
        // at this point, no pointer to the Promise has been provided
        // to the user, so we can’t have any handlers, so all we need
        // to do is set _result. Technically using PMKSetResult is
        // not needed either, but this seems better safe than sorry.
        PMKSetResult(this, NSErrorFromException(e));
    }

    return this;
}

+ (instancetype)new:(void(^)(PMKFulfiller, PMKRejecter))block {   // (1)
    return [self promiseWithResolver:^(PMKResolver resolve) {
        id rejecter = ^(id error){                    // (5-1) 失败的block
            if (error == nil) {
                error = NSErrorFromNil();
            } else if (IsPromise(error) && [error rejected]) {
                // this is safe, acceptable and (basically) valid
            } else if (!IsError(error)) {
                id userInfo = @{NSLocalizedDescriptionKey: [error description], PMKUnderlyingExceptionKey: error};
                error = [NSError errorWithDomain:PMKErrorDomain code:PMKInvalidUsageError userInfo:userInfo];
            }
            resolve(error);
        };

        id fulfiller = ^(id result){                  // (5-2) 成功的block
            if (IsError(result))
                PMKLog(@"PromiseKit: Warning: PMKFulfiller called with NSError.");
            resolve(result);       // (6) 当用户执行`PMKFulfiller`类型的block时,会回调到这里,此方法执行(4)中的那个参数block,即执行(7)
        };

        block(fulfiller, rejecter);                   // (5-3) 把成功和失败的block作为参数，执行回调原任务（e.g demo中的网络请求任务）
    }];
}

static void PMKResolve(PMKPromise *this, id result) {
    void (^set)(id) = ^(id r){ // (9) handle回调执行(10)
        NSArray *handlers = PMKSetResult(this, r);
        for (void (^handler)(id) in handlers)
            handler(r);
    };

    if (IsPromise(result)) {
        PMKPromise *next = result;
        dispatch_barrier_sync(next->_promiseQueue, ^{
            id nextResult = next->_result;
            
            if (nextResult == nil) {  // ie. pending
                [next->_handlers addObject:^(id o){
                    PMKResolve(this, o);
                }];
            } else
                set(nextResult);
        });
    } else
        set(result); // (8) 
}
```
调用`new:`方法时会调用`promiseWithResolver:`方法，在里面进行一些初始化`promise`的工作：创建了一个`GCD`并发队列和一个数组，并立即回调`new:`后面的那个参数`block`，即：立即执行，生成一个成功`fulfiller`和失败`rejecter`的`block`，这个`block`将由用户控制回调操作的时机。

----
2. 下面看一下`then`的实现：

```objc
- (PMKPromise *(^)(id))then {      // 1
    // 此处`then`本身就是一个block：（PMKPromise *(^then)(id param)），此方法类似于getter方法
    // 返回一个`(PMKPromise *(^)(id))`类型的block，这个block执行后，返回一个PMKPromise
    // 下面整个都是一个then `block`，当执行then的时候会调用 `self.thenOn(dispatch_get_main_queue(), block)`，返回一个Promise类型的结果
    return ^(id block){
        return self.thenOn(dispatch_get_main_queue(), block);
    };
}

- (PMKResolveOnQueueBlock)thenOn {
    return [self resolved:^(id result) {
        if (IsPromise(result))
            return ((PMKPromise *)result).thenOn;

        if (IsError(result)) return ^(dispatch_queue_t q, id block) {
            return [PMKPromise promiseWithValue:result];
        };

        return ^(dispatch_queue_t q, id block) {

            // HACK we seem to expose some bug in ARC where this block can
            // be an NSStackBlock which then gets deallocated by the time
            // we get around to using it. So we force it to be malloc'd.
            block = [block copy];

            return dispatch_promise_on(q, ^{
                return pmk_safely_call_block(block, result);
            });
        };
    }
    pending:^(id result, PMKPromise *next, dispatch_queue_t q, id block, void (^resolve)(id)) {  
        if (IsError(result))
            PMKResolve(next, result);
        else dispatch_async(q, ^{
            resolve(pmk_safely_call_block(block, result));  // (11)
        });
    }];
}

- (id)resolved:(PMKResolveOnQueueBlock(^)(id result))mkresolvedCallback
       pending:(void(^)(id result, PMKPromise *next, dispatch_queue_t q, id block, void (^resolver)(id)))mkpendingCallback
{
    __block PMKResolveOnQueueBlock callBlock;
    __block id result;
    
    dispatch_sync(_promiseQueue, ^{
        if ((result = _result)) // 有结果的情况下直接返回
            return;

        callBlock = ^(dispatch_queue_t q, id block) { // 此block在`thenOn:`方法赋值时进行回调

            block = [block copy];

            __block PMKPromise *next = nil;

            dispatch_barrier_sync(_promiseQueue, ^{
                if ((result = _result))
                    return;

                __block PMKPromiseFulfiller resolver;
                next = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
                    resolver = ^(id o){
                        if (IsError(o)) reject(o); else fulfill(o); // (12)
                    };
                }];
                [_handlers addObject:^(id value){
                    mkpendingCallback(value, next, q, block, resolver); // (10)
                }];
            });
            
            // next can still be `nil` if the promise was resolved after
            // 1) `-thenOn` read it and decided which block to return; and
            // 2) the call to the block.

            return next ?: mkresolvedCallback(result)(q, block);  // (2) 如果`next` promise没有生成,则用以前的参数再执行一次. `mkresolvedCallback(result)`返回一个`PMKResolveOnQueueBlock`类型的block`(在这里就相当于生成了一个callBlock),然后立即调用,生成`PMKPromise`类型的`next`,以供后面的链式调用.
        };
    });

    return callBlock ?: mkresolvedCallback(result); // (1) callBlock存在,说明result为nil,现在还没有结果;否则就执行后面的`mkresolvedCallback()` block.
}
```

这个方法的形参其实就是2个`block`，一个是`resolved`的`block`，还有一个是`pending`的`block`。当一个`promise`经历过`resolved`之后，可能是`fulfill`，也可能是`reject`，之后生成`next`新的`promise`，传入到下一个`then`中，并且状态会变成`pending`。上面代码中第一个`return`，如果`next`为`nil`，那么意味着`promise`没有生成，这是会再调用一次`mkresolvedCallback`，并传入参数`result`，生成的`PMKResolveOnQueueBlock`，再次传入`(q, block)`，直到`next`的`promise`生成，并把`pendingCallback`存入到`handler`当中。这个`handler`存了所有待执行的`block`，如果把这个数组里面的`block`都执行，那么就相当于依次完成了上面的所有异步操作。第二个`return`是在`callblock`为`nil`的时候，还会再调一次`mkresolvedCallback(result)`，保证一定要生成`next`的`promise`。

这个函数里面的`dispatch_barrier_sync`这个方法，就是`promise`后面可以链式调用`then`的原因，因为这个`GCD`函数保证了后面的`then`顺序执行。

### 三、 [Promises](https://github.com/google/promises)
> `google`出品

原理： 这个开源库的思路其实与`BFTask`很相似，每次`promise`执行then方法时都会创建一个新的`promise`对象，同时会创建一个观察者（`block`对象），这个观察者会持有这个新的`promise`，当（旧）`promise`对象`fulfilled`或者`rejected`的时候，会把`fulfilled`或者`rejected`拿到的`value`给新`promise`。

先看下promise的初始化方法:
```objc
- (instancetype)initPending {
  self = [super init];
  if (self) {
    dispatch_group_enter(FBLPromise.dispatchGroup);
  }
  return self;
}
```
首先进入一个单例`dispatch_group_t`中，为啥用`dispatch_group_t`呢？因为后面的`then`方法可以在其他队列处理，而且`dispatch_group_t`有同步队列的功能，后面作者每次初始化一个`promise`都会`enter`到`dispatch_group_t`中，`fulfilled`或者`rejected`时再`leave`。

接下来看看最重要同时也是精华所在的`then`方法：
```objc
- (instancetype)initPending {     // (0)
    self = [super init];
    if (self) {
        dispatch_group_enter(FBLPromise.dispatchGroup);
    }
    return self;
}

- (FBLPromise *)onQueue:(dispatch_queue_t)queue then:(FBLPromiseThenWorkBlock)work {
    return [self chainOnQueue:queue chainedFulfill:work chainedReject:nil];     // (1)
}

- (FBLPromise *)chainOnQueue:(dispatch_queue_t)queue
              chainedFulfill:(FBLPromiseChainedFulfillBlock)chainedFulfill
               chainedReject:(FBLPromiseChainedRejectBlock)chainedReject {
    // 首先new一个新的promise对象
    FBLPromise *newPromise = [[FBLPromise alloc] initPending];               // (2)
    
    // 这个block其实就是抽离的一个方法，避免写重复代码。
    // 当promise被fulfilled或者rejected时都会调用；
    // 结合下面方法block中的实现可以看出，如果thenBlock（chainedFulfill）存在，则先执行chainedFulfill这个block（其实就是map一下这个value值）重新生成一个value值（value值也可能不会变化，主要还得看map函数里有没有改变value）；接下来把这个重新赋值的value扔给resolverBlock，resolverBlock会把这个新的value给newPromise，newPromise会调用fulfilled方法，如果此时newPromise也有订阅者(被then过)，则就会把这个新value传递给下一个newNewPromise ...
    // 如果then的时候promise已经结束了，则直接把结果返回给订阅者,即调用thenBlock。
    __auto_type resolver = ^(id __nullable value) {
        if ([value isKindOfClass:[FBLPromise class]]) {                     // (8)
            [(FBLPromise *)value observeOnQueue:queue fulfill:^(id __nullable value) {
                [newPromise fulfill:value];
            } reject:^(NSError *error) {
                [newPromise reject:error];
            }];
        } 
        else {
            [newPromise fulfill:value];                                     // (8)
        }
    };
    [self observeOnQueue:queue fulfill:^(id __nullable value) {             
        value = chainedFulfill ? chainedFulfill(value) : value;             // (7)
        resolver(value);
    } reject:^(NSError *error) {
        id value = chainedReject ? chainedReject(error) : error;            // (7)
        resolver(value);
    }];
    return promise;
}

- (void)observeOnQueue:(dispatch_queue_t)queue
               fulfill:(FBLPromiseOnFulfillBlock)onFulfill
                reject:(FBLPromiseOnRejectBlock)onReject {

    @synchronized(self) {                                                   // (3)
        switch (_state) {
            // 默认的state，即待处理的事件
            case FBLPromiseStatePending: {
                // 如果promise对象还没有观察者数组，new一个
                // 这里为什么需要观察者数组呢？因为一个Promise可以被then很多次
                if (!_observers) {
                    _observers = [[NSMutableArray alloc] init];
                }
                // 当事件被处理时会执行下面block
                __auto_type observer = ^(FBLPromiseState state, id __nullable resolution) {
                    dispatch_group_async(FBLPromise.dispatchGroup, queue, ^{
                        switch (state) {                                    // (6)
                            case FBLPromiseStatePending:
                                break;
                            case FBLPromiseStateFulfilled:
                                onFulfill(resolution);
                                break;
                            case FBLPromiseStateRejected:
                                onReject(resolution);
                                break;
                        }
                    });
                };
                [_observers addObject:observer];                            // (4)
                break;
            }

            // 当前promise已经结束
            case FBLPromiseStateFulfilled: {
                dispatch_group_async(FBLPromise.dispatchGroup, queue, ^{
                    onFulfill(self->_value);
                });
                break;
            }

            // 当前promise已经结束
            case FBLPromiseStateRejected: {
                dispatch_group_async(FBLPromise.dispatchGroup, queue, ^{
                    onReject(self->_error);
                });
                break;
            }
    }
  }
}

- (void)fulfill:(nullable id)value {
  if ([value isKindOfClass:[NSError class]]) {
    [self reject:(NSError *)value];
  } else {
    @synchronized(self) {
      if (_state == FBLPromiseStatePending) {
        _state = FBLPromiseStateFulfilled;
        _value = value;
        _pendingObjects = nil;
        for (FBLPromiseObserver observer in _observers) {
          observer(_state, _value);                                         // (5)
        }
        _observers = nil;
        // 事件结束，leave group
        dispatch_group_leave(FBLPromise.dispatchGroup);
      }
    }
  }
}

- (void)reject:(NSError *)error {
  NSAssert([error isKindOfClass:[NSError class]], @"Invalid error type.");

  if (![error isKindOfClass:[NSError class]]) {
    // Give up on invalid error type in Release mode.
    @throw error;  // NOLINT
  }
  @synchronized(self) {
    if (_state == FBLPromiseStatePending) {
      _state = FBLPromiseStateRejected;
      _error = error;
      _pendingObjects = nil;
      for (FBLPromiseObserver observer in _observers) {
        observer(_state, _error);                                          // (5)
      }
      _observers = nil;
      // 事件结束，leave group
      dispatch_group_leave(FBLPromise.dispatchGroup);
    }
  }
}
```

主要的执行步骤已经在上面做了标注，作者的思路很鲜明，推荐同学们抽时间去学习一下这个库，必定会收获良多！

### 参考：
- [iOS如何优雅的处理“回调地狱Callback hell”(一)——使用PromiseKit](https://www.jianshu.com/p/f060cfd52f17)


