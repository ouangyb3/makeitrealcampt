//
//  VAMonitorFrame.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMonitorFrame.h"
#import "UIView+MMA_Monitor.h"

#import "NSDate+VASDK.h"

#import "MMA_AdViewMonitor.h"

@interface VAMonitorFrame ()
@property (nonatomic, strong) MMA_AdViewResult *viewabilityResult;
@end

@implementation VAMonitorFrame


- (instancetype)initWithView:(UIView *)view {
    if(!view) {
        return nil;
    }
    if (self = [super init]) {
        
        MMA_AdViewMonitor *monitor = [[MMA_AdViewMonitor alloc] init];
        _viewabilityResult = [monitor monitorWithAdView:view];
        
        _frame = view.frame;
        _windowFrame = view.mma_frameOnKeyWindow;
        _showFrame = view.mma_showOnKeyWindow;
        _alpha = view.alpha;
        _hidden = view.hidden;
        _ad_showing = _viewabilityResult.ad_showing;
        
        _isForground = ([UIApplication sharedApplication].applicationState==UIApplicationStateActive);
        _captureDate = [NSDate date];
       
        _coverRate = _viewabilityResult.cover_rate;
//        if(_frame.size.width * _frame.size.height == 0) {
//            _coverRate = 1;
//        } else {
//
//            _coverRate = 1 - (_showFrame.size.width * _showFrame.size.height) / (_frame.size.width * _frame.size.height);
//        }
        
    }
    return self;
}

- (BOOL)isVisible {
    return _showFrame.size.width > 0 && _showFrame.size.height > 0 && _hidden == NO && _alpha > 0.001 && _isForground && !_viewabilityResult.ad_showing;
}

- (BOOL)isEqualFrame:(VAMonitorFrame *)frame {
    if(CGRectEqualToRect(_frame, frame.frame) &&
       CGRectEqualToRect(_windowFrame, frame.windowFrame) &&
       CGRectEqualToRect(_showFrame, frame.showFrame) &&
       fabs(_alpha - frame.alpha) < 0.001 &&
       _hidden == frame.hidden &&
       _isForground == frame.isForground &&
       _coverRate == frame.coverRate && _ad_showing == frame.ad_showing) {
        return YES;
    }
    return NO;
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
