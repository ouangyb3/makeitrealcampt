//
//  MMA_Macro.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#ifndef MobileTracking_Macro_h
#define MobileTracking_Macro_h

#define MMA_SDK_VERSION @"V2.0.0" 

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
#define TRACKING_KEY_SCWH       @"SCWH"
#define TRACKING_KEY_ADWH       @"ADWH"
#define TRACKING_KEY_AKEY       @"AKEY"
#define TRACKING_KEY_ANAME      @"ANAME"
#define TRACKING_KEY_SDKVS      @"SDKVS"
#define TRACKING_KEY_SIGN       @"SIGN"

#define AD_PLACEMENT @"Adplacement"  // impression 解析占位符

#define AD_MEASURABILITY @"AdMeasurability" //当前广告是否可测量：0 为广告可测量，1 为广告不可测量
#define AD_VB @"Adviewability" // 	当前广告是否可见：0 为广告不可见，1 为广告可见
#define AD_VB_FORGROUND @"AdviewabilityForground"
#define AD_VB_LIGHT @"AdviewabilityLight" //当前屏幕是否点亮，1代表完全点亮，0代表完全暗
#define AD_VB_SHOWFRAME @"AdviewabilityShowFrame"  //当前广告实际在屏幕中的显示尺寸
#define AD_VB_COVER_RATE  @"AdviewabilityCoverRate" //当前广告实际在屏幕中的覆盖率
#define AD_VB_HIDE @"AdviewabilityHide"
#define AD_VB_ALPHA @"AdviewabilityAlpha"
#define AD_VB_POINT @"AdviewabilityPoint"
#define AD_VB_FRAME @"AdviewabilityFrame"  // 广告原始frame
#define AD_VB_TIME  @"AdviewabilityTime"
#define AD_VB_EVENTS @"AdviewabilityEvents"
#define IMPRESSIONID @"ImpressionID"

#define AD_VBJS_ID @"AdviewabilityID"
#define AD_VBJS_TYPE @"AdviewabilityType"




#define VIEW_ABILITY_KEY @[  \
AD_MEASURABILITY,  \
AD_VB, \
AD_VB_FORGROUND, \
AD_VB_LIGHT, \
AD_VB_SHOWFRAME, \
AD_VB_COVER_RATE, \
AD_VB_HIDE, \
AD_VB_ALPHA, \
AD_VB_POINT, \
AD_VB_FRAME, \
AD_VB_TIME, \
AD_VB_EVENTS, \
IMPRESSIONID, \
MZ_VIEWABILITY_THRESHOLD, \
MZ_VIEWABILITY_VIDEO_PLAYTYPE, \
MZ_VIEWABILITY_VIDEO_PROGRESS, \
MZ_VIEWABILITY \
]

#define VIEW_ABILITY_MAIN_KEY @[  \
AD_MEASURABILITY,  \
AD_VB, \
AD_VB_EVENTS, \
IMPRESSIONID \
]




#define TRACKING_KEY_REDIRECTURL       @"REDIRECTURL"

#define TRACKING_KEY_OS_VALUE   1

#define IOSV [[[UIDevice currentDevice] systemVersion] floatValue]

#define IOS7 7.0

#define IOS6 6.0

#define MZ_COMPANY_NAME @"miaozhen"
#define MZ_COMPANY_DOMAIN @".miaozhen.com"
#define TRACKING_KEY_NETWORKTYPE @"NETWORKTYPE" //mw
#define MZ_VIEWABILITY_THRESHOLD @"MZviewabilityThreshold"          //ve
#define MZ_VIEWABILITY_VIDEO_PLAYTYPE @"MZviewabilityVideoPlayType" //vg
#define MZ_VIEWABILITY_VIDEO_PROGRESS @"MZviewabilityVideoProgress" //vc
#define MZ_VIEWABILITY_VIDEO_DURATION @"MZviewabilityVideoDuration" //vb
#define MZ_VIEWABILITY @"MZviewability"                             //vx
#define MZ_VIEWABILITY_RECORD @"MZviewabilityRecord"                //va
#define MZ_VIEWABILITY_CONFIG_THRESHOLD @"MZviewabilityConfigThreshold"    //vi
#define MZ_VIEWABILITY_CONFIG_AREA @"MZviewabilityConfigArea"              //vh

#endif
