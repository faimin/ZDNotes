# Jenkins踩坑记录

#### 1、`homebrew`安装的`Jenkins`无法通过`IP`访问

这是因为`brew`把`jenkins`启动的监听地址设置为了`127.0.0.1`，改为`0.0.0.0`即可实现访问

`jenkins`配置所在路径：`~/Library/LaunchAgents/homebrew.mxcl.jenkins.plist`

![jenkins_config_address](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/jenkins_config_address.png)

#### 2、`jenkins`脚本中无法使用`pod`、`brew`等命令

需要在脚本开头添加 `-l`

```sh
#!/usr/bin/env sh -l

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

### 参考资料：

+ [Updating Homebrew’s “httpListenAddress” Default for Jenkins](http://mikezornek.com/posts/2013/11/updating-homebrews-httplistenaddress-default-for-jenkins/)