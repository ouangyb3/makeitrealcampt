//
//  MMA_IVTInfoService.m
//  MobileTracking
//
//  Created by DeveWang on 2019/11/1.
//  Copyright © 2019 Admaster. All rights reserved.
//

#import "MMA_IVTInfoService.h"
 
#import <AVFoundation/AVFoundation.h>
 
#import <UIKit/UIKit.h>
#import "MMA_Log.h"
#import "MMA_Macro.h"
 

#define SENSOR_LAST_TIME @"SENSOR_LAST_TIME"
#define SENSOR_UPDATE_TIME 0.1
/*--------------参数设置-----------------*/
@interface MMA_Argument : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) Boolean urlEncode;
@property (nonatomic, assign) Boolean isRequired;

@end

@interface MMA_IVTInfoService ()

 

@property(nonatomic,assign)NSInteger lastTime;

 
@property (nonatomic, strong) dispatch_source_t gcd_timer;
 




@end

@implementation MMA_IVTInfoService{
    
    
  __block  BOOL _updateing ;
    
    
}

+ (MMA_IVTInfoService *)sharedInstance {
   
    static MMA_IVTInfoService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
//        _sharedInstance.brightnessAry = [[NSMutableArray alloc]init];
//        _sharedInstance.directionAry = [[NSMutableArray alloc]init];
//
    //  [_sharedInstance checkEnable];
        
    });
    return _sharedInstance;
}

 
 


 
-(void)updateSensorInfo:(void (^)())result{
    
    if ([self timeDifference]<SENSOR_UPDATE_INTERVAL) {
      [MMA_Log log:@"距离上次刷新间隔%lds,请稍等",[self timeDifference]];
        return;
    }
   
  
    
  
 

}
 
-(BOOL)iSupdate{
    if ([self timeDifference]>=SENSOR_UPDATE_INTERVAL) {

        return YES;
    }else{
      [MMA_Log log:@"距离上次刷新间隔%lds,请稍等",[self timeDifference]];
        return NO;
    }
     
    
}
     
    
      
    
     
    
    

/**是否越狱*/
-(BOOL)isRoot{
    BOOL root = NO;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *pathArray = @[@"/etc/ssh/sshd_config",
                           @"/usr/libexec/ssh-keysign",
                           @"/usr/sbin/sshd",
                           @"/usr/sbin/sshd",
                           @"/bin/sh",
                           @"/bin/bash",
                           @"/etc/apt",
                           @"/Application/Cydia.app/",
                           @"/Library/MobileSubstrate/MobileSubstrate.dylib"
                           ];
    for (NSString *path in pathArray) {
        root = [fileManager fileExistsAtPath:path];
      // 如果存在这些目录，就是已经越狱
        if (root) {
            
            return root;
          break;
        }
    }
    
    return root;
}
/**剩余电量*/
-(NSString *)Electricity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    NSString * deviceLevelStr;
    if (deviceLevel <0||deviceLevel>1) {
        deviceLevelStr = @"-";
    }else{
        deviceLevelStr  = [NSString stringWithFormat:@"%f",deviceLevel];
    }
    return deviceLevelStr;
}
/**是否充电*/
-(BOOL)isCharging{
    
     UIDevice *Device = [UIDevice currentDevice];
            // Set battery monitoring on
            Device.batteryMonitoringEnabled = YES;
            
            // Check the battery state
            if ([Device batteryState] == UIDeviceBatteryStateCharging || [Device batteryState] == UIDeviceBatteryStateFull) {
                // Device is charging
                return true;
            } else {
                // Device is not charging
                return false;
            }
    
 
    
}
/**是否模拟器*/
-(BOOL)isSimulator{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        return YES;
    }else{
        //真机
        return NO;
    }

    
    
}
 
 





-(NSInteger)timeDifference{
    if (!self.lastTime) {
        
        self.lastTime = [[[NSUserDefaults standardUserDefaults] objectForKey:SENSOR_LAST_TIME] integerValue];
    }
 
    
    
     NSInteger nowTime =  [[NSDate date]  timeIntervalSince1970];
    
    
  NSInteger timeDiff =  nowTime - self.lastTime;
    
 // [MMA_Log log:@"相差 === %ld =====秒",(long)timeDiff];
    
    return timeDiff;
    
    
}

/**ary转字符串*/
-(NSString*)stringWithAry:(NSArray*)ary{
    
    @try {
           NSString*str =@"";
         
         for(NSString*string in ary) {
             
            
         
             
             if([str length] !=0) {
                 
                 str = [str stringByAppendingString:@","];
                 
             }
             
             str = [str stringByAppendingFormat:@"%@",string];
             
         }
         
         str = [NSString stringWithFormat:@"[%@]",str];
        
         return str;
    } @catch (NSException *exception) {
         
    } @finally {
         
    }
 

}

/**字典根据value进行排序*/
+(NSArray*)ArrayWithDict:(NSDictionary*)dict{
    
    NSArray*keys = [dict allValues];
  
    
    NSArray*sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        MMA_Argument * o1 = obj1;
        MMA_Argument * o2 = obj2;
        NSString * v1 = o1.value ;
          NSString * v2 = o2.value;;
//               if (v1 < v2)
//                   return NSOrderedAscending;
//               else if (v1 > v2)
//                   return NSOrderedDescending;
//               else
//                   return NSOrderedSame;
        return[v1 compare:v2 options:64];//正序
    }];
    
  

    return sortedArray;

}
/**字典根据value进行排序2*/
+(NSArray*)ArrayWithDict2:(NSDictionary*)dict{
    
    NSArray*keys = [dict allKeys];
  
    
    NSArray*sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
      
 
//               if (v1 < v2)
//                   return NSOrderedAscending;
//               else if (v1 > v2)
//                   return NSOrderedDescending;
//               else
//                   return NSOrderedSame;
        return[obj1 compare:obj2 options:64];//正序
    }];
    
  NSMutableArray *valueArray = [NSMutableArray array];
     for(NSString *sortSring in sortedArray){
         NSString *signSring = [NSString stringWithFormat:@"%@=%@",sortSring,[dict objectForKey:sortSring]];
         [valueArray addObject:signSring];
     }
     

    return valueArray;

}
-(void)saveLastTime{
    
    self.lastTime = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults  standardUserDefaults] setInteger: self.lastTime forKey:SENSOR_LAST_TIME];
    
}

@end
