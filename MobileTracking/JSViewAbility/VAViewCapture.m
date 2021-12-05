

//
//  VAViewCapture.m
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VAViewCapture.h"
#import "NSDate+VASDK.h"
#import "UIView+Monitor.h"
#import "VAMaros.h"
#import "VAJSMaros.h"
#import "MMA_Helper.h"
@interface VAViewCapture ()

@property (nonatomic, weak) UIView *monitorView;


@end

@implementation VAViewCapture

- (instancetype)initWithView:(UIView *)view url:(NSString *)url company:(MMA_Company *)company isVideo:(BOOL)isVideo{
    if (self = [super init]) {
        self.monitorView = view;
        _company = company;
        _url = url;
        _ts = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
        _uuid = [MMA_Helper md5HexDigest:[NSString stringWithFormat:@"%@%@",_ts,_url]];
        _isVideo = isVideo;
    }
    return self;
}

- (NSDictionary *)captureStatus {
    
    NSDate *captureDate = [NSDate date];
    BOOL isForground = ([UIApplication sharedApplication].applicationState==UIApplicationStateActive);

    if(!_monitorView || ![_monitorView isKindOfClass:[UIView class]]) {
        return @{
                 AD_VBJS_TYPE : [NSString stringWithFormat:@"%d",_isVideo],
                 AD_VB_TIME : captureDate.mtimestamp,
                 AD_VB_FORGROUND : [NSString stringWithFormat:@"%d",isForground]  // 是否前台
                 };
    }
    
    CGRect frame = _monitorView.frame;
    CGRect windowFrame = _monitorView.frameOnKeyWindow;
    CGRect showFrame = _monitorView.showOnKeyWindow;
    CGFloat alpha = _monitorView.alpha;
    BOOL hidden = _monitorView.hidden;
    
    CGFloat coverRate = 1 - (showFrame.size.width * showFrame.size.height) / (frame.size.width * frame.size.height);

//    NSLog(@"capture time %@",captureDate.mtimestamp);
    return @{
             AD_VBJS_TYPE : [NSString stringWithFormat:@"%d",_isVideo],
             AD_VB_TIME : captureDate.mtimestamp,          // 监测时间戳毫秒秒
             AD_VB_FRAME : VAStringFromSize(frame.size), // 广告原始尺寸
             AD_VB_POINT : VAStringFromPoint(windowFrame.origin), // 广告可视的原点位置
             AD_VB_ALPHA : [NSString stringWithFormat:@"%.2f",alpha], // 透明度
             AD_VB_SHOWN : [NSString stringWithFormat:@"%d",!hidden],  // 隐藏
             AD_VB_COVER_RATE : [NSString stringWithFormat:@"%.2f",coverRate], // 覆盖比例
             AD_VB_SHOWFRAME : VAStringFromSize(showFrame.size), // 广告可视尺寸
             AD_VB_FORGROUND : [NSString stringWithFormat:@"%d",isForground]  // 是否前台
                 };
}



@end
