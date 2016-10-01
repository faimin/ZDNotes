# Blots、PromiseKit源码简析
####一、Bolts:
`BFTask`原理：
每个`BFTask`自己都维护着一个任务数组，当task执行`continueWithBlock:`后（会生成一个新的`BFTask`），`continueWithBlock:`带的那个block会被加入到任务数组中，每当有结果返回时，会执行`trySetResult:`方法，这个方法中会拿到task它自己维护的那个任务数组，然后取出其中的所有任务block，然后遍历执行。

####二、Promise:
* 1、首先，让我们看看创建Promise的源码

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
调用`new:`方法时会调用`promiseWithResolver:`方法，在里面进行一些初始化`promise`的工作：创建了一个GCD并发队列和一个数组，并立即回调`new:`后面的那个参数`block`，即：立即执行，生成一个成功（fulfiller）和失败（rejecter）的block，这个block将由用户控制进行回调操作。

----
* 2、下面看一下`then`的源码实现：

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
> 这个方法看上去很复杂，仔细看看,函数的形参其实就是2个block，一个是resolved的block，还有一个是pending的block。当一个promise经历过resolved之后，可能是fulfill，也可能是reject，之后生成next新的promise，传入到下一个then中，并且状态会变成pending。上面代码中第一个return，如果next为nil，那么意味着promise没有生成，这是会再调用一次mkresolvedCallback，并传入参数result，生成的PMKResolveOnQueueBlock，再次传入(q, block)，直到next的promise生成，并把pendingCallback存入到handler当中。这个handler存了所有待执行的block，如果把这个数组里面的block都执行，那么就相当于依次完成了上面的所有异步操作。第二个return是在callblock为nil的时候，还会再调一次mkresolvedCallback(result)，保证一定要生成next的promise。

> 这个函数里面的这里dispatch_barrier_sync这个方法，就是promise后面可以链式调用then的原因，因为GCD的这个方法，让后面then变得像一行行的then顺序执行了。



