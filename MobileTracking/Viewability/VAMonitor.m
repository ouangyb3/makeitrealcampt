

//
//  VAMonitor.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMonitor.h"
#import "VAViewMonitor.h"

#import "VAMaros.h"
@interface VAMonitor () {
    VAMonitorConfig *_config;
    
}
@property (nonatomic, strong) NSDictionary *keyValueAccess;

@end


@implementation VAMonitor

- (instancetype)initWithView:(UIView *)view isVideo:(BOOL)isVideo url:(NSString *)url redirectURL:(NSString *)redirectURL impressionID:(NSString *)impID adID:(NSString *)adID  keyValueAccess:(NSDictionary *)keyValueAccess{
    if(!view) {
        NSLog(@"view 视图为空,未开始监测");
        return nil;
    }
    if (![view isKindOfClass:[UIView class]]) {
        NSLog(@"传入值错误,广告监测目标视图必须继承自<UIView>");
        return nil;
    }
    
    if(self = [super init]) {
        _adView = view;
        _isVideo = isVideo;
        _url = url;
        
        _redirectURL = redirectURL;
        _canMeasurable = YES;
        _impressionID = impID;
        _adID = adID;
        _timeline = [[VAMonitorTimeline alloc] initWithMonitor:self];
        _isValid = NO;
        _keyValueAccess = keyValueAccess;
        _mzMidOver = NO;
        _mzEndOver = NO;
        self.status = VAMonitorStatusRuning;
    }
    return self;
}


- (void)setConfig:(VAMonitorConfig *)config {
    _config = config;
}

- (VAMonitorConfig *)config {
    if(!_config) {
        _config = [VAMonitorConfig defaultConfig];
    }
    return _config;
}


+ (VAMonitor *)monitorWithView:(UIView *)view isVideo:(BOOL)isVideo  url:(NSString *)url redirectURL:(NSString *)redirectURL impressionID:(NSString *)impID adID:(NSString *)adID keyValueAccess:(NSDictionary *)keyValueAccess {
    VAMonitor *monitor;
    monitor = [[VAViewMonitor alloc] initWithView:view isVideo:(BOOL)isVideo url:url redirectURL:redirectURL impressionID:impID adID:adID keyValueAccess:keyValueAccess];
    return monitor;
}


- (void)captureAdStatusAndVerify {
    if(_adView) {
        [self captureAdStatus];
    }
    [self verifyExpose];
}

- (void)stopAndUpload {
    self.status = VAMonitorStatusWaitingUpload;
    [self generateUpload];
}


- (void)captureAdStatus {
    // reimplement by subclass
}

// 验证是否可上报
- (void)verifyExpose {
    //曝光有效间隔和最大时长达标,等待上报
    
    //mzcommit-满足条件进行中点监测，否则把mzEndOver置成true，走普通的数据上报流程
    if (self.isVideo && self.videoDuration > 0) {
        [self mzMidPointVerifyUpload];
    } else {
        _mzEndOver = YES;
    }
    
    //  条件1: 达到曝光最大时长并且当前广告未正在进行曝光
    if(self.timeline.monitorDuration >= _config.maxDuration && self.timeline.exposeDuration < 0.001) {
        NSLog(@"ID:%@达到最大上报时长条件并且当前无曝光,进行上报等待,广告位监测帧数:%ld",self.impressionID,(long)[self.timeline count]);
        self.status = VAMonitorStatusWaitingUpload;
        [self generateUpload];
        return;
    }
    
    // 条件2: 当前曝光时长已经满足曝光上报条件阈值
    if (_isMZURL && _validExposeDuration > 0) {
        _exposeVaildDuration = _validExposeDuration;
    } else {
        _exposeVaildDuration = _isVideo ? _config.videoExposeValidDuration : _config.exposeValidDuration;
    }
    if(self.timeline.exposeDuration >= _exposeVaildDuration && !_isValid) {
        NSLog(@"ID:%@满足曝光条件进行上报等待,广告位监测帧数:%ld",self.impressionID,[self.timeline count]);
        _isValid = YES;
        if(_mzEndOver) {
            //中点监测结束，才停止定时器
            self.status = VAMonitorStatusWaitingUpload;
        }
        [self generateUpload];
        return;
    }
    
    // 条件3: AdView 释放满足上报条件
    if(!_adView) {
        NSLog(@"ID:%@ AdView 消失,准备上报等待,广告位监测帧数:%ld",self.impressionID,[self.timeline count]);
        self.status = VAMonitorStatusWaitingUpload;
        [self generateUpload];
        return;
    }
}

