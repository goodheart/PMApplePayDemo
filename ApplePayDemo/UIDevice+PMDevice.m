//
//  UIDevice+PMDevice.m
//  ApplePayDemo
//
//  Created by majian on 15/10/9.
//  Copyright © 2015年 majian. All rights reserved.
//

#import "UIDevice+PMDevice.h"

@implementation UIDevice (PMDevice)
#pragma mark - Public Method
- (BOOL)isBrokedDevice {
    BOOL isBrokedDevice = NO;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        isBrokedDevice = YES;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]) {
        isBrokedDevice = YES;
    }
    
    if (getenv("DYLD_INSERT_LIBRARIES")) {
        isBrokedDevice = YES;
    }
    
    return isBrokedDevice;
}
@end
