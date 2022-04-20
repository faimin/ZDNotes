//
//  ViewController.m
//  ZDFrameBounds
//
//  Created by Zero.D.Saber on 2017/3/29.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UIView *zd_view1;
@property (strong, nonatomic) UIView *zd_view2;
@property (nonatomic, assign) BOOL isResume;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self frameBounds];
}

UIKIT_STATIC_INLINE void zd_printViewCoordinateInfo(UIView *view) {
    NSLog(@"\n frame = %@, bounds = %@, center = %@",
          NSStringFromCGRect(view.frame),
          NSStringFromCGRect(view.bounds),
          NSStringFromCGPoint(view.center)
    );
}

- (void)frameBounds {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    view1.backgroundColor = [UIColor redColor];
    [self.view addSubview:view1];
    self.zd_view1 = view1;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view2.backgroundColor = [UIColor yellowColor];
    [view1 addSubview:view2];
    self.zd_view2 = view2;
    
    zd_printViewCoordinateInfo(self.zd_view1);
    zd_printViewCoordinateInfo(self.zd_view2);
}

- (IBAction)changeBounds:(UIButton *)sender {
    if (self.isResume) {
        self.zd_view1.bounds = (CGRect){0, 0, 200, 200};
    }
    else {
        self.zd_view1.bounds = (CGRect){20, 20, 150, 150};
    }
    self.isResume = !self.isResume;
    
    zd_printViewCoordinateInfo(self.zd_view1);
    zd_printViewCoordinateInfo(self.zd_view2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
