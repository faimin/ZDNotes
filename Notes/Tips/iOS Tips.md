##iOS tips：
#####UITableView plain样式下，让section跟随滑动
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
#####手动更改iOS状态栏颜色
```objc
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];

    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;    
    }
}
```
#####更改状态栏的类型
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
    return self.isOpaqueStatusBar ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}
```
#####手势全屏返回
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
#####判断view是不是指定视图的子视图
```objc
BOOL isView = [targetView isDescendantOfView:superView];
```
#####判断viewController是disappear还是dealloc
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
#####判断当前viewController是push来的还是present来的
> 如果A弹出B，那么A为presenting，B为presented。
A弹出B , 则B就是A的presentedViewController, A就是B的presentingViewController
虽然A为控制器，但是当打印B的presentingViewController，显示类型为导航控制器，这说明如果当前视图有自己的导航控制器，则最终调用present方法的是当前控制器的导航控制器，如果不存在导航控制器，调用着是当前控制器（self）。

```objc
// 如果存在presentingViewController，则说明是当前视图是present出来的
if (self.presentingViewController) { 
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
} else {
    [self.navigationController popViewControllerAnimated:YES];
}            
```
#####修改UItextField中placeholder的文字颜色
```objc
[textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
```
#####UITextField 光标右移
创建一个 leftView
```objc
searchTextField.leftViewMode = UITextFieldViewModeAlways;
searchTextField.leftView = ({
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, margin, searchTextField.my_height)];
	leftView.backgroundColor = [UIColor clearColor];
	leftView;
});
```
#####直接设置UITextView的placeholder
```objc
[self setValue:zd_placeHolderLabel forKey:@"_placeholderLabel"];
```
#####取消隐式动画
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
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.frameLayer.frame = self.frameView.bounds;
    
    [CATransaction commit];
}
```
#####去掉导航栏返回按钮的back标题
```objc
// 第一种方法:
[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

// 第二种方法:
@implementation UINavigationItem (backBarButttonItem)
- (UIBarButtonItem*)backBarButtonItem
{
    if ([UIDevice iOS_7])
    {
        return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
    else
    {
        return [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:NULL];
    }
}
```
#####调整barButtonItem之间的距离
```objc
UIImage *img = [[UIImage imageNamed:@"icon_cog"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//宽度为负数的固定间距的系统item
UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
[rightNegativeSpacer setWidth:-15];

UIBarButtonItem *rightBtnItem1 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
UIBarButtonItem *rightBtnItem2 = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonItemClicked:)];
self.navigationItem.rightBarButtonItems = @[rightNegativeSpacer,rightBtnItem1,rightBtnItem2];
```
#####从一个隐藏导航栏的 A 控制器 push 到一个有导航栏的 B 控制器中(导航栏隐藏问题)
在不显示导航栏的 A 控制器中遵守`UINavigationControllerDelegate`协议,实现其代理方法
```objc
#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    BOOL isShowBar = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowBar animated:YES];
}
```
#####禁止锁屏
```objc
[UIApplication sharedApplication].idleTimerDisabled = YES;
// 或
[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
```
#####退出应用
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
#####获取手机安装的应用
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
#####打开系统设置界面
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
#####动画暂停然后再开始
```objc
-(void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
```
#####iOS开发中的一些相关路径
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
#####查找所有block的正则表达式
[正则表达式检测](http://www.regexr.com/)
```regex
// 解释：以`^`开头，`{`和`换行符`结束，中间（`*`表示匹配0次或多次，`+`表示匹配一次或者多次）匹配任意字符，最后是换行符
\^.*\{\n     
```
####参考帖子：
>* [iOS小技巧总结](http://www.jianshu.com/p/4523eafb4cd4)

