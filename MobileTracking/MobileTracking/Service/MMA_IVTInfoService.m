//
//  MMA_IVTInfoService.m
//  MobileTracking
//
//  Created by DeveWang on 2019/11/1.
//  Copyright © 2019 Admaster. All rights reserved.
//

#import "MMA_IVTInfoService.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import <UIKit/UIKit.h>
#import "MMA_Log.h"
#import "MMA_Macro.h"
#import <CoreLocation/CoreLocation.h>

#define SENSOR_LAST_TIME @"SENSOR_LAST_TIME"
#define SENSOR_UPDATE_TIME 0.1
/*--------------参数设置-----------------*/
@interface MMA_Argument : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) Boolean urlEncode;
@property (nonatomic, assign) Boolean isRequired;

@end

@interface MMA_IVTInfoService ()<AVCaptureVideoDataOutputSampleBufferDelegate,CLLocationManagerDelegate>

/**距离传感器是否可用*/
@property(nonatomic,assign)BOOL proximityMonitoringEnabled;
/**加速器是否可用*/
@property(nonatomic,assign)BOOL accelerationEnable;
/**陀螺仪是否可用*/
@property(nonatomic,assign)BOOL gyroEnable;
/**磁力器是否可用*/
@property(nonatomic,assign)BOOL magnetEnable;
/**摄像头亮度是否可用*/
@property(nonatomic,assign)BOOL CameraBrightnessEnable;

@property(nonatomic,assign)NSInteger lastTime;

@property(nonatomic,strong)NSMutableArray * brightnessAry;
@property(nonatomic,strong)NSMutableArray * directionAry;
/**光感检测*/
@property (nonatomic, strong) AVCaptureSession *session;
/**方向传感器*/
@property (nonatomic, strong) CLLocationManager *locationManager;

// 其他
@property (nonatomic, strong) CMMotionManager   *motionManage;
@property (nonatomic, strong) CMPedometer       *pedometer;
@property (nonatomic, strong) AVCaptureSession  *captureSession;
@property(nonatomic,strong) CMAltimeter *altimeter;

@property (nonatomic, strong) dispatch_source_t gcd_timer;

/**采集次数*/
@property(nonatomic,assign)NSInteger Count;




@end

@implementation MMA_IVTInfoService{
    
    
  __block  BOOL _updateing ;
    
    
}

+ (MMA_IVTInfoService *)sharedInstance {
   
    static MMA_IVTInfoService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.brightnessAry = [[NSMutableArray alloc]init];
        _sharedInstance.directionAry = [[NSMutableArray alloc]init];
        _sharedInstance.Count = SENSOR_COLLECT_TIME/SENSOR_UPDATE_TIME;
      //  [_sharedInstance checkEnable];
        
    });
    return _sharedInstance;
}

- (CMMotionManager *)motionManage {
    if (!_motionManage) {
        
        _motionManage = [[CMMotionManager alloc] init];
        // 控制传感器的更新间隔
        _motionManage.accelerometerUpdateInterval = SENSOR_UPDATE_TIME;
        _motionManage.gyroUpdateInterval = SENSOR_UPDATE_TIME;
        _motionManage.magnetometerUpdateInterval = SENSOR_UPDATE_TIME;
        _motionManage.deviceMotionUpdateInterval = SENSOR_UPDATE_TIME;
        
    }
    return _motionManage;
}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        
       _locationManager = [[CLLocationManager alloc] init];
           _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
           _locationManager.delegate = self;
           [_locationManager requestWhenInUseAuthorization];
        
    }
    return _locationManager;
}

- (AVCaptureSession *)session {
    if (!_session) {
        
        _session = [[AVCaptureSession alloc] init];
      
    }
    return _session;
}




