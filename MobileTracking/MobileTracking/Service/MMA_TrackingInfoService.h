//
//  MMA_TrackingInfoService.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-14.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface MMA_TrackingInfoService : NSObject

+ (MMA_TrackingInfoService *)sharedInstance;

@property (nonatomic, strong, readonly) NSString *macAddress;
@property (nonatomic, strong, readonly) NSString *ipAddress;
@property (nonatomic, strong, readonly) NSString *systemVerstion;
@property (nonatomic, strong, readonly) NSString *idfa;
@property (nonatomic, strong, readonly) NSString *idfv;

@property (nonatomic, strong, readonly) NSString *scwh;
@property (nonatomic, strong, readonly) NSString *appKey;
@property (nonatomic, strong, readonly) NSString *appName;

@property (nonatomic, strong, readonly) NSString *location;
@property (nonatomic, strong, readonly) NSString *term;
@property (nonatomic, assign, readonly) NSInteger networkCondition;
@property (nonatomic, strong, readonly) NSString *wifiSSID;
@property (nonatomic, strong, readonly) NSString *wifiBSSID;
@end
