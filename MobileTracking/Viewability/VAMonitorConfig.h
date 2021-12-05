//
//  VAMonitorConfig.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, VAVideoProgressTrackType) {
    VAVideoProgressTrackTypeNone = 0,
    VAVideoProgressTrackType1_4 = 1 << 0,
    VAVideoProgressTrackType2_4 = 1 << 1,
    VAVideoProgressTrackType3_4 = 1 << 2,
    VAVideoProgressTrackType4_4 = 1 << 3,

};

typedef NS_ENUM(NSUInteger, VATrackPolicy) {
    VATrackPolicyPositionChanged,
    VATrackPolicyVisibleChanged
};

@interface VAMonitorConfig : NSObject <NSCopying>


@property (nonatomic) CGFloat monitorInterval;
@property (nonatomic) CGFloat maxUploadCount;
@property (nonatomic) CGFloat vaildExposeShowRate;
@property (nonatomic) CGFloat cacheInterval;
@property (nonatomic) CGFloat maxDuration;

@property (nonatomic) CGFloat exposeValidDuration;
@property (nonatomic) BOOL needRecordData;
@property (nonatomic) CGFloat videoExposeValidDuration;
@property (nonatomic) CGFloat videoDuration;
@property (nonatomic) VAVideoProgressTrackType trackProgressPointsTypes;

@property (nonatomic) BOOL needRecordProgress;
@property (nonatomic) NSInteger videoPlayType;
@property (nonatomic) VATrackPolicy trackPolicy;


+ (instancetype)defaultConfig;
- (BOOL)canTrackProgress;
- (NSString *)progressTrackConfigString;

@end
