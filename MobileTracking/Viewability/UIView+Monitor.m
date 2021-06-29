


//
//  UIView+Monitor.m
//  AdMaster_Ad_Cheat
//
//  Created by master on 10/11/16.
//  Copyright © 2016 AdMaster. All rights reserved.
//

#import "UIView+Monitor.h"
@implementation UIView (Monitor)


- (CGRect)showOnKeyWindow {
    // 可视尺寸
    CGRect realRect = self.frameOnKeyWindow;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *superview = self.superview;
    while (superview) {
        if(superview.clipsToBounds) {
            realRect = [self intersectionRectOnWindow:realRect with:superview];
        }
        superview = superview.superview;
    }
    
    if(!superview) {
        if(self.window.clipsToBounds == YES) {
            realRect = [self intersectionRectOnWindow:realRect with:superview];
        }
    }
    
    return realRect;
}

// view 基于window和window 的rect 相交得到的尺寸
- (CGRect)intersectionRectOnWindow:(CGRect)aRect with:(UIView *)bView {
    
    CGRect bRect = [bView frameOnKeyWindow];

    CGRect intersection = CGRectIntersection(aRect, bRect);
    return intersection;
}

- (CGRect)frameOnKeyWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return [self convertRect:self.bounds toView:window];
}





@end
