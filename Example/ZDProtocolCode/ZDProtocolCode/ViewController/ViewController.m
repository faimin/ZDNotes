//
//  ViewController.m
//  ZDProtocolCode
//
//  Created by 符现超 on 2017/4/15.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "VCBaseProtocol.h"

@interface ViewController () <VCBaseProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self commonUIConfiguration];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
