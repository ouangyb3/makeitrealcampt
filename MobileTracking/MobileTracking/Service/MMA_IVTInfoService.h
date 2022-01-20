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
-(BOOL)isRoot;
/**剩余电量*/
-(double)Electricity;
/**是否充电*/
-(BOOL)isCharging;
/**是否模拟器*/
-(BOOL)isSimulator;
 /**距离*/
 -(BOOL)Proximity;
 
/**加速度值*/
@property(nonatomic,copy)NSString * Accelerometer;
/**陀螺仪值*/
@property(nonatomic,copy)NSString * GyroActive;
/**磁场值*/
@property(nonatomic,copy)NSString * Magnetometer;
/**重力值*/
@property(nonatomic,copy)NSString * DeviceMotion;
/**气压值*/
@property(nonatomic,copy)NSString * Pressure;
/**方向传感器*/
@property(nonatomic,copy)NSString * Direction;

/**光线强弱*/
@property(nonatomic,copy)NSString * Brightness;

-(void)updateSensorInfo:(void(^)())result;
/**距离上次刷新时间s*/
-(NSInteger )timeDifference;

//根据value排序
+(NSArray*)ArrayWithDict:(NSDictionary*)dict;
@end

 
