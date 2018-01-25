## Runloop

![](https://github.com/faimin/ZDStudyNotes/blob/1d849bd7e19b26af7996dd14d5a8e1d54cdb3ab7/Notes/SourceImages/RunLoop.png)

> `RunLoop`可观察的几种时机状态:

```objc
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
    kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
    kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
    kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
};
```

### `Runloop`中自动释放池的创建和释放

1. 第一次创建: 启动`runloop`
2. 最后一次销毁: `runloop`退出的时候
3. 其他时候的创建和销毁: 当`runloop`即将睡眠的时候销毁之前的释放池，然后重新创建一个新的。

### 线程保活

```objc
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
     @autoreleasepool {
        [[NSThread currentThread] setName:@"AFNetworking"];

        // 1.获取线程的runloop
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // 2.RunLoop 启动前内部必须要有至少一个 Timer/Observer/Source，所以 AFNetworking 在 [runLoop run] 之前先创建了一个新的 NSMachPort 添加进去了
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        // 3. 开启runloop
        [runLoop run];
     }
}

+ (NSThread *)networkRequestThread {
     static NSThread *_networkRequestThread = nil;
     static dispatch_once_t oncePredicate;
     dispatch_once(&oncePredicate, ^{
          _networkRequestThread =
          [[NSThread alloc] initWithTarget:self
               selector:@selector(networkRequestThreadEntryPoint:)
               object:nil];
          [_networkRequestThread start];
     });

     return _networkRequestThread;
}
```

### 参考

1. [深入理解RunLoop -- ibreme](https://blog.ibireme.com/2015/05/18/runloop/)
1. [CFRunLoop -- 戴铭](https://github.com/ming1016/study/wiki/CFRunLoop)