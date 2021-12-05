//
//  UIView+Monitor.h
//  AdMaster_Ad_Cheat
//
//  Created by master on 10/11/16.
//  Copyright © 2016 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdHeper.h"

@interface UIView (Monitor)

/** show frame on keywindow 在window上的可视区域*/
- (CGRect)showOnKeyWindow;

- (CGRect)frameOnKeyWindow;


@end
