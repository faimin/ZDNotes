//
//  VCBaseProtocol.h
//  ZDProtocolCode
//
//  Created by 符现超 on 2017/4/15.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libextobjc/EXTConcreteProtocol.h>


@protocol VCBaseProtocol <NSObject>

@concrete
- (void)commonUIConfiguration;

@end
