//
//  ViewController.m
//  ZDFrameBounds
//
//  Created by 符现超 on 2017/3/29.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UIView *zd_view;
@property (nonatomic, assign) BOOL isResume;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    view1.backgroundColor = [UIColor redColor];
    [self.view addSubview:view1];
    self.zd_view = view1;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view2.backgroundColor = [UIColor yellowColor];
    [view1 addSubview:view2];
}

- (IBAction)changeBounds:(UIButton *)sender {
    if (self.isResume) {
        self.zd_view.bounds = (CGRect){0, 0, 200, 200};
    }
    else {
        self.zd_view.bounds = (CGRect){20, 20, 200, 200};
    }
    self.isResume = !self.isResume;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
