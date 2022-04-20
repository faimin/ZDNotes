//
//  ViewController.m
//  MRC
//
//  Created by Zero.D.Saber on 2017/3/30.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self mrc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mrc {
    
    NSArray *arr = [NSArray arrayWithObject:@"hello"];
    
    NSLog(@" retainCount = %zd", arr.retainCount);
    
    //[arr autorelease];
    //[arr autorelease];
    
    // [NSArray arrayWithObject:@"hello"]对象由自动释放池管理，
    // 现在手动调用arr的release，相当于释放了非自己持有的对象
    //[arr release];
    
    NSLog(@" retainCount = %zd", arr.retainCount);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //调用一次autorelease的时候会crash在这，调用2次的时候都执行不到这里就crash了
        NSLog(@"%@", arr);
    });
}


@end
