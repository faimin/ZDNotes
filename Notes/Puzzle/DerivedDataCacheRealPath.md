
## 获取 `Derived Data` 中缓存所对应的真实目录

引子：
> 我现在经常用 [DevCleaner](https://github.com/vashpan/xcode-dev-cleaner) 这款`APP`（App Store可以免费下载）来清理`Xcode`缓存，但是使我好奇的是它能获取每个同名工程不同文件夹的所在目录，到底是怎么获取到的呢？

![devcleaner_deriveddatafilename](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/devcleaner_deriveddatafilename.png)

一开始我以为文件名`Demo-aqtcnowksgrekocpqleqmtxwxqqw`后的乱码是路径加密后生成的，可是试了几种解密方式都不行。

![devcleaner_deriveddata](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/devcleaner_deriveddata.png)

值得庆幸的是`DevCleaner`是开源软件，所以还是从源码入手找答案吧。

![devcleaner_code](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/devcleaner_code.png)

从代码中我们可以看到原来在每个工程缓存文件夹中的`info.plist`文件中存储了路径，扫噶，一下子豁然开朗了。

![devcleaner_info](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/devcleaner_info.png)


## 参考：

- [xcode-dev-cleaner](https://github.com/vashpan/xcode-dev-cleaner)