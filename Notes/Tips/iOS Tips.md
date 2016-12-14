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
#####判断当前viewController是push进来的还是present进来的
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
#####修改UItextField中placeholder的文字颜色
```objc
[textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
```
#####UITextField 光标右移
```objc
// 创建一个 leftView
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
#####动态调整 UITextView 的高度
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
#####动画暂停然后再开始
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
#####Autolayout动画
```objc
[containerView setNeedsLayout];
[UIView animateWithDuration:1.0 animations:^{
  // Make all constraint changes here
  [containerView layoutIfNeeded];
}];
```
#####去掉导航栏返回按钮的back标题
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
#####解决自定义返回按钮导致手势返回失败的问题
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
#####全屏手势返回
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
#####从一个隐藏导航栏的 A 控制器 push 到一个有导航栏的 B 控制器中(导航栏隐藏问题)
> 在不显示导航栏的 A 控制器中遵守`UINavigationControllerDelegate`协议,实现其代理方法

```objc
#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isShowBar = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowBar animated:YES];
}
```
#####本地推送
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
#####匹配block的正则表达式
[正则表达式检测](http://www.regexr.com/)
```regex
// 解释：以`^`开头，`{`和`换行符`结束，中间（`*`表示匹配0次或多次，`+`表示匹配一次或者多次）匹配任意字符，最后是换行符
\^.*\{\n     
```
#####iOS 常用数学函数
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
　　
####参考帖子：
>* [iOS小技巧总结](http://www.jianshu.com/p/4523eafb4cd4)

