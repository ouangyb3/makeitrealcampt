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

#import <sys/sysctl.h>
#import <UIKit/UIDevice.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CommonCrypto/CommonDigest.h>


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
#pragma mark 新增参数8月28日 e1-e8
//e1
-(NSString *)deviveName{
    @try {
        
        NSString *name = [NSString stringWithFormat:@"%@",[UIDevice
                                                           currentDevice].name];
        
        return  name;
        
    } @catch (NSException *exception) {
        return @"-";
    }
    
}
//e2
- (NSString *)hwModel{
    @try {
        
        size_t size;
        sysctlbyname("hw.model", NULL, &size, NULL, 0);
        char *answer = malloc(size);
        sysctlbyname("hw.model", answer, &size, NULL, 0);
        NSString *results = [NSString stringWithUTF8String:answer];
        free(answer);
        return results;
        
    } @catch (NSException *exception) {
        return @"-";
    }
    
}
//3
- (NSString *)carrier{
    @try {
#if TARGET_IPHONE_SIMULATOR
        return @"simulator";
#else
        static dispatch_queue_t _queue;
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            _queue = dispatch_queue_create([[NSString stringWithFormat:@"com.carr.%@", self] UTF8String], NULL);
        });
        __block NSString *  carr = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(_queue, ^(){
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init]; CTCarrier *carrier = nil;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.1) {
                if ([info
                     respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
                    NSArray *carrierKeysArray = [info.serviceSubscriberCellularProviders.allKeys
                                                 sortedArrayUsingSelector:@selector(compare:)];
                    carrier =
                    info.serviceSubscriberCellularProviders[carrierKeysArray.firstObject]; if (!carrier.mobileNetworkCode) {
                        carrier = info.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
                    }
#pragma clang diagnostic pop
                } }
            if(!carrier) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                carrier = info.subscriberCellularProvider;
#pragma clang diagnostic pop
            }
            if (carrier != nil) {
//                NSString *networkCode = [carrier mobileNetworkCode];
//                NSString *countryCode = [carrier mobileCountryCode];
//                if (countryCode && [countryCode isEqualToString:@"460"] &&
//                    networkCode) {
//                    if ([networkCode isEqualToString:@"00"] || [networkCode
//                                                                isEqualToString:@"02"] || [networkCode isEqualToString:@"07"] || [networkCode
//                                                                                                                                  isEqualToString:@"08"]) {
//                        carr= @"中国移动"; }
//                    if ([networkCode isEqualToString:@"01"] || [networkCode
//                                                                isEqualToString:@"06"] || [networkCode isEqualToString:@"09"]) {
//                        carr= @"中国联通"; }
//                    if ([networkCode isEqualToString:@"03"] || [networkCode
//                                                                isEqualToString:@"05"] || [networkCode isEqualToString:@"11"]) {
//                        carr= @"中国电信"; }
//                    if ([networkCode isEqualToString:@"04"]) { carr= @"中国卫通";
//                    }
//                    if ([networkCode isEqualToString:@"20"]) {
//                        carr= @"中国铁通"; }
//                }else {
                    carr = [carrier.carrierName copy];
          }
            if (carr.length <= 0) { carr = @"unknown";
            }
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, 0.5* NSEC_PER_SEC); dispatch_semaphore_wait(semaphore, t);
        return [carr copy];
        
#endif
        
    } @catch (NSException *exception) {
        return @"-";
    }
    
}
//e4
- (NSString *)fileSystemSize{
    
    @try {
        int64_t space = -1;
        NSError *error = nil;
        NSDictionary *attrs = [[NSFileManager defaultManager]
                               attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
        if (!error) {
            space = [[attrs objectForKey:NSFileSystemSize] longLongValue];
        }
        if(space < 0) { space = -1;
        }
        return [NSString stringWithFormat:@"%lld",space];
        
    } @catch (NSException *exception) {
        return @"-";
    }
}
//e5
- (NSString *)systemBootTime{
    
    @try {
        struct timeval boottime;
        int mib[2] = {CTL_KERN, KERN_BOOTTIME};
        size_t size = sizeof(boottime);
        time_t uptime = -1;
        if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
            uptime = boottime.tv_sec; }
        NSString *result = [NSString stringWithFormat:@"%ld",uptime];
        return result;
        
    } @catch (NSException *exception) {
        return @"-";
    }
}
//e6
- (NSString *)systemUpdateTime{
    
    @try {
        NSString *result = nil;
        NSString *information =
        @"L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0";
        NSData *data=[[NSData alloc]initWithBase64EncodedString:information
                                                        options:0];
        NSString *dataString = [[NSString alloc]initWithData:data
                                                    encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:dataString error:&error];
        if (fileAttributes) {
            id singleAttibute = [fileAttributes objectForKey:NSFileCreationDate];
            if ([singleAttibute isKindOfClass:[NSDate class]]) {
                NSDate *dataDate = singleAttibute;
                result = [NSString stringWithFormat:@"%f",[dataDate
                                                           timeIntervalSince1970]];
            } }
        return result;
    } @catch (NSException *exception) {
        return  @"-";
    }
}
//e7
- (NSString *)language{
    
    @try {
        NSString *language;
        NSLocale *locale = [NSLocale currentLocale];
        if ([[NSLocale preferredLanguages] count] > 0) {
            language = [[NSLocale preferredLanguages]objectAtIndex:0];
        } else {
            language = [locale objectForKey:NSLocaleLanguageCode];
        }
        
        return language;
    } @catch (NSException *exception) {
        return @"-";
    }
}
//e8
- (NSString *)countryCode{
    
    @try {
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
        return countryCode;
    } @catch (NSException *exception) {
        return  @"-";
    }  
}
@end
