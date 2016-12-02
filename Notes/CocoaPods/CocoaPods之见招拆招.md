#CocoaPods之见招拆招
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

以下2张图分别是旧版本的`spec`库和新版本`spec`库的结构，大家可以对比一下二者的结构：
![OldSpec](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/OldSpec.png)
![NewSpec](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/NewSpec.png)

#### 2、File not found with <angled> include; use "quoates" instead
在`target`中手动设置**Always Search User Paths**为**YES**，也可以通过`pod`动态设置（推荐）

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
		config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'YES'
    end
  end
end
```
#### 3、Cannot create `__weak reference` in file using manual reference counting
>+ https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2761
>+ @mdiep 对出现此问题的原因的解释：In Xcode 7.3, __weak causes errors in files compiled as -fno-objc-arc. Since RAC uses __weak, you cannot use it in those files without setting the Weak References in Manual Retain Release setting to YES. If you're using a .pch that imports RAC, you're more likely to see this error.

错误样式如下图所示
![ReactiveCocoa issue 2761](https://cloud.githubusercontent.com/assets/10302939/13940970/93497b58-f01d-11e5-9211-a96927537365.png)

**有3种解决办法：**


1）修改源码：把.h文件中报错的`__weak`标识删除（不能删除.m文件中的，否则会发生内存问题）


2）在引入`ReactiveCocoa`的地方添加`macro`判断标识：

```objc
#if __has_feature(objc_arc)
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
```


3）设置工程文件：设置`Weak References in Manual Retain Release`为`YES`
![weak reference in manual](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/weak%20reference%20setting.png)
#### 4、"The validator for Swift projects uses Swift 3.0 by default, if you are using a different version of swift you can use a `.swift-version	` file to set the version for you Pod. For example to use Swift 2.3, run: `echo "2.3" > .swift-version`:"
如下图所示：
![SwiftVersionError](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/Swift-versionError.png)

**解决办法：**

把`pod`的引用方式由`:git`方式改为指定版本号的方式。
#### 5、在`pod`中添加对私有`.a`文件的支持时，不需要在编译选项中设置任何东西，添加之后不仅没效果，还会报错
#### 6、在`podspec`文件中添加`source_files`时，不推荐`s.source_files = 'DDReaderModelFoundation/Define/*'`这种写法，最好写上后缀限制`s.source_files = 'DDReaderModelFoundation/Define/*.{h,m}`，因为假如在Define文件夹下包含`xib`或者其他资源文件时，会把资源文件也拷入`source_files`中，而资源文件在`podspec`中是需要单独设置的，比如下面的几种方式：

```ruby
spec.ios.resource_bundle = { 'MapBox' => 'MapView/Map/Resources/*.png' }
spec.resource_bundles = {
    'MapBox' => ['MapView/Map/Resources/*.png'],
    'OtherResources' => ['MapView/Map/OtherResources/*.png']
}

spec.resource = 'Resources/HockeySDK.bundle'
spec.resources = ['Images/*.png', 'Sounds/*']

spec.vendored_frameworks = 'MyFramework.framework', 'TheirFramework.framework'

spec.vendored_libraries = 'libProj4.a', 'libJavaScriptCore.a'
spec.ios.vendored_library = 'Libraries/libProj4.a'
```
> 对于`podspec`的语法我就不过多的贴在这里了，推荐大家阅读`cocoaPods`的官方**[wiki](http://guides.cocoapods.org/syntax/podspec.html)**
单独设置资源文件时也会发生引用、拷贝操作，这样就会导致编译问题。

这里有篇我同事写的**[文章](http://www.cnblogs.com/JoelZeng/p/6123234.html)**就是介绍这个坑的，大家可以了解一下。
#### 7、在`pod`的`pch`文件中添加引用时，比如

```objc
s.prefix_header_contents = '#import "DDDefine.h"'
```
不能添加自己工程中的文件，执行`pod lib lint`时，它会一直报找不到你想引入的文件的错误。

但是你可以在这里添加其他`pod`中的文件，或者`iOS`自己`API`中的库文件。





