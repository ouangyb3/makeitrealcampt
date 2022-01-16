//
//  MMA_IVTInfoService.h
//  MobileTracking
//
//  Created by DeveWang on 2019/11/1.
//  Copyright © 2019 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>

 

@interface MMA_IVTInfoService : NSObject
+ (MMA_IVTInfoService *)sharedInstance;

/**是否越狱*/
+(BOOL)isRoot;
/**剩余电量*/
+(double)electricity;
/**是否充电*/
+(BOOL)isCharging;
/**是否模拟器*/
+(BOOL)isSimulator;
/**加速度传感器*/
-(void)getSensorInfo:(void(^)(NSString *l7,NSString*l8,NSString * l9,NSString *l10,NSString *l11,NSString *l12))info;

@end

 
