//
//  MobileTracking.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

//#define MMA_SDK_VERSION @"V2.0.0"

#import <UIKit/UIKit.h>

@interface MobileTracking : NSObject



+ (MobileTracking *)sharedInstance;

// 配置远程XML配置文件地址
- (void)configFromUrl:(NSString *)url;

// 是否开启调试日志
- (void)enableLog:(BOOL)enableLog;

// 点击
- (void)click:(NSString *)url;

// 普通曝光
- (void)view:(NSString *)url;

// 可视化监测曝光
- (void)view:(NSString *)url ad:(UIView *)adView;

// 视频可视化监测曝光
- (void)viewVideo:(NSString *)url ad:(UIView *)adView;
- (void)viewVideo:(NSString *)url ad:(UIView *)adView videoPlayType:(NSInteger)type;//type:视频播放类型，1-自动播放，2-手动播放，0-无法识别

// 普通曝光
- (void)jsView:(NSString *)url ad:(UIView *)adView;

// 视频可视化监测曝光
- (void)jsViewVideo:(NSString *)url ad:(UIView *)adView;

// 清空待发送任务队列和发送失败任务队列
- (BOOL)clearAll;

// 清空发送失败任务队列
- (BOOL)clearErrorList;

// 进入后台调用
- (void)didEnterBackground;

// 进入前台调用
- (void)didEnterForeground;

// 结束时调用
- (void)willTerminate;


@end
