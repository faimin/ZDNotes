//
//  ViewController1.m
//  ZDProtocolCode
//
//  Created by Zero.D.Saber on 2017/4/16.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController1.h"
#import "VCBaseProtocol.h"

@interface ViewController1 () <VCBaseProtocol>

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self commonUIConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
