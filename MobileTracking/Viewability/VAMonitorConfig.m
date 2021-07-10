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
    _maxUploadCount = 10; //最大可上传监测节点数量
    return self;
}

//TODO: 检查一下所有值是否在标准值之间 maxDuration 不能小于_exposeValidDuration 不能小于0 不能小于一定值或大于一定值
@end
