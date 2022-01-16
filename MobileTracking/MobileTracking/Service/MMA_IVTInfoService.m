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

@interface MMA_IVTInfoService ()<AVCaptureVideoDataOutputSampleBufferDelegate>

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

// 其他
@property (nonatomic, strong) CMMotionManager   *motionManage;
@property (nonatomic, strong) CMPedometer       *pedometer;
@property (nonatomic, strong) AVCaptureSession  *captureSession;

@end

@implementation MMA_IVTInfoService

+ (MMA_IVTInfoService *)sharedInstance {
    
    static MMA_IVTInfoService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance checkEnable];
        
    });
    return _sharedInstance;
}

- (CMMotionManager *)motionManage {
    if (!_motionManage) {
        
        _motionManage = [[CMMotionManager alloc] init];
        // 控制传感器的更新间隔
        _motionManage.accelerometerUpdateInterval = 0.1;
        _motionManage.gyroUpdateInterval = 0.1;
        _motionManage.magnetometerUpdateInterval = 0.1;
    }
    return _motionManage;
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
-(void)getSensorInfo:(void (^)(NSString * _Nonnull, NSString * _Nonnull, NSString * _Nonnull, NSString * _Nonnull, NSString * _Nonnull, NSString * _Nonnull))info{
    
    
    // 可用性检测
           if(![self.motionManage isAccelerometerAvailable]){
              
               return;
           }
           
 
           
  
           __weak typeof (self) weakSelf = self;
           [self.motionManage startAccelerometerUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
               // 回到主线程
              
                   if (info) {
                           info( [NSString stringWithFormat:@"%f", accelerometerData.acceleration.x], [NSString stringWithFormat:@"%f", accelerometerData.acceleration.y], [NSString stringWithFormat:@"%f", accelerometerData.acceleration.z],@"4",@"5",@"6");
                     }
               
                 
                   
                   
                
          
           }];
    
  
 

}
@end
