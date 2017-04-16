//
//  VCBaseProtocol.m
//  ZDProtocolCode
//
//  Created by 符现超 on 2017/4/15.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "VCBaseProtocol.h"

@concreteprotocol(VCBaseProtocol)
- (void)commonUIConfiguration {
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (id)self;
        vc.view.backgroundColor = [UIColor redColor];
    }
}
@end



/*

 BOOL ext_addConcreteProtocol (Protocol *protocol, Class methodContainer);
 void ext_loadConcreteProtocol (Protocol *protocol);
 
 
 @protocol VCBaseProtocol <NSObject>
 
 @optional
 - (void)commonUIConfiguration:(UIViewController *)vc;
 
 @end
 
 
 @interface VCBaseProtocol_ProtocolMethodContainer : NSObject < VCBaseProtocol >
 {
 
 }
 @end
 
 
 @implementation VCBaseProtocol_ProtocolMethodContainer
 
 + (void)load {
	if (!ext_addConcreteProtocol(objc_getProtocol("VCBaseProtocol"), self))
 fprintf(__stderrp, "ERROR: Could not load concrete protocol %s\n", "VCBaseProtocol");
 }
 
 __attribute__((constructor)) static void ext_VCBaseProtocol_inject (void) {
	ext_loadConcreteProtocol(objc_getProtocol("VCBaseProtocol"));
 }
 
 - (void)commonUIConfiguration:(UIViewController *)vc {
 vc.view.backgroundColor = [UIColor redColor];
 }
 
 @end
 
*/
