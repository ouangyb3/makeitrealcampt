


//
//  VADeviceMessage.m
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VADeviceMessage.h"
#import "MMA_Macro.h"
#import "TrackingInfoService.h"
#import "GTMNSString+URLArguments.h"
#import "MMA_Helper.h"

static NSDictionary *_device;
static NSString *_locationInfo;

@implementation VADeviceMessage

+ (void)start {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [VADeviceMessage deviceMessage:NO];
    });
}

// 共计14个字段
+ (NSDictionary *)deviceMessage:(BOOL)trackLocation {
    NSMutableDictionary *deviceMessage = [NSMutableDictionary dictionary];
    
    TrackingInfoService *service = [TrackingInfoService sharedInstance];
    
    if(!_device || !_device.count) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary addEntriesFromDictionary:@{
                                               @"os" : [NSString stringWithFormat:@"%d",TRACKING_KEY_OS_VALUE],
                                               @"akey" : [[service appKey] gtm_stringByEscapingForURLArgument],
                                               @"aname" : [[service appName] gtm_stringByEscapingForURLArgument],
                                               @"scwh" : [service scwh],
                                               @"openudid" :   [[service openUDID] gtm_stringByEscapingForURLArgument],
                                               @"term" : [[service term] gtm_stringByEscapingForURLArgument],
                                               @"wifissid"  : [[service wifiSSID] gtm_stringByEscapingForURLArgument],
                                               @"wifibssid"  : [MMA_Helper md5HexDigest:[service wifiBSSID]],
                                               @"osvs" : [[service systemVerstion]gtm_stringByEscapingForURLArgument],
                                               @"sdkvs" : MMA_SDK_VERSION

                                               }];
        
        if ( IOSV >= IOS6) {
            NSString *idfa = [[service idfa] gtm_stringByEscapingForURLArgument];
            dictionary[@"idfa"] = idfa;
            dictionary[@"idfamd5"] = [MMA_Helper md5HexDigest:idfa];
        }
        if (IOSV < IOS7) {
            NSString *macAddress = service.macAddress;
            dictionary[@"mac"] = [MMA_Helper md5HexDigest:macAddress];
        }
        _device = [dictionary copy];
    }
    
    
    if (trackLocation && !_locationInfo) {
        _locationInfo = [service location];
    }
    
    // device
    [deviceMessage addEntriesFromDictionary:_device];
    
    //location
    if(_locationInfo && _locationInfo.length) {
        deviceMessage[@"lbs"] = _locationInfo;
    }

    // wifi
    deviceMessage[@"wifi"] = [NSString stringWithFormat:@"%ld",(long)[service networkCondition]];

    return deviceMessage;
}

@end