// 查询上报的key
- (NSString *)keyQuery:(NSString *)key {
    return _keyValueAccess[key];
}

// key 是否在对照列表中 不再列表中 不上传
- (BOOL)canRecord:(NSString *)key {
    NSString *accessKey = _keyValueAccess[key];
    if(accessKey && accessKey.length) {
        return YES;
    }
    return NO;
}

- (NSString *)generateUpload {

    NSMutableDictionary *parmaters;
    if (self.isMZURL) {
        parmaters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_impressionID,IMPRESSIONID,
                                                                        [NSString stringWithFormat:@"%d",_isValid?1:4],MZ_VIEWABILITY,
                                                                        [NSString stringWithFormat:@"%d",(int)_exposeVaildDuration],MZ_VIEWABILITY_THRESHOLD,
                                                                        nil];
        if (self.isNeedRecord) {
            [parmaters setValue:[self.timeline generateUploadEvents] forKey:AD_VB_EVENTS];
        }
        if (self.isVideo) {
            [parmaters setValue:[NSString stringWithFormat:@"%d", _videoPlayType] forKey:MZ_VIEWABILITY_VIDEO_PLAYTYPE];
        }
    } else {
        parmaters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_impressionID,IMPRESSIONID,
                                                                        [self.timeline generateUploadEvents],AD_VB_EVENTS,
                                                                        [NSString stringWithFormat:@"%d",_isValid],AD_VB,
                                                                        @"1",AD_MEASURABILITY,
                                                                        nil];
    }
    
    
    NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
    [parmaters enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * _Nonnull stop) {
        if([self canRecord:key]) {
            accessDictionary[[self keyQuery:key]] = obj;
        }
    }];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(monitor:didReceiveData:)]) {
        [_delegate monitor:self didReceiveData:accessDictionary];
    }
    
    if(!(_isValid && !_mzEndOver)) {
        //可见但中点监测没结束，先不停定时器
        self.status = VAMonitorStatusUploaded;
    }
    
    return @"";
}

- (void)mzMidPointVerifyUpload {
    if (_mzEndOver) {
        return;
    }
    
    if (!_mzMidOver && self.timeline.monitorDuration >= _videoDuration/2) {
        _mzMidOver = YES;
        NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
        if ([self canRecord:IMPRESSIONID]) {
            accessDictionary[[self keyQuery:IMPRESSIONID]] = _impressionID;
        }
        accessDictionary[self.mzVideoMidPoint] = @"mid";
        if(self.delegate && [self.delegate respondsToSelector:@selector(monitor:didReceiveData:)]) {
            [_delegate monitor:self didReceiveData:accessDictionary];
        }
    }
    
    if (!_mzEndOver && self.timeline.monitorDuration >= _videoDuration) {
        _mzEndOver = YES;
        if(_isValid) {
            self.status = VAMonitorStatusWaitingUpload;
        }
        NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
        if ([self canRecord:IMPRESSIONID]) {
            accessDictionary[[self keyQuery:IMPRESSIONID]] = _impressionID;
        }
        accessDictionary[self.mzVideoMidPoint] = @"end";
        if(self.delegate && [self.delegate respondsToSelector:@selector(monitor:didReceiveData:)]) {
            [_delegate monitor:self didReceiveData:accessDictionary];
        }
        if(_isValid) {
            self.status = VAMonitorStatusUploaded;
        }
    }
}

- (void)dealloc {
    NSLog(@"ID:%@ deallocd",self.impressionID);
}

#pragma mark ---- Coder

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super init]) {
        _url = [aDecoder decodeObjectForKey:@"url"];
        _impressionID = [aDecoder decodeObjectForKey:@"impressionID"];
        
        _timeline = [aDecoder decodeObjectOfClass:[VAMonitorTimeline class] forKey:@"timeline"];
        _status = [aDecoder decodeIntegerForKey:@"status"];
        _isValid = [aDecoder decodeBoolForKey:@"isValid"];
        _keyValueAccess = [aDecoder decodeObjectForKey:@"keyValueAccess"];

        
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_impressionID forKey:@"impressionID"];
    
    [aCoder encodeObject:_timeline forKey:@"timeline"];
    [aCoder encodeInteger:_status forKey:@"status"];
    [aCoder encodeBool:_isValid forKey:@"isValid"];
    [aCoder encodeObject:_keyValueAccess forKey:@"keyValueAccess"];

}
@end
