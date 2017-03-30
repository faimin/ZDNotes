//
//  PropertyController.m
//  ZDFrameBounds
//
//  Created by 符现超 on 2017/3/30.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "PropertyController.h"

@interface PropertyController ()
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSString *strongName;

@property (nonatomic, copy) NSString *copyyName;
@end

@implementation PropertyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self test];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test {
    NSLog(@"\n\n");
    
    NSString *string = @"name";
    self.name = string;
    NSLog(@"\n%@, %p", self.name, &_name);
    
    string = @"age";
    NSLog(@"\n%@, %p", self.name, &_name);
    
    
    NSString *str = [NSString stringWithFormat:@"AWEGIOJGiowmeoi"];
    self.strongName = str;
    self.copyyName = str;
    NSLog(@"origin string: %p, %p, %@",str, &str, str);
    
    str = @"惺惺惜惺惺想";
    NSLog(@"strong string: %p, %p, %@",self.strongName, &_strongName, _strongName);
    NSLog(@"copy string: %p, %p, %@", _copyyName, &_copyyName, _copyyName);
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
