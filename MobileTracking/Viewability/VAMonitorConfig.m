//
//  VAMonitorConfig.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMonitorConfig.h"

@implementation VAMonitorConfig

+ (instancetype)defaultConfig {
    return [[VAMonitorConfig alloc] init];
}

- (instancetype)init {
    self = [super init];
    _maxDuration = 120;  // 默认监测时长
    _exposeValidDuration = 1; //  普通曝光达标时长(秒)
    _videoExposeValidDuration = 2; // 视频曝光达标时长(秒)
    _monitorInterval = 0.1;  // 监测事件间隔(秒)
    _cacheInterval = 1; // 缓存事件间隔(秒)
    _vaildExposeShowRate = 0.5; // 有效曝光比例
    _maxUploadCount = 20; //最大可上传监测节点数量
    _needRecordData = YES;
    _videoDuration = 0;
    _trackProgressPointsTypes = VAVideoProgressTrackTypeNone;
    _needRecordProgress = NO;
    _videoPlayType = 0;
    _trackPolicy = VATrackPolicyPositionChanged; // 监控策略默认位置移动记录
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    VAMonitorConfig *obj = [[[self class] alloc] init];
    obj.maxDuration = self.maxDuration;
    obj.exposeValidDuration = self.exposeValidDuration;
    obj.videoExposeValidDuration = self.videoExposeValidDuration;
    obj.monitorInterval = self.maxDuration;
    obj.cacheInterval = self.cacheInterval;
    obj.vaildExposeShowRate = self.vaildExposeShowRate;
    obj.maxUploadCount = self.maxUploadCount;
    obj.needRecordData = self.needRecordData;
    obj.trackProgressPointsTypes = self.trackProgressPointsTypes;
    obj.needRecordProgress = self.needRecordProgress;
    obj.videoPlayType = self.videoPlayType;
    obj.trackPolicy = self.trackPolicy;
    return obj;
}

- (BOOL)canTrackProgress {
    return _videoDuration > 0 &&
    (self.trackProgressPointsTypes & VAVideoProgressTrackType1_4 ||
     self.trackProgressPointsTypes & VAVideoProgressTrackType2_4 ||
     self.trackProgressPointsTypes & VAVideoProgressTrackType3_4 ||
     self.trackProgressPointsTypes & VAVideoProgressTrackType4_4) &&
    self.needRecordProgress;

}

- (NSString *)progressTrackConfigString {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:(self.trackProgressPointsTypes & VAVideoProgressTrackType1_4) ? @"1" : @"0"];
    [string appendString:(self.trackProgressPointsTypes & VAVideoProgressTrackType2_4) ? @"1" : @"0"];
    [string appendString:(self.trackProgressPointsTypes & VAVideoProgressTrackType3_4) ? @"1" : @"0"];
    [string appendString:(self.trackProgressPointsTypes & VAVideoProgressTrackType4_4) ? @"1" : @"0"];

    return [string copy];
}

//TODO: 检查一下所有值是否在标准值之间 maxDuration 不能小于_exposeValidDuration 不能小于0 不能小于一定值或大于一定值


#pragma mark ---- Coder

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super init]) {
        _monitorInterval = [aDecoder decodeFloatForKey:@"monitorInterval"];
        _maxUploadCount = [aDecoder decodeFloatForKey:@"maxUploadCount"];
        _vaildExposeShowRate = [aDecoder decodeFloatForKey:@"vaildExposeShowRate"];
        _cacheInterval = [aDecoder decodeFloatForKey:@"cacheInterval"];
        _maxDuration = [aDecoder decodeFloatForKey:@"maxDuration"];
        
        _exposeValidDuration = [aDecoder decodeFloatForKey:@"exposeValidDuration"];
        _needRecordData = [aDecoder decodeBoolForKey:@"needRecordData"];
        _videoExposeValidDuration = [aDecoder decodeFloatForKey:@"videoExposeValidDuration"];
        _videoDuration = [aDecoder decodeFloatForKey:@"videoDuration"];
        _trackProgressPointsTypes = [aDecoder decodeIntegerForKey:@"trackProgressPointsTypes"];
        
        _needRecordData = [aDecoder decodeBoolForKey:@"needRecordData"];
        _videoPlayType = [aDecoder decodeIntegerForKey:@"videoPlayType"];
        _trackPolicy = [aDecoder decodeIntegerForKey:@"trackPolicy"];
        
        
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
   [aCoder encodeFloat:_monitorInterval forKey:@"monitorInterval"];
    [aCoder encodeFloat:_maxUploadCount forKey:@"maxUploadCount"];
   [aCoder encodeFloat:_vaildExposeShowRate forKey:@"vaildExposeShowRate"];
   [aCoder encodeFloat:_cacheInterval forKey:@"cacheInterval"];
   [aCoder encodeFloat:_maxDuration forKey:@"maxDuration"];
    
   [aCoder encodeFloat:_exposeValidDuration forKey:@"exposeValidDuration"];
    [aCoder encodeBool:_needRecordData forKey:@"needRecordData"];
   [aCoder encodeFloat:_videoExposeValidDuration forKey:@"videoExposeValidDuration"];
   [aCoder encodeFloat:_videoDuration forKey:@"videoDuration"];
   [aCoder encodeInteger:_trackProgressPointsTypes forKey:@"trackProgressPointsTypes"];
    
   [aCoder encodeBool:_needRecordData forKey:@"needRecordData"];
   [aCoder encodeInteger:_videoPlayType forKey:@"videoPlayType"];
    [aCoder encodeInteger:_trackPolicy forKey:@"trackPolicy"];
}
@end
