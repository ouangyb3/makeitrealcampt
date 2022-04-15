//
//  UIView+Monitor.h
//  AdMaster_Ad_Cheat
//
//  Created by master on 10/11/16.
//  Copyright © 2016 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MMA_Monitor)

/** isshowing */
- (BOOL)mma_isShowing;

/**on AdViewIsShowing*/
- (BOOL)mma_ViewIsShowing;

/** traverse all superview issshowing */
- (BOOL)mma_isSuperviewsShowing;

/** return intersection rect with view */
- (CGRect)mma_intersectionWithView:(UIView *)view;

/** show frame on keywindow */
- (CGRect)mma_showOnKeyWindow;

- (CGRect)mma_frameOnKeyWindow;

/** return is super -> */
- (BOOL)mma_isSuper:(UIView *)view;

/** height */
- (float)mma_height;

/** width */
- (float)mma_width;

/** height on window */
- (float)mma_sHeight;

/** width on window */
- (float)mma_sWidth;

- (NSDictionary *)mma_properties;

@end
