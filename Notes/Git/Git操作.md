# Git操作
######git命令
查看提交记录：`git log`
查看分支：`git branch`
创建分支：`git branch <name>`
切换分支：`git checkout <name>`
创建+切换分支：`git checkout -b <name>`
合并某分支到当前分支：`git merge <name>`
删除分支：`git branch -d <name>`

把远端的文件下载下来： `git fetch`
把远端的文件合并到本地： `git pull`  相当于`fetch + merge`
把当前目录下的文件更新添加到暂存区： `git add.`
查看更改： `git status`
提交更新到缓存区： `git commit -a -m "提交说明"`
把本地缓存区的文件推送到远端： `git push`

#####git回滚到指定版本并推送到远程分支：
1、本地分支会滚到指定版本
	`git reset --hard <提交记录号(hash值)>`
2、推送到远程分支
	`git push -f origin master`
	
######解决有时clone下来代码后提示缺失文件的解决办法
`git clone --recursive https://github.com/Cocoanetics/DTCoreText.git "/Users/sssss/Desktop/DTCoreTextDemo"`

###推荐文章：
1、[代码回滚：Reset、Checkout、Revert的选择](https://github.com/geeeeeeeeek/git-recipes/wiki/5.2-%E4%BB%A3%E7%A0%81%E5%9B%9E%E6%BB%9A%EF%BC%9AReset%E3%80%81Checkout%E3%80%81Revert%E7%9A%84%E9%80%89%E6%8B%A9)





