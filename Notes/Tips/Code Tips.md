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

#### 9. 同名全局变量或者全局函数共存：

    ```c
    // 下面二者可以并存
    NSDictionary *ZDInfoDict = nil;

    __attribute__((weak)) NSDictionary *ZDInfoDict = nil;
    ```

-------

### 参考：

- [objc非主流代码技巧](http://blog.sunnyxx.com/2014/08/02/objc-weird-code/)

- [Even Swiftier Objective-C](https://pspdfkit.com/blog/2017/even-swiftier-objective-c/)

- [《C语言编程魔法书》](http://www.jb51.net/books/620682.html)

- [GCC中的弱符号与强符号](https://www.cnblogs.com/kernel_hcy/archive/2010/01/27/1657411.html)

