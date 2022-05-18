//
//  MMA_Macro.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#ifndef MobileTracking_Macro_h
#define MobileTracking_Macro_h

#define MMA_SDK_VERSION @"V2.1.6"

#define NOTIFICATION_VB @"viewability_notification"
#define NOTIFICATION_EXPOSE @"expose_notification"
#define NOTIFICATION_SUCCEED @"send_succeed_notification"

#define SDK_CONFIG_DATA_FILE_NAME @"SDK_CONFIG_DATA_KEY"


#define SEND_QUEUE_IDENTITY @"SEND_QUEUE_IDENTITY"
#define FAILED_QUEUE_IDENTITY @"FAILED_QUEUE_IDENTITY"
#define FAILED_QUEUE_TRY_SEND_COUNT 3

#define SDK_CONFIG_FILE_NAME @"sdkconfig"
#define SDK_CONFIG_FILE_EXT @"xml"
#define SDK_CONFIG_DATA_FILE_NAME @"SDK_CONFIG_DATA_KEY"
#define SDK_CONFIG_DATA_PATH [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/%@",SDK_CONFIG_DATA_FILE_NAME]]

#define SDK_CONFIG_LAST_UPDATE_KEY @"SDK_CONFIG_LAST_UPDATE_KEY"

#define DEFAULT_FAILED_QUEUE_TIMER_INTERVAL (1 * 30)
#define DEFAULT_SEND_QUEUE_TIMER_INTERVAL (1 * 10)
#define UPDATE_SDK_CONFIG_WIFI_INTERVAL (1 * 24 * 60 * 60)
#define UPDATE_SDK_CONFIG_3G_INTERVAL (3 * 24 * 60 * 60)
#define LOCATION_UPDATE_INTERVAL 120 //定位刷新间隔 单位:秒
#define SENSOR_UPDATE_INTERVAL 0 //传感器刷新间隔 单位:秒


#define NETWORK_STATUS_WIFI 1
#define NETWORK_STATUS_3G   0
#define NETWORK_STATUS_NO   2

#define TRACKING_KEY_OS         @"OS"
#define TRACKING_KEY_MAC        @"MAC"
#define TRACKING_KEY_IDFA       @"IDFA"

#define TRACKING_KEY_IDFAMD5    @"IDFAMD5"

#define TRACKING_KEY_OPENUDID   @"OPENUDID"
#define TRACKING_KEY_TS         @"TS"
#define TRACKING_KEY_LBS        @"LBS"
#define TRACKING_KEY_OSVS       @"OSVS"
#define TRACKING_KEY_TERM       @"TERM"
#define TRACKING_KEY_WIFI       @"WIFI"
#define TRACKING_KEY_WIFISSID   @"WIFISSID"
#define TRACKING_KEY_WIFIBSSID   @"WIFIBSSID"
#define TRACKING_KEY_SCWH       @"SCWH"
#define TRACKING_KEY_ADWH       @"ADWH"
#define TRACKING_KEY_AKEY       @"AKEY"
#define TRACKING_KEY_ANAME      @"ANAME"
#define TRACKING_KEY_SDKVS      @"SDKVS"
#define TRACKING_KEY_SIGN       @"SIGN"

#define AD_PLACEMENT @"Adplacement"  // impression 解析占位符

#define AD_MEASURABILITY @"AdMeasurability" //当前广告是否可测量：0 为广告可测量，1 为广告不可测量
#define AD_VB @"Adviewability" // 	当前广告是否可见：0 为广告不可见，1 为广告可见
#define AD_VB_RESULT @"AdviewabilityResult" // 当前广告监测结果类型：0 进行了可见监测 1 结果可见 2 不可测量 4 结果不可见
#define AD_VB_FORGROUND @"AdviewabilityForground"
#define AD_VB_LIGHT @"AdviewabilityLight" //当前屏幕是否点亮，1代表完全点亮，0代表完全暗
#define AD_VB_SHOWFRAME @"AdviewabilityShowFrame"  //当前广告实际在屏幕中的显示尺寸
#define AD_VB_COVER_RATE  @"AdviewabilityCoverRate" //当前广告实际在屏幕中的覆盖率
#define AD_VB_SHOWN @"AdviewabilityShown"
#define AD_VB_ALPHA @"AdviewabilityAlpha"
#define AD_VB_POINT @"AdviewabilityPoint"
#define AD_VB_FRAME @"AdviewabilityFrame"  // 广告原始frame
#define AD_VB_TIME  @"AdviewabilityTime"
#define AD_VB_EVENTS @"AdviewabilityEvents"
#define IMPRESSIONID @"ImpressionID"
#define IMPRESSIONTYPE @"ImpressionType"  //普通曝光的类型
#define AD_VB_INTERACT @"AdviewabilityStrongInteract"

