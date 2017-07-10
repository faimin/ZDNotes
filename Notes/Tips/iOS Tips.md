# iOS tips
![t@2x.png](https://ooo.0o0.ooo/2017/01/12/5876ebd6266ac.png)
### UITableView plain样式下，让section跟随滑动
```objc
// 让section跟随滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
#if 1
    // 上拉为正数，下拉为负数
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY > 0) {
        CGFloat padding = MIN(contentOffsetY, SectionHeight);
        self.tableView.contentInset = UIEdgeInsetsMake(-padding, 0, 0, 0);
        if (contentOffsetY > self.recordContentOffsetY) {   // 上拉
            
        }
        else {                                              // 下拉
            
        }
    }
    self.recordContentOffsetY = contentOffsetY; //设置一全局变量，记录滑动偏移量
    
#else
    
    if (contentOffsetY <= SectionHeight && contentOffsetY >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-contentOffsetY, 0, 0, 0);
    }
    else if (contentOffsetY >= SectionHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-SectionHeight, 0, 0, 0);
    }
#endif
}
```

### 设置tableViewCell之间的分割线
+ 第一种办法

```objc 
// 设置 `tableView`的`separatorInset`
self.tableView.separatorInset = UIEdgeInsetsZero;

// 运行程序后还是存在边距,接下来设置cell的属性
cell.layoutMargins = UIEdgeInsetsZero;
```

+ 第二种办法（推荐）

```objc
// 1、隐藏tableview的分割线
self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

// 2、把分割线的颜色设置为tableview的背景色
self.tableView.backgroundColor = [UIColor redColor];

// 3、重写cell的setFrame方法
- (void)setFrame:(CGRect)frame {
    frame.size.height -=1;
    [super setFrame:frame];
}
```

### 设置`tableViewCell`分割线的左右边距
Refer： http://itangqi.me/2017/02/28/uitableview-cell-separatorinset/

```objc
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If cell margins are derived from the width of the readableContentGuide.
    // NS_AVAILABLE_IOS(9_0)，需进行判断
    // 设置为 NO，防止在横屏时留白
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }

    // Prevent the cell from inheriting the Table View's margin settings.
    // NS_AVAILABLE_IOS(8_0)，需进行判断
    // 阻止 Cell 继承来自 TableView 相关的设置（LayoutMargins or SeparatorInset），设置为 NO 后，Cell 可以独立地设置其自身的分割线边距而不依赖于 TableView
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Remove seperator inset.
    // NS_AVAILABLE_IOS(8_0)，需进行判断
    // 移除 Cell 的 layoutMargins（即设置为 0）
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    // Explictly set your cell's layout margins.
    // NS_AVAILABLE_IOS(7_0)，需进行判断
    // 根据需求设置相应的边距
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 16)];
    }
}
```

### 修改`UITableviewCell.imageView`的大小
```objc
UIImage *icon = [UIImage imageNamed:@""];
CGSize itemSize = CGSizeMake(30, 30);
UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
[icon drawInRect:imageRect];
cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
```

### 判断某一行`cell`是否已经显示
```objc
CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
BOOL completelyVisible = CGRectContainsRect(tableView.bounds, cellRect);
```

### 打开或禁用`UIView`的复制、选择、全选等功能
```objc
// override the method
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
// 返回NO为禁用，YES为开启
    // 粘贴
    if (action == @selector(paste:)) return NO;
    // 剪切
    if (action == @selector(cut:)) return NO;
    // 复制
    if (action == @selector(copy:)) return NO;
    // 选择
    if (action == @selector(select:)) return NO;
    // 选中全部
    if (action == @selector(selectAll:)) return NO;
    // 删除
    if (action == @selector(delete:)) return NO;
    // 分享
    if (action == @selector(share)) return NO;
    return [super canPerformAction:action withSender:sender];
}
```

### 让`UIView`支持`Autolayout`计算高度
```objc
// 重写系统计算高度的方法
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority verticalFittingPriority:(UILayoutPriority)verticalFittingPriority {
    
    [_tagView layoutIfNeeded];
    [_tagView invalidateIntrinsicContentSize];
    
    return [super systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority:horizontalFittingPriority verticalFittingPriority:verticalFittingPriority];
}
```
### 为`NavigationBar`设置`titleView`
```objc
UIButton *titleButton = ({
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor blackColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [titleButton setTitle:showTitle forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"top-arrw"] forState:UIControlStateNormal];
    // 这句话是重点，如果不调用`sizeToFit`方法的话，titleView根本显示不出来，或者只显示文字
    [titleButton sizeToFit];
    button;
});
self.navigationItem.titleView = titleButton;
```
> http://stackoverflow.com/questions/13341562/how-to-set-button-for-navigationitem-titleview

### 手动更改iOS状态栏颜色
```objc
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];

    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;    
    }
}
```
### 更改状态栏的类型
[iOS 中关于 NavigationController 中 preferredStatusBarStyle 一直不执行的问题](http://www.tuicool.com/articles/MZfyE3Z)

```objc
// 在plist文件里把 `View controller-based status bar appearance` 设置成 `YES`。
// 
- (void)changeNavigationAndStatusBarStyle {
    /// 状态栏
    [self preferredStatusBarStyle];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.isBlackStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}
```
### 禁用UIButton的高亮状态
```objc
button.adjustsImageWhenHighlighted = NO;
//或者在创建的时候
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
```
### 判断view是不是指定视图的子视图
```objc
BOOL isView = [targetView isDescendantOfView:superView];
```
### 判断viewController是disappear还是dealloc
```objc  
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL isContains = [self.navigationController.childViewControllers containsObject:self];
    if (isContains) {
        NSLog(@"控制器只是单纯的disappear，比如pushToVC");
    } else {
        NSLog(@"控制器将要释放了");
    }
}
```
### 判断当前viewController是push进来的还是present进来的
> 如果A弹出B，那么A为presenting，B为presented。
A弹出B , 则B就是A的presentedViewController, A就是B的presentingViewController。
>
> 虽然A为控制器，但是当打印B的presentingViewController，显示类型为导航控制器，这说明如果当前视图有自己的导航控制器，则最终调用present方法的是当前控制器的导航控制器，如果不存在导航控制器，调用着是当前控制器（self）。

```objc
// 如果存在presentingViewController，则说明是当前视图是present出来的
if (self.presentingViewController) { 
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
} else {
    [self.navigationController popViewControllerAnimated:YES];
}            
```
### 修改`UItextField`中`placeholder`的文字颜色
```objc
[textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
```
### `UITextField`光标右移
```objc
// 创建一个 leftView
searchTextField.leftViewMode = UITextFieldViewModeAlways;
searchTextField.leftView = ({
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, margin, searchTextField.my_height)];
	leftView.backgroundColor = [UIColor clearColor];
	leftView;
});
```

### `UITextField`文字周围增加边距
```objc
// 子类化UITextField，增加insert属性
@interface ZDTextField : UITextField
@property (nonatomic, assign) UIEdgeInsets insets;
@end

// 在.m文件重写下列方法
- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);
    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeUnlessEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);

    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeUnlessEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect paddedRect = UIEdgeInsetsInsetRect(bounds, self.insets);
    if (self.rightViewMode == UITextFieldViewModeAlways || self.rightViewMode == UITextFieldViewModeWhileEditing) {
        return [self adjustRectWithWidthRightView:paddedRect];
    }
    return paddedRect;
}

- (CGRect)adjustRectWithWidthRightView:(CGRect)bounds {
    CGRect paddedRect = bounds;
    paddedRect.size.width -= CGRectGetWidth(self.rightView.frame);

    return paddedRect;
}
```

### 直接设置`UITextView`的`placeholder`
```objc
[self setValue:zd_placeHolderLabel forKey:@"_placeholderLabel"];
```

### 动态调整 `UITextView` 的高度
```objc
- (void)addKVOObserver {
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    UITextView *textView = object;
    textView.frame = (CGRect){textView.frame.origin, textView.frame.size.width, textView.contentSize.height};
    CGFloat topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
    topCorrect = MAX(0.0, topCorrect);
    textView.contentOffset = (CGPoint){0, -topCorrect};
}
```

### 当`UITextView/UITextField`中没有文字时，禁用回车键
```objc
textField.enablesReturnKeyAutomatically = YES;
```

### 动画修改`UILabel`上的文字
```objc
// 方法一
CATransition *animation = [CATransition animation];
animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
animation.type = kCATransitionFade;
animation.duration = 0.75;
[self.label.layer addAnimation:animation forKey:@"kCATransitionFade"];
self.label.text = @"New";

// 方法二
[UIView transitionWithView:self.label
                      duration:0.25f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        self.label.text = @"Well done!";

                    } completion:nil];

// 方法三
[UIView animateWithDuration:1.0
                     animations:^{
                         self.label.alpha = 0.0f;
                         self.label.text = @"newText";
                         self.label.alpha = 1.0f;
                     }];
```

### 计算`UILabel`上某段文字的`frame`
```objc
@implementation UILabel (TextRect)

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}
```


### 取消隐式动画
```objc
//方法一
[UIView performWithoutAnimation:^{
    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}];

//方法二
[UIView animateWithDuration:0 animations:^{
    [collectionView performBatchUpdates:^{
        [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    } completion:nil];
}];
     
//方法三
[UIView setAnimationsEnabled:NO];
[self.trackPanel performBatchUpdates:^{
    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
} completion:^(BOOL finished) {
    [UIView setAnimationsEnabled:YES];
}];

//方法四
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.frameLayer.frame = self.frameView.bounds;
    
    [CATransaction commit];
}
```
### 动画暂停和重新开始
Reference： [http://stackoverflow.com/questions/2306870/is-there-a-way-to-pause-a-cabasicanimation/3003922#3003922](http://stackoverflow.com/questions/2306870/is-there-a-way-to-pause-a-cabasicanimation/3003922#3003922)

```objc
- (void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
```

### Pop动画
[https://github.com/facebook/pop/issues/28](https://github.com/facebook/pop/issues/28)

![](https://camo.githubusercontent.com/28a42913bbc1dd0d27459991ef14b0a3b9a80489/687474703a2f2f662e636c2e6c792f6974656d732f334f3351336d3368305431323268316f323531592f506f70436f6e74726f6c506f696e74732e676966)

```objc
@property (nonatomic, assign) CGFloat controlPointOfLine; // property on view controller

- (void)controlPointAnimation
{
    self.controlPointOfLine = 0;

    CGFloat height = 300.f;
    bendiPath = [UIBezierPath bezierPath];
    [bendiPath moveToPoint:CGPointMake(0, 0)];
    [bendiPath addCurveToPoint:CGPointMake(0, height) controlPoint1:CGPointMake(0, height * 0.5) controlPoint2:CGPointMake(0, height * 0.5)];

    shape = [CAShapeLayer layer];
    shape.path = bendiPath.CGPath;
    shape.strokeColor = [UIColor blackColor].CGColor;
    shape.lineWidth = 10.f;
    shape.fillColor = nil;
    shape.position =CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
    [self.view.layer addSublayer:shape];

    //    return;
    self.pop = [POPAnimatableProperty propertyWithName:@"controlPointOfLine" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(DHTDetailViewController *obj, CGFloat values[]) {
            values[0] = self.controlPointOfLine;
        };
        // write value
        prop.writeBlock = ^(DHTDetailViewController *obj, const CGFloat values[]) {
            obj.controlPointOfLine = values[0];
            // update bezier
            [bendiPath removeAllPoints];
            [bendiPath moveToPoint:CGPointMake(0, 0)];
            [bendiPath addCurveToPoint:CGPointMake(0, height) controlPoint1:CGPointMake(obj.controlPointOfLine, height * 0.5) controlPoint2:CGPointMake(obj.controlPointOfLine, height * 0.5)];

            [label setText:[NSString stringWithFormat:@"%f", obj.controlPointOfLine]];
            [label sizeToFit];
            label.layer.position = self.view.center;
            shape.path = bendiPath.CGPath;
        };
        // dynamics threshold
        prop.threshold = 0.1;
    }];

    self.anim = [POPSpringAnimation animation];
    _anim.fromValue = @(-50.0);
    _anim.toValue =  @(0.f);
    _anim.springBounciness = 30.1;
    _anim.springSpeed = 10.4;
    _anim.dynamicsTension = 2000;
    _anim.property = self.pop;
    [self pop_addAnimation:_anim forKey:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];

// get touches in view, before and after shapelayer, to get the new control point
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    CGFloat controlPoint = location.x - shape.position.x;

    _anim.fromValue = @(controlPoint);
    _anim.toValue =  @(0.f);

     [self pop_addAnimation:_anim forKey:nil];
}
```

### Autolayout动画
```objc
[containerView setNeedsLayout];
[UIView animateWithDuration:1.0 animations:^{
  // Make all constraint changes here
  [containerView layoutIfNeeded];
}];
```
### 去掉导航栏返回按钮的back标题
```objc
// 第一种方法:
[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

// 第二种方法:
@implementation UINavigationItem (backBarButttonItem)
- (UIBarButtonItem*)backBarButtonItem {
    if ([UIDevice iOS_7]) {
        return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
    else {
        return [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
}
```
### 调整barButtonItem之间的距离
```objc
UIImage *img = [[UIImage imageNamed:@"icon_cog"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//宽度为负数的固定间距的系统item
UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
[rightNegativeSpacer setWidth:-15];

UIBarButtonItem *rightBtnItem1 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
UIBarButtonItem *rightBtnItem2 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
self.navigationItem.rightBarButtonItems = @[rightNegativeSpacer,rightBtnItem1,rightBtnItem2];
```
### 解决自定义返回按钮导致手势返回失败的问题
> 1、代理方法
> 
思路：先把导航控制器手势返回的代理保存起来，然后再把当前的控制器设为导航控制器手势返回的代理；当当前控制消失的时候再把原来的代理给导航控制器的手势返回。

```objc
@interface ViewController () <UIGestureRecognizerDelegate>
@end

@implementation ViewController {
    id<UIGestureRecognizerDelegate> _delegate
}

- (void)viewDidLoad {
   [super viewDidLoad];

     // 自定义返回按钮
   UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:({
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.size = (CGSize){22, 22};
        backButton.image = [UIImage imageNamed:@"icon_back"];
        [backButton.image addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        backButton;
    })];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)back:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
          // 记录系统返回手势的代理
        _delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
          // 设置系统返回手势的代理为当前控制器
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     // 设置系统返回手势的代理为我们刚进入控制器的时候记录的系统的返回手势代理
    self.navigationController.interactivePopGestureRecognizer.delegate = _delegate;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.childViewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}
@end
```
> 2、添加action事件的方法

```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(xxxx)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.interactivePopGestureRecognizer removeTarget:self action:@selector(xxxx)];
}
```

### 全屏手势返回
```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    // self.interactivePopGestureRecognizer系统手势类型为`UIScreenEdgePanGestureRecognizer`
    // 设置代理
    id target = self.interactivePopGestureRecognizer.delegate;
    // 创建手势,并设置代理
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    // 添加手势
    [self.view addGestureRecognizer:pan];
     // 将系统自带的手势覆盖掉
    self.interactivePopGestureRecognizer.enabled = NO;
}
```

### 从一个隐藏导航栏的 A 控制器 push 到一个有导航栏的 B 控制器中(导航栏隐藏问题)
> 在不显示导航栏的 A 控制器中遵守`UINavigationControllerDelegate`协议,实现其代理方法

```objc
#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isShowBar = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowBar animated:YES];
}
```

### 页面跳转时翻转动画
```objc
// modal方式
    TestViewController *vc = [[TestViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:nil];

// push方式
    TestViewController *vc = [[TestViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [self.navigationController pushViewController:vc animated:YES];
    [UIView commitAnimations];
```

### 以`modal`样式进行`push`跳转
```objc
- (void)push {
TestViewController *vc = [[TestViewController alloc] init];
    vc.view.backgroundColor = [UIColor redColor];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)pop {
CATransition* transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}
```

### 本地推送
> AppDelegate.m

```objc
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {//app在前台
        NSLog(@"app在前台");
    } else {//不在前台
        NSLog(@"app不在前台");
    }
}
```
> iOS10以前

```objc
- (void)post_Less_iOS10:(NSDictionary *)userInfo title:(NSString *)title body:(NSString *)body {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间，这里设置的是立即触发
    NSDate *fireDate = [NSDate date];
    notification.fireDate = fireDate;

    // 通知内容
    notification.alertBody =  body;
    // 标题，iOS8.2之后才有了这个属性
    if ([notification respondsToSelector:@selector(setAlertTitle:)]) {
        notification.alertTitle = title;
    }

    // 通知的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 附带内容
    notification.userInfo = userInfo;

    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        ///设置
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }

    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
```
> iOS10之后
 
```objc
- (void)registerNoti {
    // iOS10 兼容
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
        // 监听回调事件
        [uncenter setDelegate:self];
        //iOS10 使用以下方法注册，才能得到授权
        [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                }];
        // 获取当前的通知授权状态, UNNotificationSettings
        [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"未选择");
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                NSLog(@"未授权");
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                NSLog(@"已授权");
            }
        }];
    }
}

- (void)post_iOS10:(NSDictionary *)userInfo title:(NSString *)title body:(NSString *)body {
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];

    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:body
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];

    content.userInfo  = userInfo;
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1 repeats:NO];

    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content trigger:trigger];

    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    }];
}

#pragma mark - UNUserNotificationCenterDelegate
///在前台接收到通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    completionHandler(UNNotificationPresentationOptionAlert);//不写这句通知不会出现在前台，如有需要|UNNotificationPresentationOptionSound，角标UNNotificationPresentationOptionBadge
}

///点击通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //handle touch event
}
```
### 禁止锁屏
```objc
[UIApplication sharedApplication].idleTimerDisabled = YES;
// 或
[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
```
### 退出应用
```objc
//退出方法
- (void)exitApp {
	[UIView beginAnimations:@"exitApplication" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                           forView:self.view.window cache:NO];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	self.view.window.bounds = CGRectMake(0, 0, 0, 0);
	[UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID compare:@"exitApplication"] == 0) {
		exit(0); //退出
	}
}
```
### 获取手机安装的应用
```objc
Class c =NSClassFromString(@"LSApplicationWorkspace");
id s = [(id)c performSelector:NSSelectorFromString(@"defaultWorkspace")];
NSArray *array = [s performSelector:NSSelectorFromString(@"allInstalledApplications")];
for (id item in array) {
    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"applicationIdentifier")]);
    //NSLog(@"%@",[item performSelector:NSSelectorFromString(@"bundleIdentifier")]);
    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"bundleVersion")]);
    NSLog(@"%@",[item performSelector:NSSelectorFromString(@"shortVersionString")]);
}
```
### 打开系统设置界面
```objc
//iOS8之后
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//如果App没有添加权限，显示的是设定界面。如果App有添加权限（例如通知），显示的是App的设定界面。

//iOS8之前
//先添加一个url type如下图，在代码中调用如下代码,即可跳转到设置页面的对应项
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];

可选值如下：
About — prefs:root=General&path=About
Accessibility — prefs:root=General&path=ACCESSIBILITY
Airplane Mode On — prefs:root=AIRPLANE_MODE
Auto-Lock — prefs:root=General&path=AUTOLOCK
Brightness — prefs:root=Brightness
Bluetooth — prefs:root=General&path=Bluetooth
Date & Time — prefs:root=General&path=DATE_AND_TIME
FaceTime — prefs:root=FACETIME
General — prefs:root=General
Keyboard — prefs:root=General&path=Keyboard
iCloud — prefs:root=CASTLE
iCloud Storage & Backup — prefs:root=CASTLE&path=STORAGE_AND_BACKUP
International — prefs:root=General&path=INTERNATIONAL
Location Services — prefs:root=LOCATION_SERVICES
Music — prefs:root=MUSIC
Music Equalizer — prefs:root=MUSIC&path=EQ
Music Volume Limit — prefs:root=MUSIC&path=VolumeLimit
Network — prefs:root=General&path=Network
Nike + iPod — prefs:root=NIKE_PLUS_IPOD
Notes — prefs:root=NOTES
Notification — prefs:root=NOTIFICATI*****_ID
Phone — prefs:root=Phone
Photos — prefs:root=Photos
Profile — prefs:root=General&path=ManagedConfigurationList
Reset — prefs:root=General&path=Reset
Safari — prefs:root=Safari
Siri — prefs:root=General&path=Assistant
Sounds — prefs:root=Sounds
Software Update — prefs:root=General&path=SOFTWARE_UPDATE_LINK
Store — prefs:root=STORE
Twitter — prefs:root=TWITTER
Usage — prefs:root=General&path=USAGE
VPN — prefs:root=General&path=Network/VPN
Wallpaper — prefs:root=Wallpaper
Wi-Fi — prefs:root=WIFI
```
### iOS开发中的一些相关路径
```objc
模拟器的位置:
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs 

文档安装位置:
/Applications/Xcode.app/Contents/Developer/Documentation/DocSets

插件保存路径:
~/Library/ApplicationSupport/Developer/Shared/Xcode/Plug-ins

自定义代码段的保存路径:
~/Library/Developer/Xcode/UserData/CodeSnippets/ 
如果找不到CodeSnippets文件夹，可以自己新建一个CodeSnippets文件夹。

描述文件路径
~/Library/MobileDevice/Provisioning Profiles
```
### 匹配block的正则表达式
[正则表达式检测](http://www.regexr.com/)
```regex
// 解释：以`^`开头，`{`和`换行符`结束，中间（`*`表示匹配0次或多次，`+`表示匹配一次或者多次）匹配任意字符，最后是换行符
\^.*\{\n     
```
### ARC 下打印retainCount（引用计数）
```objc
// obj目标对象
NSInteger retainCount = CFGetRetainCount((__bridge CFTypeRef)obj);
NSLog(@"Retain count is %ld", retainCount);
```
### 系统隐藏的调试工具类 `UIDebuggingInformationOverlay`
> Reference: [http://ryanipete.com/blog/ios/swift/objective-c/uidebugginginformationoverlay/](http://ryanipete.com/blog/ios/swift/objective-c/uidebugginginformationoverlay/)
> 1、Call `[UIDebuggingInformationOverlay prepareDebuggingOverlay]` - I’m not sure exactly what this method does, but the overlay will be empty if you don’t call it.
> 2、Call `[[UIDebuggingInformationOverlay overlay] toggleVisibility]` - This shows the overlay window (assuming it’s not already visible).

```objc
/// Objective-C
- (void)debug {
#if DEBUG
    Class aClass = objc_getClass("UIDebuggingInformationOverlay");
    ((void (*) (id, SEL))(void *)objc_msgSend) ((id)aClass, sel_registerName("prepareDebuggingOverlay"));
    id returnInstance = ((id (*) (id, SEL))(void *)objc_msgSend) ((id)aClass, sel_registerName("overlay"));
    // 下面这个方法是可选的，可以不调用，因为直接两个手指点击状态栏就可以调出调试工具
    ((void* (*) (id, SEL))(void *)objc_msgSend) ((id)returnInstance, sel_registerName("toggleVisibility"));
#endif
}
```

```swift
/// Swift
let overlayClass = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type
_ = overlayClass?.perform(NSSelectorFromString("prepareDebuggingOverlay"))
let overlay = overlayClass?.perform(NSSelectorFromString("overlay")).takeUnretainedValue() as? UIWindow
_ = overlay?.perform(NSSelectorFromString("toggleVisibility"))
```
### 快速生成以实例变量名称作为`key`,变量作为`value`的字典
```
NSString *packId    = @"zero";
NSNumber *userId    = @(22);
NSArray *proxyTypes = @[@"int", @"string", @"double"];
NSDictionary *param = NSDictionaryOfVariableBindings(packId, userId, proxyTypes);
NSLog(@"%@", param);

<=> 等价于

NSDictionary *param = @{
	@"packId" : packId,
	@"userId" : userId,
	@"proxyTypes" : @[@"int", @"string", @"double"]
}; 
```
### 函数和消息代替`performSelector：`
```objc
if (!obj) { return; }
SEL selector = NSSelectorFromString(@"aMethod");
IMP imp = [obj methodForSelector:selector];
void (*func)(id, SEL) = (void *)imp;
func(obj, selector);

或者：
SEL selector = NSSelectorFromString(@"aMethod");
((void (*)(id, SEL))[obj methodForSelector:selector])(obj, selector);

或者：
//代码块：((<#ReturnClass#> (*) (id, SEL, <#ParameterClass, ...#>))(void *)objc_msgSend) ((id)<#self#>, sel_registerName(<#const char *str#>), <#Parameters, ...#>);

#import <objc/message.h>

((void(*)(id, SEL, id, int, BOOL))objc_msgSend)(ot, sel_registerName("A:B:C:"), value_1, value_2, value_3);
```
### 生成随机小数(0-1之间)
```objc
#define ARC4RANDOM_MAX      0x100000000
double val = ((double)arc4random() / ARC4RANDOM_MAX);
```
### iOS 常用数学函数
```C
	1、 三角函数 
　　double sin (double);正弦 
　　double cos (double);余弦 
　　double tan (double);正切 
　　2 、反三角函数 
　　double asin (double); 结果介于[-PI/2, PI/2] 
　　double acos (double); 结果介于[0, PI] 
　　double atan (double); 反正切(主值), 结果介于[-PI/2, PI/2] 
　　double atan2 (double, double); 反正切(整圆值), 结果介于[-PI, PI] 
　　3 、双曲三角函数 
　　double sinh (double); 
　　double cosh (double); 
　　double tanh (double); 
　　4 、指数与对数 
　　double exp (double);求取自然数e的幂 
　　double sqrt (double);开平方 
　　double log (double); 以e为底的对数 
　　double log10 (double);以10为底的对数 
　　double pow(double x, double y）;计算以x为底数的y次幂 
　　float powf(float x, float y); 功能与pow一致，只是输入与输出皆为浮点数 
　　5 、取整 
　　double ceil (double); 取上整 
　　double floor (double); 取下整 
　　6 、绝对值 
　　double fabs (double);求绝对值 
　　double cabs(struct complex znum) ;求复数的绝对值 
　　7 、标准化浮点数 
　　double frexp (double f, int *p); 标准化浮点数, f = x * 2^p, 已知f求x, p ( x介于[0.5, 1] ) 
　　double ldexp (double x, int p); 与frexp相反, 已知x, p求f 
　　8 、取整与取余 
　　double modf (double, double*); 将参数的整数部分通过指针回传, 返回小数部分 
　　double fmod (double, double); 返回两参数相除的余数 
　　9 、其他 
　　double hypot(double x, double y);已知直角三角形两个直角边长度，求斜边长度 
　　double ldexp(double x, int exponent);计算x*(2的exponent次幂) 
　　double poly(double x, int degree, double coeffs [] );计算多项式 
　　nt matherr(struct exception *e);数学错误计算处理程序
```
　　
### 参考帖子：
>* [iOS小技巧总结](http://www.jianshu.com/p/4523eafb4cd4)
>+ [多年iOS开发经验总结(二)](http://www.tuicool.com/articles/2Ynmui2)


