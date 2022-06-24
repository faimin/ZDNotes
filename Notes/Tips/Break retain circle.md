## 闭包破环

有时我们需要`block`捕获`self`，但是又不想发生循环引用，怎么办？

核心思路是借助中间人或者是主动破环。

现提供三种实现：

```objectivec
NSArray *wrapSelf = @[self];
self.block = ^void(AViewController *a) {
    [wrapSelf class];
    xxx
};
self.block(nil);
```


```objectivec
__block __strong __auto_type *strongSelf = self;
self.block = ^void(AViewController *a) {
    [strongSelf class];
    xxx
};
self.block(nil);
```



```objectivec
self.block = ^void(AViewController *a) {
    [self xxx];
};
self.block(nil);
// 主动破环
self.block = nil;
```