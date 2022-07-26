
## 分析Swift利器

> swiftc xxx.swift -emit-silgen | xcrun swift-demangle > xxxxSILGen.sil

## 值类型线程安全？

不要人云亦云，这个说法是有问题的，你想想假如我们有个变量 `var i = 1`，多线程修改时不需要加锁？

在未优化状态下值类型其实默认是在堆上分配的，只是在`SIL`优化阶段，编译器会根据上下文把大部分值类型改为在栈上分配，在栈上分配的情况是才是线程安全的，因为每个线程都有自己的栈空间，不需要考虑线程安全问题。但是对于被捕获的这种情况是没办法优化的，你想想如果放到栈上在出作用域后不就被释放了嘛，所以这种情况不会优化到栈上，而是继续留在堆上，也就是说这种场景下多线程操作值类型是不安全的，需要加锁来防止数据竞争。

那值类型的安全性体现在哪里呢？

1. 显式捕获：这种情况会发生值类型的拷贝操作，即生成一份新的变量，所以是安全的

2. 函数传参时值类型会发生拷贝，所以是安全的

3. `let` 标记的变量是不允许修改的，所以这种也是安全的

## 闭包

`OC`中的`block`默认会捕获外界变量，我们要想修改捕获的值需要添加`__block`。 但Swift不一样，Swift中默认是可以修改外界捕获的变量的，除非你显式捕获外界变量。

这是为什么呢？原因是`Swift`捕获外界变量会先被`HeapObject`包装一下，`HeapObject`再被`Box`包装一下，最后默认捕获的是`Box`，变量属于是被间接捕获的。有点类似于`OC`中的`__block`原理。当然，并不是所有的外界变量捕获都是经过包装过的，只有在闭包内发生修改的变量才会被包装。

```swift
 struct HeapObject {
    var Kind: UInt64
    var refcount: UInt64
 }
 
 // 负责包装的结构体,也就是用来包装捕获需要更新的值
 struct Box {
    var refCounted: HeapObject
    // 这个捕获的值的类型根据捕获的值进行分配，此处规范操作是写泛型
    // var value: Int
    var value: <T>
}
 ```

而显示捕获，经过编译后，其实是把被捕获的变量作为闭包函数的参数放到了原有闭包函数的后面，而值类型的函数参数在传参过程中会发生拷贝操作。


## Lazy

这里的`lazy`指的是高阶函数前面的`lazy`，而非属性声明中的`lazy`。

使用`lazy`后再执行高阶函数，返回的其实是一个`lazy`对象，比如对一个数组进行`XX`操作，返回的是 `LazyXXSequence` 类型，这个类型中会保存原函数的操作行为和原始数据，只有在对这个`lazy`类型进行操作时才会真正进行函数操作。

![Lazy](../ArticleImageResources/OpenSource/Swift/Swift_Lazy.png)


## 参考文章

- [从 SIL 角度看 Swift 中的值类型与引用类型](https://juejin.cn/post/7030983921328193549)

- [从 SIL 看 Swift 函数派发机制](https://mp.weixin.qq.com/s/KvwFyc1X_anTt-DTw86u7Q)

- [iOS下的闭包下篇-Closure](https://mp.weixin.qq.com/s/97Ij2N545ydx6WBNAwncOA)

- [Swift 性能优化(2)——协议与泛型的实现](http://chuquan.me/2020/02/19/swift-performance-protocol-type-generic-type/)

- [Swift 泛型底层实现原理](http://chuquan.me/2020/04/20/implementing-swift-generic/)
