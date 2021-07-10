//
//  VAMonitorFrame.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMonitorFrame.h"
#import "UIView+Monitor.h"

#import "NSDate+VASDK.h"

@implementation VAMonitorFrame


- (instancetype)initWithView:(UIView *)view isMZURL:(BOOL)isMZURL {
    if(!view) {
        return nil;
    }
    if (self = [super init]) {
        _windowFrame = view.frameOnKeyWindow;
        _alpha = view.alpha;
        _hidden = view.hidden;
        
        _isForground = [UIApplication sharedApplication].applicationState==UIApplicationStateActive; //判断遮挡和焦点
        _captureDate = [NSDate date];
        if (isMZURL) {
            _coverRate = 1 - [self getVisibilityRate:view];
        } else {
            _frame = view.frame;
            _showFrame = view.showOnKeyWindow;
            _coverRate = 1 - (_showFrame.size.width * _showFrame.size.height) / (_frame.size.width * _frame.size.height);
        }
    }
    return self;
}

- (BOOL)isVisible {
    return _showFrame.size.width > 0 && _showFrame.size.height > 0 && _hidden == NO && _alpha > 0.001 && _isForground;;
}

- (BOOL)isEqualFrame:(VAMonitorFrame *)frame {
    if(CGRectEqualToRect(_frame, frame.frame) &&
       CGRectEqualToRect(_windowFrame, frame.windowFrame) &&
       CGRectEqualToRect(_showFrame, frame.showFrame) &&
       fabs(_alpha - frame.alpha) < 0.001 &&
       _hidden == frame.hidden &&
       _isForground == frame.isForground &&
       _coverRate == frame.coverRate) {
        return YES;
    }
    return NO;
}

-(CGFloat)getVisibilityRate:(UIView *)adView
{
    if (adView == nil) {
        NSLog(@"#MZ Warning: View is nil, please check input parameter.");
        return 0;
    }
    
    // 获取屏幕区域
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (CGRectIsEmpty(screenRect) || CGRectIsNull(screenRect)) {
        NSLog(@"#MZ Warning: Screen rect is null.");
        return 0;
    }
    
    // 转换view对应window的Rect
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [adView convertRect: adView.bounds toView:window];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return 0;
    }
    _frame = rect;
    
    // 转换父view对应window的Rect
    CGRect superRect = [adView.superview convertRect: adView.superview.bounds toView:window];
    if (CGRectIsEmpty(superRect) || CGRectIsNull(superRect)) {
        return 0;
    }
    
    // 获取父view与window交叉的可视区域Rect
    CGRect visibleRect = CGRectIntersection(superRect, screenRect);
    if (CGRectIsEmpty(visibleRect) || CGRectIsNull(visibleRect)) {
        return 0;
    }
    
    // 获取adView与可视区域的交叉Rect
    CGRect intersectionRect = CGRectIntersection(rect, visibleRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return 0;
    }
    _showFrame = intersectionRect;
    
    //    NSLog(@"#MZ Warning, rects(\n\tscreenRect:%@, \n\tadview:%@, \n\tfatherview:%@, \n\tvisible:%@, \n\tfinally:%@\n\t)",
    //          NSStringFromCGRect(screenRect),NSStringFromCGRect(rect),NSStringFromCGRect(superRect),NSStringFromCGRect(visibleRect),NSStringFromCGRect(intersectionRect));
    
    // 计算可视面积
    if(rect.size.height == 0 || rect.size.width == 0) {
        return 0;
    }
    else {
        return (intersectionRect.size.height * intersectionRect.size.width) / (rect.size.height * rect.size.width);
    }
}

#pragma mark ---- Coder

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super init]) {
        _frame = [aDecoder decodeCGRectForKey:@"frame"];
        _windowFrame = [aDecoder decodeCGRectForKey:@"windowFrame"];
        _showFrame = [aDecoder decodeCGRectForKey:@"showFrame"];
        _alpha = [aDecoder decodeFloatForKey:@"alpha"];
        
        _hidden = [aDecoder decodeBoolForKey:@"hidden"];
        _isForground = [aDecoder decodeBoolForKey:@"isForground"];
        
        _captureDate = [aDecoder decodeObjectForKey:@"captureDate"];
        _coverRate = [aDecoder decodeFloatForKey:@"coverRate"];

    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeCGRect:_frame forKey:@"frame"];
    [aCoder encodeCGRect:_windowFrame forKey:@"windowFrame"];
    [aCoder encodeCGRect:_showFrame forKey:@"showFrame"];
    [aCoder encodeFloat:_alpha forKey:@"alpha"];
    
    [aCoder encodeBool:_hidden forKey:@"hidden"];
    [aCoder encodeBool:_isForground forKey:@"isForground"];
    
    [aCoder encodeObject:_captureDate forKey:@"captureDate"];
    [aCoder encodeFloat:_coverRate forKey:@"coverRate"];
}

@end
