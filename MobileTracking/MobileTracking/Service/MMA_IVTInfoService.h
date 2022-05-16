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
-(NSString *)Electricity;
/**是否充电*/
-(BOOL)isCharging;
/**是否模拟器*/
-(BOOL)isSimulator;
 

-(void)updateSensorInfo:(void(^)())result;
/**距离上次刷新时间s*/
-(NSInteger )timeDifference;
/**存储当前时间*/
-(void)saveLastTime;

-(BOOL)iSupdate;

//根据value排序
+(NSArray*)ArrayWithDict:(NSDictionary*)dict;
//根据value排序2
+(NSArray*)ArrayWithDict2:(NSDictionary*)dict;


@end

 
