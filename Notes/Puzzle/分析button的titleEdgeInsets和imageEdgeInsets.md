#分析button的titleEdgeInsets和imageEdgeInsets
含有图片和文字的`button`默认情况下是图片在左，标题在右的<br>
![](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/originPosition.png) <br>
上图中的`image`尺寸是`230*230`，`title`的宽度大约是`70`。

现在，我想要让`title`和`image`调换位置，怎么办呢？<br>
以前我的做法是在一个`view`上放一个`imageView`和`label`来处理，虽然我也知道利用`button`的`titleEdgeInsets`和`imageEdgeInsets`属性可以通过调整偏移值来实现，但是我根本就找不出调整的规律，觉得这个根本就无规律可循。如果是个死`button`是可以这样调一下的，但是如果图片和文字一改变，以前调整好的`inset`统统完蛋。。。

不过，后来听说这个是有章法可循的，然后一时兴起笔者就新建了个空工程，在`storyboard`中添加了个`button`，然后利用`nib`的实时动态调整功能，理解了官方文档中
> This property is used only for positioning the title during layout. The button does not use this property to determine intrinsicContentSize and sizeThatFits:.

所说的意思。

现在咱们一步步的来：

1、先把`title`移到图片左边去，按理说向左移动一个图片的宽度值不就行了吗？但是看图

![titleInsetsLeft-230Right0](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/titleInsetsLeft-230Right0.png)

what the fuck！！！

完全不是想象中的样子嘛！为什么只移动到了图片的中心位置呢？？？

然后再调整下`titleEdgeInsets`的`right`值

![titleInsetsLeft-230Right230](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/titleInsetsLeft-230Right230.png)

这样才对嘛。至于为什么要左右值都要移动呢，而不是继续移动`left`的值（比如把`left`设置为`-460`），一会儿再解释。

`title`移过去了，那接下来再把`image`移过去就万事大吉了。要想移动`image`需要调整`imageEdgeInsets`属性的值，看图：

![imageInsetsLeft70Right0](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/imageInsetsLeft70Right0.png)

靠，还是一半。。。依据上面的经验修改`right`值呗：

![imageInsetsLeft70Right-70](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/imageInsetsLeft70Right-70.png)

这才是最终咱们想要的结果。

那么，为什么要像上面那样操作呢？为什么`left`和`right`值要同时设置才可以？为什么不只是移动一个`left`或者`right`？

其实，就拿`button`中的`image`和`title`的原始位置来说吧，**`image`的上、左、下是相对于`button`本身的，而右边是相对于`title`的，`title`的上、下、右是相对于`button`本身的，而左边是相对于`image`的。** 如果你一味的只移动一个值，比如`left`，在视觉上是对的，但是做法是错的，因为你误解了这两个属性的用法。

比如你直接设置

```objc
button.titleEdgeInsets = UIEdgeInsetsMake(0, -460, 0, 0);
``` 
意思就是`title`上下位置不变，左边相对于`button`左移了`460`个距离，右边相对于`title`来说没动，这显然是错的，当`title`左移时，`image`是没动的，这样`title`相对于`image`来说不可能是静止的，所以`right`的值怎么可能为`0`呢！是吧！同样的，当设置`button.imageEdgeInsets`时`title`此时是静止的，所以当`image`向右移动时，左边相对于`button`移动了`title`宽度个距离，右边相对于`title`来说也是移动了`title`宽度个距离，因为`image`左边是远离`button`，所以`left`是正值，而右边相对于`title`的原始位置来说是接近，所以是负值。

同理，如果想设置image上title下的效果，只要记住他们的相对关系就OK了。
下面提供一个半成品😀，只要知晓了原理，就好搞了~~~

![imageUpTitleDown](https://github.com/faimin/ZDStudyNotes/blob/master/Notes/SourceImages/buttonEdgeInsets/imageUpTitleDown.png)

###总结
`button`控件中：

`image`的上、左、下是相对于`button`本身的，而右边是相对于`title`的;

`title`的上、下、右是相对于`button`本身的，而左边是相对于`image`的;

### 参考
> http://www.cnblogs.com/Phelthas/p/4452235.html


