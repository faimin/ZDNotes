# CocoaPods Tips

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

> + https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2761
> + @mdiep 对出现此问题的原因的解释：In Xcode 7.3, __weak causes errors in files compiled as -fno-objc-arc. Since RAC uses __weak, you cannot use it in those files without setting the Weak References in Manual Retain Release setting to YES. If you're using a .pch that imports RAC, you're more likely to see this error.

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

#### 4、"The validator for Swift projects uses Swift 3.0 by default, if you are using a different version of swift you can use a `.swift-version    ` file to set the version for you Pod. For example to use Swift 2.3, run: `echo "2.3" > .swift-version`:"

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
> 单独设置资源文件时也会发生引用、拷贝操作，这样就会导致编译问题。

这里有篇我同事写的**[文章](http://www.cnblogs.com/JoelZeng/p/6123234.html)**就是介绍这个坑的，大家可以了解一下。

#### 7、在`pod`的`pch`文件中添加引用时，比如

```objc
s.prefix_header_contents = '#import "DDDefine.h"'
```

不能添加自己工程中的文件，执行`pod lib lint`时，它会一直报找不到你想引入的文件的错误。

但是你可以在这里添加其他`pod`中的文件，或者`iOS`自己`API`中的库文件。

#### 8、`CocoaPods`卸载

有的时候不小心把`podSpec`升级到了`1.x` 版本，然后`pod search`就不能用了，然后通过切换分支`checkout`到`v0.32.1`，但是`pod search`还是报错：

```pod
$ pod search ZDTableView
[!] Unable to load a specification for the plugin `/Users/fuxianchao/.rvm/gems/ruby-2.2.1/gems/cocoapods-deintegrate-1.0.0.beta.1`

――― MARKDOWN TEMPLATE ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

 Command

/Users/fuxianchao/.rvm/gems/ruby-2.2.1/bin/pod search ZDTableView


 Report

* What did you do?

* What did you expect to happen?

* What happened instead?

 Stack

   CocoaPods : 0.38.2
        Ruby : ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
    RubyGems : 2.4.8
        Host : Mac OS X 10.12.2 (16C67)
       Xcode : 8.2.1 (8C1002)
         Git : git version 2.11.0
Ruby lib dir : /Users/fuxianchao/.rvm/rubies/ruby-2.2.1/lib
Repositories : cocoapods - https://github.com/CocoaPods/Old-Specs @ 6e256ccc84aad851d401fabb79b2c0f9e09bb875
               DDSpec - http://10.255.223.213/ios-code/DDSpec.git @ 941bed4b0c03090e13ecb7ee16a1eafa77969785
               master - https://github.com/CocoaPods/Specs.git @ 2d939ca0abb4172b9ef087d784b43e0696109e7c


Plugins

cocoapods-keys        : 1.7.0
cocoapods-playgrounds : 0.1.0
cocoapods-plugins     : 0.4.2
cocoapods-search      : 1.0.0.beta.1
cocoapods-stats       : 0.5.3
cocoapods-trunk       : 0.6.4
cocoapods-try         : 0.4.5

Error

NoMethodError - undefined method `all' for Pod::Platform:Class
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/gems/cocoapods-search-1.0.0.beta.1/lib/cocoapods-search/command/search.rb:34:in `initialize'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:334:in `new'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:334:in `parse'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:330:in `parse'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:308:in `run'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/gems/cocoapods-0.38.2/lib/cocoapods/command.rb:48:in `run'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/gems/cocoapods-0.38.2/bin/pod:44:in `<top (required)>'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/bin/pod:23:in `load'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/bin/pod:23:in `<main>'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/bin/ruby_executable_hooks:15:in `eval'
/Users/fuxianchao/.rvm/gems/ruby-2.2.1/bin/ruby_executable_hooks:15:in `<main>'

――― TEMPLATE END ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

[!] Oh no, an error occurred.

Search for existing GitHub issues similar to yours:
https://github.com/CocoaPods/CocoaPods/search?q=undefined+method+%60all%27+for+Pod%3A%3APlatform%3AClass&type=Issues

If none exists, create a ticket, with the template displayed above, on:
https://github.com/CocoaPods/CocoaPods/issues/new

Be sure to first read the contributing guide for details on how to properly submit a ticket:
https://github.com/CocoaPods/CocoaPods/blob/master/CONTRIBUTING.md

Don't forget to anonymize any private data!
```

这时候我的做法通常就是卸载`pod` ，然后重新安装。

```ruby
$ which pod //得到path
$ sudo rm -rf <path>
// 循环遍历卸载pod组件（如果是安装在了用户目录下，那就去掉命令中的sudo）
$ for i in `gem list | grep pod | awk '{print $1}'`; do sudo gem uninstall  $i; done
```

有的时候对于新系统直接调用`gem install cocoapods` 是不行的，提示错误，此种情况就用下面的命令：

```ruby
// 安装指定版本的pod
sudo gem install -n /usr/local/bin cocoapods -v 1.2.0
// 卸载
sudo gem uninstall -n /usr/local/bin cocoapods -v 1.2.0
```

#### 9、Library not found for -lAFNetworking

![](http://olmn3rwny.bkt.clouddn.com/20170220194028_e1YcoQ_Library not found for -lAFNetworking.jpeg)
这种情况的解决方案是设置`project` -> `build setting` -> `library search patchs` 里添加 `$(inherited)` 标识。

#### 10、Cannot synthesize weak property because the current deployment target does not support weak refernces

![](http://olmn3rwny.bkt.clouddn.com/20170221184314_Ewqne4_Screenshot.jpeg)
refer: [http://stackoverflow.com/questions/37160688/set-deployment-target-for-cocoapodss-pod](http://stackoverflow.com/questions/37160688/set-deployment-target-for-cocoapodss-pod)
解决方案：

```cocoaPods
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == 'DDKit'
                config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'NO'
            elsif target.name == 'PulsingHalo'
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.2'
            end
        end
    end
end
```

或者错误提示为：`Cannot synthesize weak property in file using manual reference counting`

```cocoaPods
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == 'ReactiveCocoa'
                config.build_settings['CLANG_ENABLE_OBJC_WEAK'] = 'YES'
            end
        end
    end
end
```

#### 11、`Cocoapods` debug

我们可以用 `pry` 来调试 `podfile` ，即调试 `ruby`，使用之前先安装

```ruby
gem install pry
```

接下来在 `podfile` 中导入 `require 'pry'`，然后在你想打断点调试的地方添加一行代码 `binding.pry`，这样就可以在每次执行`pod install` or `pod update` 的时候断在这句代码的位置，我们就可以调试了；

#### 12、自动添加`modulemap`的支持

如果我们想以`@import`的方式引用一个不支持`modulemap`的`repo`，那么我们可以让`CocoaPods`自动生成`modulemap`，语法如下：

```ruby
pod 'MLFilterKit', '1.9.705', :modular_headers => true
```

这个可以解决部分`repo`中 `@import` 报错的问题；

#### 13、为`CocoaPods`开启增量编译模式：

> 开启增量编译模式后，`post_install、pre_install` 中的某些设置会报错，因为工程配置的层级结构发生了变化；

```ruby
install! 'cocoapods',
         :generate_multiple_pod_projects => true,
         :incremental_installation => true
```

#### 14、静态库和动态库共存的设置：

```ruby
# https://www.rubydoc.info/gems/cocoapods/Pod
# https://github.com/facebook/flipper/issues/254
# https://github.com/facebook/flipper/blob/master/docs/getting-started.md
$dynamic_framework = ['LayoutInspector', 'PromiseKit', 'Yoga', 'YogaKit']
pre_install do |installer|
#    installer.pod_targets.each do |pod|
#        if $dynamic_framework.include?(pod.name)
#            pod.instance_variable_set(:@host_requires_frameworks, true)
#        end
#    end

  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
  installer.pod_targets.each do |pod|
     if not $dynamic_framework.include?(pod.name)
       def pod.build_type;
          Pod::Target::BuildType.static_library
       end
     end
  end
end
```

--------

### 参考：

- [CocoaPods 大全](https://guides.cocoapods.org/)

- [podspec 语法指南](http://guides.cocoapods.org/syntax/podspec.html#specification)

- [podfile 语法指南](https://guides.cocoapods.org/syntax/podfile.html)

- [开启 Cocoapods 新选项，加快项目索引速度](https://kemchenj.github.io/2019-05-31/)

- [Flipper](https://github.com/facebook/flipper/blob/master/docs/getting-started.md)
