//
//  VADeviceMessage.h
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VADeviceMessage : NSObject
+ (void)start;
+ (NSDictionary *)deviceMessage:(BOOL)trackLocation;

@end