//#define AD_VB_ENABLE @"AdviewabilityEnable" //是否开启 ViewAbility 监测

//配置读取占位符
#define AD_VB_AREA @"AdviewabilityConfigArea" //满足条件可见比例%
#define AD_VB_THRESHOLD @"AdviewabilityConfigThreshold" //满足可视时长(s)
#define AD_VB_VIDEODURATION @"AdviewabilityVideoDuration" //可视视频播放时长 (s)
#define AD_VB_VIDEOPOINT @"AdviewabilityVideoProgressPoint" // 配置监测点 1111 全部监测 1100 监测1/4 1/2
#define AD_VB_RECORD @"AdviewabilityRecord" //可视轨迹数据是否上报

#define AD_VB_VIDEOPLAYTYPE @"AdviewabilityVideoPlayType" //可视监测传入的视频播放类型
#define AD_VB_VIDEOPROGRESS @"AdviewabilityVideoProgress" //可视视频播放进度监测事件类型字段 (string)播放 1/4：25 播放 1/2：50播放 3/4：75 播放完成：100
 
 
                    
                           
                           
                         
                              
                     
                            
/**IVT参数*/
/**是否越狱*/
#define  IVT_isRoot @"isRoot"
/**剩余电量*/
#define  IVT_electricity @"electricity"
/**是否充电*/
#define  IVT_isCharging @"isCharging"
/**是否模拟器*/
#define  IVT_isSimulator @"isSimulator"
/**是否hook*/
#define  IVT_isHook @"isHook"
/**是否刷机*/
#define  IVT_isFlash @"isFlash"
/**加速度*/
#define  IVT_Accelerometer @"Accelerometer"
/**磁场*/
#define  IVT_Magnetometer @"Magnetometer"
/**方向*/
#define  IVT_direction @"direction"
/**陀螺仪*/
#define  IVT_gyroActive @"gyroActive"
/**光线*/
#define  IVT_brightness @"brightness"
/**气压*/
#define  IVT_pressure @"pressure"
/**温度*/
#define  IVT_temperature @"temperature"
/**距离*/
#define  IVT_proximity @"proximity"
/**重力*/
#define  IVT_deviceMotion  @"deviceMotion"
/**线性加速度*/
#define  IVT_lineAccelerometer @"lineAccelerometer"
/**旋转矢量*/
#define  IVT_RotationVector @"RotationVector"

#define IVT_ARRAY @[IVT_isRoot,IVT_electricity,IVT_isCharging,IVT_isSimulator,IVT_isHook,IVT_isFlash,IVT_Accelerometer,IVT_Magnetometer,IVT_direction,IVT_gyroActive,IVT_brightness,IVT_pressure,IVT_temperature,IVT_proximity,IVT_deviceMotion,IVT_lineAccelerometer,IVT_RotationVector]
 
//switch
#define AD_VB_POLICY @"viewabilityTrackPolicy"  //可视化监测采集策略


//FOR JS
#define AD_VBJS_ID @"AdviewabilityID"
#define AD_VBJS_TYPE @"AdviewabilityType"




#define VIEW_ABILITY_KEY @[  \
AD_MEASURABILITY,  \
AD_VB, \
AD_VB_RESULT, \
AD_VB_FORGROUND, \
AD_VB_LIGHT, \
AD_VB_SHOWFRAME, \
AD_VB_COVER_RATE, \
AD_VB_SHOWN, \
AD_VB_ALPHA, \
AD_VB_POINT, \
AD_VB_FRAME, \
AD_VB_TIME, \
AD_VB_EVENTS, \
IMPRESSIONID, \
AD_VB_VIDEOPLAYTYPE, \
AD_VB_VIDEOPROGRESS, \
AD_VB_INTERACT \
]
//AD_VB_AREA, \
//AD_VB_THRESHOLD, \
//AD_VB_ENABLE, \
//AD_VB_VIDEODURATION, \
//AD_VB_VIDEOPROGRESS, \
//AD_VB_VIDEOPOINT, \
//AD_VB_RECORD, \
//AD_VB_VIDEOPLAYTYPE, \
]

#define VIEW_ABILITY_MAIN_KEY @[  \
AD_MEASURABILITY,  \
AD_VB, \
AD_VB_RESULT, \
AD_VB_EVENTS, \
IMPRESSIONID \
]




#define TRACKING_KEY_REDIRECTURL       @"REDIRECTURL"

#define TRACKING_KEY_OS_VALUE   1

#define IOSV [[[UIDevice currentDevice] systemVersion] floatValue]

#define IOS7 7.0

#define IOS6 6.0

#endif
