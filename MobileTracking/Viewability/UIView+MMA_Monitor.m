


//
//  UIView+Monitor.m
//  AdMaster_Ad_Cheat
//
//  Created by master on 10/11/16.
//  Copyright © 2016 AdMaster. All rights reserved.
//

#import "UIView+MMA_Monitor.h"
@implementation UIView (MMA_Monitor)

//Window投射尺寸 自身尺寸 alpha hidden window
- (BOOL)mma_isShowing {
    /**肉眼无法察觉的透明度*/
    BOOL alphaCheck = !(self.alpha <= 0.01);
    BOOL hiddenCheck = !self.hidden;
    BOOL ClearColorCheck = YES;
    BOOL backgroundColorCheck  = YES;
    UIImageView * imgView = (UIImageView *)self;
   /**这里逻辑还需要严谨化 需要判断图片的实际大小*/
    if(![imgView isKindOfClass:[UIImageView class]]||([imgView isKindOfClass:[UIImageView class]]&&imgView.image==nil)){
        /**透明颜色判断*/
    ClearColorCheck = ! CGColorEqualToColor(self.backgroundColor.CGColor,  [UIColor clearColor].CGColor);
        backgroundColorCheck =  !(self.backgroundColor==nil);
    }
 
   
    BOOL sizeCheck = self.mma_width != 0 && self.mma_height != 0;
    BOOL sSizeCheck = self.mma_sWidth != 0 && self.mma_sHeight != 0;
    
    BOOL windowCheck = [self isKindOfClass:[UIWindow class]] ? YES : (self.window != nil);
    
    return alphaCheck && hiddenCheck && sizeCheck && sSizeCheck && windowCheck && ClearColorCheck&&backgroundColorCheck;
    
}

- (BOOL)mma_hiddenCheck {
    BOOL alphaCheck = !(self.alpha == 0);
    BOOL hiddenCheck = !self.hidden;
    return alphaCheck && hiddenCheck;
}

/** traverse all superview issshowing */
- (BOOL)mma_isSuperviewsShowing {
    
    UIView *superview = self.superview;
    if (!superview) {
        return NO;
    }
    BOOL superviewsCheck = YES;
    while (superview) {
        superviewsCheck = superviewsCheck && superview.mma_hiddenCheck;
        superview = superview.superview;
    }
    return superviewsCheck && self.window.mma_isShowing;
    
}

//相交rect
- (CGRect)mma_intersectionWithView:(UIView *)view {
    
    CGRect mainRect = [self mma_showOnKeyWindow];
    CGRect coverRect = [view mma_showOnKeyWindow];
    if (CGRectIntersectsRect(mainRect, coverRect)) {
        return CGRectIntersection(mainRect, coverRect);
    }
    return CGRectZero;
}

/** show frame on keywindow */
- (CGRect)mma_showOnKeyWindow {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *superview = self.superview;
    while (superview) {
        if (superview.clipsToBounds) {
            break;
        }
        superview = superview.superview;
    }
    
    //    super遍历结束，如果没有需要了遍历window
    if (superview == nil) {
        if (self.window.clipsToBounds == YES) {
            superview = self.window;
        }
    }
    
    CGRect realRect = CGRectZero;
    if (superview == nil) {
        realRect = self.bounds;  // 因为可能不存在父视图坐标系转换的时候设定从自己的view坐标系转换.需要使用bound
        return [self convertRect:realRect toView:window];
    } else {
        CGRect selfOnWindow = [self convertRect:self.bounds toView:window];
        CGRect superOnWindow = [superview convertRect:superview.bounds toView:window];
        CGRect intersection = CGRectIntersection(selfOnWindow, superOnWindow);
        return intersection;
        
    }
}

- (CGRect)mma_frameOnKeyWindow {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return [self convertRect:self.bounds toView:window];
}

/** return is super -> */
- (BOOL)mma_isSuper:(UIView *)view {
    NSArray *superviews = nil;
    if (!superviews) {
        superviews = [self mma_superviews];
    }
    if ([superviews indexOfObject:view] == NSNotFound) {
        return NO;
    }
    return YES;
}

- (NSArray *)mma_superviews {
    NSMutableArray *supers = [NSMutableArray array];
    [supers addObject:self.window];
    UIView *superview = self.superview;
    while (superview) {
        [supers addObject:superview];
        superview = superview.superview;
    }
    return [supers copy];
}

/** height */
- (float)mma_height {
    return self.frame.size.height;
}

/** width */
- (float)mma_width {
    return self.frame.size.width;
}

/** height on window */
- (float)mma_sHeight {
    return [self mma_showOnKeyWindow].size.height;
}

/** width on window */
- (float)mma_sWidth {
    return [self mma_showOnKeyWindow].size.width;
}

- (NSDictionary *)mma_properties {
    
    return @{
             @"class":NSStringFromClass([self class]),
             @"frameOnWindow":NSStringFromCGRect([self mma_showOnKeyWindow]),
             @"frame":NSStringFromCGRect([self frame]),
             @"backgroundColor":[self mma_bgcolorString],
             @"clipsToBounds":@(self.clipsToBounds)
             };
    
}

- (NSString *)mma_bgcolorString {
    return [self mma_stringFromColor:self.backgroundColor];
}

//颜色转string
- (NSString *)mma_stringFromColor:(UIColor *)value {
    
    if (value && [value isKindOfClass:[UIColor class]]) {
        UIColor *colorValue = (UIColor *)value;
        
        CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(colorValue.CGColor));
        if (colorSpaceModel == kCGColorSpaceModelMonochrome || colorSpaceModel == kCGColorSpaceModelRGB) {
            size_t numberOfComponents = CGColorGetNumberOfComponents(colorValue.CGColor);
            const CGFloat *components = CGColorGetComponents(colorValue.CGColor);
            
            if (colorSpaceModel == kCGColorSpaceModelMonochrome && numberOfComponents >= 1) {
                CGFloat w = (255 * components[0]);
                CGFloat a = (numberOfComponents > 1 ? components[1] : 1.0f);
                
                return [NSString stringWithFormat:@"rgba(%.0f, %.0f, %.0f, %.2f)", w, w, w, a];
            }
            else if (colorSpaceModel == kCGColorSpaceModelRGB && numberOfComponents >= 3)
            {
                CGFloat r = (255 * components[0]);
                CGFloat g = (255 * components[1]);
                CGFloat b = (255 * components[2]);
                CGFloat a = (numberOfComponents > 3 ? components[3] : 1.0f);
                
                return [NSString stringWithFormat:@"rgba(%.0f, %.0f, %.0f, %.2f)", r, g, b, a];
            }
        }
    }
    return @"";
    
}

@end
