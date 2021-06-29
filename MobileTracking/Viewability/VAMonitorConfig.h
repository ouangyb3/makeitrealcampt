//
//  VAMonitorConfig.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAMonitorConfig : NSObject

@property (nonatomic) CGFloat maxDuration;
@property (nonatomic) CGFloat exposeValidDuration;
@property (nonatomic) CGFloat videoExposeValidDuration;

@property (nonatomic) CGFloat monitorInterval;
@property (nonatomic) CGFloat maxUploadCount;
@property (nonatomic) CGFloat vaildExposeShowRate;

@property (nonatomic) CGFloat cacheInterval;

@property (nonatomic) NSDictionary *keyValueConfig;


+ (instancetype)defaultConfig;

@end