// 检查设备的可用性
- (void)checkEnable{
    
    // 距离传感器
    // 当设置proximityMonitoringEnabled为YES后，属性值仍然为NO，说明传感器不可用。
 [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    self.proximityMonitoringEnabled  = [UIDevice currentDevice].proximityMonitoringEnabled;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
  
    // 加速计
    self.accelerationEnable = self.motionManage.isAccelerometerAvailable;
    
    // 陀螺仪
    self.gyroEnable = self.motionManage.isGyroAvailable;
    
    // 磁力计
    self.magnetEnable = self.motionManage.isMagnetometerAvailable;
    
    // 摄像头
    self.CameraBrightnessEnable = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    
}
-(void)updateSensorInfo:(void (^)())result{
    
    if ([self timeDifference]<SENSOR_UPDATE_INTERVAL||_updateing==YES) {
      [MMA_Log log:@"距离上次刷新间隔%lds,请稍等",[self timeDifference]];
        return;
    }
    [self performSelector:@selector(saveLastTime) withObject:nil afterDelay:2];
    _updateing = YES;
    
    [self.brightnessAry removeAllObjects];
    [self.directionAry removeAllObjects];
    
    //加速度
 __block   NSMutableArray *  Accelerometer = [[NSMutableArray alloc]init];
    //陀螺仪
 __block   NSMutableArray *  gyroActive = [[NSMutableArray alloc]init];
    //磁场
  __block  NSMutableArray *  Magnetometer = [[NSMutableArray alloc]init];
    //设备方向
  __block  NSMutableArray *  deviceMotion = [[NSMutableArray alloc]init];
  
  __weak typeof (self) weakSelf = self;
    
       [self.motionManage startGyroUpdates];
       [self.motionManage startDeviceMotionUpdates];
       [self.motionManage startAccelerometerUpdates];
       [self.motionManage startMagnetometerUpdates];
    
      NSDictionary *tempInfoDict = [[NSBundle mainBundle] infoDictionary];
 
    if (![tempInfoDict objectForKey:@"NSLocationWhenInUseUsageDescription"]&&[CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied)
      {
         self.Direction =nil;
          
      }else{
          [self.locationManager startUpdatingHeading];
      }
    
   


    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied||![tempInfoDict objectForKey:@"NSCameraUsageDescription"])
    {
        self.Brightness = nil;
        
    }else{
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
           AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
           
           AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
           [lightOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
           
           
           self.session.sessionPreset = AVCaptureSessionPresetLow;
           if ([self.session canAddInput:input]) {
               [self.session addInput:input];
           }
           if ([self.session canAddOutput:lightOutput]) {
               [self.session addOutput:lightOutput];
           }
            [self.session startRunning];
        
    }
    
   
    
  __block  NSInteger i = 0;
    NSTimeInterval start = 0.1;//开始时间
       NSTimeInterval interval = SENSOR_UPDATE_TIME;//时间间隔
       dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
       dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
       dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
       dispatch_source_set_event_handler(timer, ^{
         
           [ Accelerometer addObject:  @{@"x":@(weakSelf.motionManage.accelerometerData.acceleration.x),
               @"y":@(weakSelf.motionManage.accelerometerData.acceleration.y),
               @"z":@(weakSelf.motionManage.accelerometerData.acceleration.z)
          }  ];
           [ gyroActive addObject:@{@"x":@(weakSelf.motionManage.gyroData.rotationRate.x),@"y":@(weakSelf.motionManage.gyroData.rotationRate.y),@"z":@(weakSelf.motionManage.gyroData.rotationRate.z)}  ];
           [ Magnetometer addObject:@{@"x":@(weakSelf.motionManage.magnetometerData.magneticField.x),@"y":@(weakSelf.motionManage.magnetometerData.magneticField.y),@"z":@(weakSelf.motionManage.magnetometerData.magneticField.z)} ];
           
           [ deviceMotion addObject:@{@"yaw":@(weakSelf.motionManage.deviceMotion.attitude.yaw),@"pitch":@( weakSelf.motionManage.deviceMotion.attitude.pitch),@"roll":@(weakSelf.motionManage.deviceMotion.attitude.roll)}];
           
           i++;
           if (i==_Count) {
                        weakSelf.Accelerometer =  Accelerometer;
                         weakSelf.GyroActive = gyroActive;
                          weakSelf.Magnetometer = Magnetometer;
                          weakSelf.DeviceMotion = deviceMotion;
                   
                          
                        _updateing = NO;
                        dispatch_source_cancel(self.gcd_timer);
                    }
   
       });
       self.gcd_timer = timer;
       dispatch_resume(self.gcd_timer);
    
    
 
    //启用气压计

   self.altimeter = [[CMAltimeter alloc]init];

 
 

      [self.altimeter startRelativeAltitudeUpdatesToQueue:NSOperationQueue.mainQueue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {

          [MMA_Log log:@"气压：%lf",[altitudeData.pressure floatValue]];
          weakSelf.Pressure =[NSString stringWithFormat:@"%lf",[altitudeData.pressure floatValue]];
          
             [weakSelf.altimeter stopRelativeAltitudeUpdates];
          
          
          
          _updateing = NO;
      
           if (result) {
              result();
          }
     
         

      }];
    
  
 

}
 #pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

 - (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
     static BOOL isWaiting = NO;
      static NSInteger count = 0;
     
     if (isWaiting) {
             return;
         }
         isWaiting = YES;
     
     CFDictionaryRef metadataDicRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
     NSDictionary *metadataDic = (__bridge NSDictionary *)metadataDicRef;
     CFRelease(metadataDicRef);
     NSDictionary *exifDic = metadataDic[(__bridge NSString *)kCGImagePropertyExifDictionary];
     CGFloat brightness = [exifDic[(__bridge NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
     
    
     
    
     
     __weak typeof (self) WeakSelf = self;
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SENSOR_UPDATE_TIME * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        
         [WeakSelf.brightnessAry addObject:[NSString stringWithFormat:@"%f", brightness]];
         
         
            isWaiting = NO;
               count++;
         if (count==_Count) {
             _Brightness = WeakSelf.brightnessAry;
                     [self.session stopRunning];
               _updateing = NO;
                 }
        });
 }
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
        static BOOL isWaiting = NO;
         static NSInteger count = 0;
        
        if (isWaiting) {
                return;
            }
            isWaiting = YES;
    
  
    
     
    
    __weak typeof (self) WeakSelf = self;
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SENSOR_UPDATE_TIME * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
          
           NSDictionary *newHeadingDic =@{@"trueHeading":@(newHeading.trueHeading),@"magneticHeading":@(newHeading.magneticHeading),@"headingAccuracy":@(newHeading.headingAccuracy),@"x":@(newHeading.x),@"y":@(newHeading.y),@"z":@(newHeading.z)} ;
           
        
           
           [WeakSelf.directionAry addObject:newHeadingDic];
           
           
              isWaiting = NO;
                 count++;
           if (count==_Count) {
                self.Direction = WeakSelf.directionAry;
                      [manager stopUpdatingHeading];
                 _updateing = NO;
                   }
          });
    
   
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
-(double)Electricity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    return deviceLevel;
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
 /**距离*/
-(BOOL)Proximity{
    
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    BOOL ret = ([UIDevice currentDevice].proximityState) ;
    
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    return ret;
    
    
}





-(NSInteger)timeDifference{
    if (!self.lastTime) {
        
        self.lastTime = [[[NSUserDefaults standardUserDefaults] objectForKey:SENSOR_LAST_TIME] integerValue];
    }
 
    
    
     NSInteger nowTime =  [[NSDate date]  timeIntervalSince1970];
    
    
  NSInteger timeDiff =  nowTime - self.lastTime;
    
  //  [MMA_Log log:@"相差 === %ld =====秒",(long)timeDiff];
    
    return timeDiff;
    
    
}

/**ary转字符串*/
-(NSString*)stringWithAry:(NSArray*)ary{
    
    
    NSString*str =@"";
    
    for(NSString*string in ary) {
        
       
    
        
        if([str length] !=0) {
            
            str = [str stringByAppendingString:@"/"];
            
        }
        
        str = [str stringByAppendingFormat:@"%@",string];
        
    }
    
    str = [NSString stringWithFormat:@"[%@]",str];
   
    return str;

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
