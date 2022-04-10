## Code Tips

> `C` && `Objective-C`代码技巧 

---

#### 1. `GNU C`的赋值扩展：

    即使用`({...})`的形式。这种形式的语句可以类似很多脚本语言，在顺次执行之后，会将最后一次的表达式的值作为返回值。

> 注意：这个不是懒加载

```c
RETURN_VALUE_RECEIVER = {(
     // do whatever you want
     ...
     RETURN_VALUE; // 返回值
)};
```

   [REMenu](https://github.com/romaonthego/REMenu) 这个开源库中就使用了这种语法，如下：

```objectivec
_titleLabel = ({
   UILabel *label = [[UILabel alloc] initWithFrame:titleFrame];
   label.isAccessibilityElement = NO;
   label.contentMode = UIViewContentModeCenter;
   label.textAlignment = (NSInteger)self.item.textAlignment == -1 ? self.menu.textAlignment : self.item.subtitleTextAlignment;
   label.backgroundColor = [UIColor clearColor];
   label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
   label;
});
```

   使用这种语法的其中一个优点是结构鲜明紧凑，而且由于不用担心块里面的变量名污染外面变量名的问题。

#### 2. `case`语句中使用范围表达式：

> `GCC`对`C11`标准的语法扩展

   比如，`case 1 ... 5` 就表示值如果在 `1~5` 的范围内则满足条件。
   这里，省略号 `...` 就作为一个范围操作符，**其左右两个操作数之间至少要用一个空白符进行分割**，如果写成 `1...5` 这种形式会引发词法解析错误。范围操作符的操作数可以是任一整数类型，包括字符类型。
   另外，范围操作符的做操作数的值应该小于或等于右操作数，否则该范围表达式就会是一个空条件范围，永远不成立。

```c
#include <stdio.h>

int main(int argc, const char * argv[]) {

    int a = 1; 
    const int c = 10;

    switch(a) {
        // 这条case语句是合法的，并且与case 1等效 
        case 1 ... 1:
            printf("a = %d\n", a);
            break;

        // 这条case语句中的范围操作符的左操作数⼤于右操作数， 
        // 因此它是⼀个空条件范围，这条case语句下的逻辑永远不会被执⾏ 
        case 2 ... 1:
            puts("Hello, world!"); 
            break;

        // 使⽤const修饰的对象也可作为范围操作符的操作数 
        case 8 ... c:
            puts("Wow!");
            break;

        default: 
            break;
    }

    char ch = 'A'; 
    switch(ch) {
        // 从'A'到'Z'的ASCII码范围 
        case 'A' ... 'Z':
            printf("The letter is: %c\n", ch);
            break;

        // 从'0'到'9'的ASCII码范围 
        case '0' ... '9':
            printf("The digit is: %c\n", ch);
            break;

        default:
            break;
    }
}
```

#### 3. 使用`__auto_type`做类型推导：

> `GCC`对`C11`标准的语法扩展

```c
#if defined(__cplusplus)
#define var auto
#define let auto const
#else
#define var __auto_type
#define let const __auto_type
#endif
```

例如：

```objectivec
 let block = ^NSString *(NSString *name, NSUInteger age) {
     return [NSString stringWithFormat:@"%@ + %ld", name, age];
 };
 let result = block(@"foo", 100);  // no warning
```

#### 4. 结构体的初始化：

```objectivec
 // 不加(CGRect)强转也不会warning
 GRect rect1 = {1, 2, 3, 4};
 CGRect rect2 = {.origin.x=5, .size={10, 10}}; // {5, 0, 10, 10}
 CGRect rect3 = {1, 2}; // {1, 2, 0, 0}
```

#### 5. 数组的下标初始化：

```objectivec
 const int numbers[] = {
     [1] = 3,
     [2] = 2,
     [3] = 1,
     [5] = 12306
 };
 // {0, 3, 2, 1, 0, 12306}
```

   **这个特性可以用来做枚举值和字符串的映射**

```objectivec
 typedef NS_ENUM(NSInteger, Type){
     Type1,
     Type2
 };
 const NSString *TypeNameMapping[] = {
     [Type1] = @"Type1",
     [Type2] = @"Type2"
 };
```

   又如 `UITableView+FDIndexPathHeightCache`中的例子：

```objectivec
 // All methods that trigger height cache's invalidation
 SEL selectors[] = {
     @selector(reloadData),
     @selector(insertSections:withRowAnimation:),
     @selector(deleteSections:withRowAnimation:),
     @selector(reloadSections:withRowAnimation:),
     @selector(moveSection:toSection:),
     @selector(insertRowsAtIndexPaths:withRowAnimation:),
     @selector(deleteRowsAtIndexPaths:withRowAnimation:),
     @selector(reloadRowsAtIndexPaths:withRowAnimation:),
     @selector(moveRowAtIndexPath:toIndexPath:)
 };

 for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
     SEL originalSelector = selectors[index];
     SEL swizzledSelector = NSSelectorFromString([@"fd_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
     Method originalMethod = class_getInstanceMethod(self, originalSelector);
     Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
     method_exchangeImplementations(originalMethod, swizzledMethod);
 }
```

#### 6. 自带提示的`keypath`宏：

```objectivec
#define keypath2(OBJ, PATH) \
 (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
```

#### 7. 逗号表达式：

   逗号表达式取后值，但前值的表达式参与运算，可用`void`忽略编译器警告

```objective-c
 int a = ((void)(1+2), 2); // a == 2
```

   于是上面的`keypath`宏的输出结果是`#PATH`也就是一个`c`字符串 

#### 8. `C`函数重载标示符：

> [RTRootNavigationController](https://github.com/rickytan/RTRootNavigationController/blob/master/RTRootNavigationController/Classes/RTRootNavigationController.m) 中有用到这个技巧

```objective-c
 __attribute((overloadable)) NSInteger ZD_SumFunc(NSInteger a, NSInteger b) {
     return a + b;
 }

 __attribute((overloadable)) NSInteger ZD_SumFunc(NSInteger a, NSInteger b, NSInteger c) {
     return a + b + c;
 }
```

#### 9. 参数个数

```c
// 最多支持10个参数
#define COUNT_PARMS2(_a1, _a2, _a3, _a4, _a5, _a6, _a7, _a8, _a9, _a10, RESULT, ...) RESULT
#define COUNT_PARMS(...) COUNT_PARMS2(__VA_ARGS__, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

int count = COUNT_PARMS(1,2,3,4,5,6); // 预处理时count == 6
```

#### 10. 同名全局变量或者全局函数共存：

```c
 // 下面二者可以并存
 NSDictionary *ZDInfoDict = nil;

 __attribute__((weak)) NSDictionary *ZDInfoDict = nil;
```

#### 11. 偷梁换柱：

```swift
class Test {
    dynamic func foo() {
        print("bar")
    }
}

extension Test {
    @_dynamicReplacement(for: foo())
    func new_foo() {
        print("bar new")
        foo()  // calls previous implementation
    }
}

Test().foo() // bar new
```

> 有2点需要说明：
> 
> 1. 标注`dynamic`关键字
> 2. 在工程中运行，`playground`不支持

#### 12. 移花接木

```swift
@_silgen_name("backtrace")
internal func swift_backtrace(_ callstacks: UnsafeMutableRawPointer, _ counts: Int) -> Int

@_silgen_name("backtrace_symbols")
internal func swift_backtrace_symbols(_ callstacks: UnsafeRawPointer, _ counts: Int) -> UnsafeMutablePointer<UnsafePointer<CChar>>?

//------------------------------------------------

static func callstack() -> [String] {
    var callstack = [UnsafeMutableRawPointer?](repeating: nil, count: 128)
    let frames = swift_backtrace(&callstack, callstack.count)

    var callstackArr: [String] = []
    if let symbols = swift_backtrace_symbols(&callstack, frames) {
        for frame in 0..<frames {
            let symbol = String(cString: symbols[frame])
            callstackArr.append(symbol)
        }

        free(symbols)

        os_log("堆栈信息 => %@", log: .apmLog, type: .info, callstackArr)
    }

    return callstackArr
}
```

#### 13. Swift类名解析

```shell
# xcrun swift-demangle _TtC11NewWolfKill22WKRoomControlMenuModel
$ xcrun swift-demangle <your-mangled-symbol>
```

#### 14. 队列校验

```swift
methodThatCallsBackOnMain(completion: { result in
    // 确保在主队列中调用
    dispatchPrecondition(.onQueue(.main))

    // process `result`
    // ...
})
```

#### 15. Assert

`assert`会导致程序退出，下面这种方式不会使程序退出而只是让`IDE`断在指定位置，类似于打断点那种效果

```c
// 适用于所有架构
__builtin_debugtrap()
```

如果是模拟器，可以使用内联汇编的方式

```c
asm("int3")
```

如果是win平台，可以用

```c++
__debugbreak()
```



贴段样例：

```objc
// MARK: - ZDAssert
#if DEBUG
#ifndef ZDAssert
#define ZDAssert(condition, format, ...) do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wobjc-literal-conversion\"") \
    if (condition) break; \
    if (format) printf("\n%s\n\n", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); \
    _Pragma("clang diagnostic pop") \
    __builtin_debugtrap(); \
} while(0);
#endif
#else
#ifndef ZDAssert
#define ZDAssert(condition, format, ...)
#endif
#endif
```



#### 16. 保证对象的生命周期

1. Swift
   
   [withExtendedLifetime()](https://github.com/apple/swift/blob/541f7725e1b0f4ac2cfc1f1b71a90c5a5c813c1d/stdlib/public/core/Unmanaged.swift#L145)
   
   ```swift
   var owningReference = Instance()
   ...
   withExtendedLifetime(owningReference) {
       dosomething(...)
   }  // Assuming: No stores to owned occur for the dynamic lifetime of
      //         the withExtendedLifetime invocation.
   ```

2. Objective-C
   
   在 Objective-C ARC 中你可以使用 `__attribute__((objc_precise_lifetime))` 或者 `NS_VALID_UNTIL_END_OF_SCOPE` 来标注变量以达到类似的效果.







-------

### 参考：

- [objc非主流代码技巧](http://blog.sunnyxx.com/2014/08/02/objc-weird-code/)

- [Even Swiftier Objective-C](https://pspdfkit.com/blog/2017/even-swiftier-objective-c/)

- [《C语言编程魔法书》](http://www.jb51.net/books/620682.html)

- [GCC中的弱符号与强符号](https://www.cnblogs.com/kernel_hcy/archive/2010/01/27/1657411.html)

- [swift: SIL](https://github.com/apple/swift/blob/main/docs/SIL.rst)

- [30-tips-to-make-you-a-better-ios-developer](https://www.fadel.io/blog/posts/30-tips-to-make-you-a-better-ios-developer)

- [C/C++调试技巧-debugbreak](https://www.bilibili.com/read/cv1165694)

- [Swift 中的 ARC 机制: 从基础到进阶](https://mp.weixin.qq.com/s/ZJ3gVI-jzDcKpRKa0IMi0A)


