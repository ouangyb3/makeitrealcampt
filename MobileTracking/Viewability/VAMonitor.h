//
//  VAMonitor.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Monitor.h"
#import "VAMonitorFrame.h"
#import "VAMonitorTimeline.h"
#import "VAMonitorConfig.h"
#import "MMA_Macro.h"
#import "VAMaros.h"
@class VAMonitor;

@protocol VAMonitorDataProtocol <NSObject>

- (void)monitor:(VAMonitor *)monitor didReceiveData:(NSDictionary *)monitorData;
@end


typedef NS_ENUM(NSUInteger, VAMonitorStatus) {
    VAMonitorStatusRuning = 0,              // 正常工作
//    VAMonitorStatusTimeout = 1,              // 超过最大可持续监测时间
    VAMonitorStatusWaitingUpload = 1,           // 等待上传
    VAMonitorStatusUploaded = 2              // 上传完成
    
};

typedef NS_ENUM(NSUInteger, VAProgressStatus) {
    VAProgressStatusRuning = 0,              // 正常工作
    VAProgressStatusEnd = 3              // 上传完成
};


@interface VAMonitor : NSObject <NSCoding>
{
    BOOL _canMeasurable;

}

@property (nonatomic, weak, readonly) UIView *adView;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *redirectURL;

@property (nonatomic, copy, readonly) NSString *impressionID;
@property (nonatomic, copy, readonly) NSString *adID;


@property (nonatomic, strong, readonly) VAMonitorTimeline *timeline;
@property (nonatomic) VAMonitorStatus status;
@property (nonatomic) VAProgressStatus progressStatus;

@property (nonatomic, strong,readonly) VAMonitorConfig *config;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly) BOOL isVideo;


@property (nonatomic, weak) id<VAMonitorDataProtocol> delegate;


+ (VAMonitor *)monitorWithView:(UIView *)view isVideo:(BOOL)isVideo url:(NSString *)url redirectURL:(NSString *)redirectURL impressionID:(NSString *)impID adID:(NSString *)adID keyValueAccess:(NSDictionary *)keyValueAccess config:(VAMonitorConfig *)config;

//- (void)setConfig:(VAMonitorConfig *)config;

- (void)captureAdStatusAndVerify;

//private method for subclass
- (void)captureAdStatus;

- (void)stopAndUpload;

- (NSString *)keyQuery:(NSString *)key;
- (BOOL)canRecord:(NSString *)key;
@end

