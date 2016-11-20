#CocoaPods错误集锦
1、The `master` repo requires CocoaPods 1.0.0 - (currently using 0.38.2)
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


