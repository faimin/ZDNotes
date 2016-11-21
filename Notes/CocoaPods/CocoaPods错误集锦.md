#CocoaPods错误集锦
#### 1、The `master` repo requires CocoaPods 1.0.0 - (currently using 0.38.2)
> 参考：http://blog.cocoapods.org/Sharding/

安装1.0之前（e.g：v0.38.2）版本的pod

```ruby
sudo gem install cocoapods -v 0.38.2
```
之后在执行`pod setup`时，由于`pod`工具已经升级到`1.xx`版本了，`pod`算法以及`Specs`库中的文件结构已经改变，所以它会默认拉取新版本的`Specs`库，这样就会出现旧版本`pod`新版本`Specs`库的情况，当执行`pod install`的时候会发生找不到`xxx`第三方库的情况。

解决此问题的方案是需要在`Podfile`中指定`source`源地址：

``` 
source "https://github.com/CocoaPods/Old-Specs"
```
并把本地的`Specs`库切换到旧版本：

```git
cd ~/.cocoapods/repos/master/
git fetch origin master
git checkout v0.32.1
```

最后，在执行`pod install`的时候需要添加上`--no-repo-update`标识，因为`1.0`之前的`pod`版本在执行`pod install`的时候会默认先更新升级本地`Specs`库文件。

#### 2、File not found with <angled> include; use "quoates" instead
在`target`中设置**Always Search User Paths**为**YES**

#### 3、Cannot create `__weak reference` in file using manual reference counting
>+ https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2761
>+ @mdiep 对出现此问题的原因的解释：In Xcode 7.3, __weak causes errors in files compiled as -fno-objc-arc. Since RAC uses __weak, you cannot use it in those files without setting the Weak References in Manual Retain Release setting to YES. If you're using a .pch that imports RAC, you're more likely to see this error.

错误样式如下图所示
![ReactiveCocoa issue 2761](https://cloud.githubusercontent.com/assets/10302939/13940970/93497b58-f01d-11e5-9211-a96927537365.png)

######3种解决办法：
1）修改源码：把.h文件中报错的`__weak`标识删除（不能删除.m文件中的，否则会发生内存问题）


2）在引入`ReactiveCocoa`的地方添加`macro`判断标识：

```objc
#if __has_feature(objc_arc)
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
```


3）设置工程文件：set 'Weak References in Manual Retain Release:YES'
![weak reference in manual](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/weak%20reference%20setting.png)


