## Git常用操作

### git命令

查看命令历史： `git reflog`


查看提交记录：`git log`


查看指定条数的log：`git log -n <limit>`


查看远程库的信息：`git remote -v`


查看分支：`git branch`


创建分支：`git branch <name>`


切换分支：`git checkout <name>`


创建+切换分支：`git checkout -b <name>`


合并某分支到当前分支：`git merge <name>`


删除分支：`git branch -d <name>`


把远端的文件下载下来： `git fetch`


把远端的文件合并到本地： `git pull`  相当于`fetch + merge`


把当前目录下的文件更新添加到暂存区： `git add.`


查看更改：`git status`


查看修改过的内容：`git diff`


提交更新到缓存区：`git commit -a -m "提交说明"`


把本地缓存区的文件推送到远端：`git push`


回退到上一版本：`git reset --hard HEAD^`


回退到上上版本：`git reset --hard HEAD^^` 或 `git reset --hard HEAD~2`


回退到上n个版本：`git reset --hard HEAD~n`


回退到某一提交版本：`git reset --hard <commit_ID>`

------
+ `git revert <commit>`   撤销

> `git revert`命令用来撤销一个已经提交的快照。但是，它是通过搞清楚如何撤销这个提交引入的更改，然后在最后加上一个撤销了更改的新提交，而不是从项目历史中移除这个提交。这避免了Git丢失项目历史，这一点对于你的版本历史和协作的可靠性来说是很重要的。

------
+ `git reset <commit>`    重设

`git reset <file>`
> 从缓存区移除特定文件，但不改变工作目录。它会取消这个文件的缓存，而不覆盖任何更改。

`git reset`
> 重设缓冲区，匹配最近的一次提交，但工作目录不变。它会取消 所有 文件的缓存，而不会覆盖任何修改，给你了一个重设缓存快照的机会。

`git reset --hard`
> 重设缓冲区和工作目录，匹配最近的一次提交。除了取消缓存之外，--hard 标记告诉Git还要重写所有工作目录中的更改。换句话说：它清除了所有未提交的更改，所以在使用前确定你想扔掉你所有本地的开发。

`git reset <commit>`
> 将当前分支的末端移到<commit>，将缓存区重设到这个提交，但不改变工作目录。所有<commit>之后的更改会保留在工作目录中，这允许你用更干净、原子性的快照重新提交项目历史。

`git reset --hard <commit>`
> 将当前分支的末端移到<commit>，将缓存区和工作目录都重设到这个提交。它不仅清除了未提交的更改，同时还清除了<commit>之后的所有提交。

#### git回滚到指定版本并推送到远程分支：
1、本地分支会滚到指定版本
	`git reset --hard <提交记录号(hash值)>`


2、推送到远程分支
	`git push -f origin master`
	
#### 删除分支
1、删除本地已经合并了的分支
	`git branch -d <branchName>`


2、删除本地未合并的分支
	`git branch -D <branchName>`


3、删除远程分支
	`git push origin --delete <branchName>`
	
> 或者推送一个空分支到远程分支，其实就是相当于删除远程分支：
	`git push origin :<branchName>`

#### 删除tag

```git
git tag -d <tagname>
git push origin -d <tagname>
```

1、删除本地`tag`

```
git tag -d <tagname>
git push origin :refs/tags/<tagname>
```
2、删除远程`tag`

```
git push origin --delete tag <tagname>
```

3、批量删除tag

```
git tag | grep "0.0.d$" | xargs git tag -d
```
	
#### 解决有时clone下来代码后提示缺失文件的解决办法

添加`--recursive`参数选项

```git
git clone --recursive https://github.com/Cocoanetics/DTCoreText.git "/Users/sssss/Desktop/DTCoreTextDemo"
```

#### 'stash@{x}' is not a stash reference

![](http://olmn3rwny.bkt.clouddn.com/20180914114817_95vQdn_stash error.jpeg)

```git 
git stash list

//--- apply target stash
git stash apply refs/stash@{n} 

//---- delete target stash
git stash drop --index n
git stash drop refs/stash@{n}
```


### 推荐文章：
1、[代码回滚：Reset、Checkout、Revert的选择](https://github.com/geeeeeeeeek/git-recipes/wiki/5.2-%E4%BB%A3%E7%A0%81%E5%9B%9E%E6%BB%9A%EF%BC%9AReset%E3%80%81Checkout%E3%80%81Revert%E7%9A%84%E9%80%89%E6%8B%A9)

2、[回滚错误的修改](https://github.com/geeeeeeeeek/git-recipes/wiki/2.6-%E5%9B%9E%E6%BB%9A%E9%94%99%E8%AF%AF%E7%9A%84%E4%BF%AE%E6%94%B9)

3、[Git查看、删除、重命名远程分支和tag](http://zengrong.net/post/1746.htm)







