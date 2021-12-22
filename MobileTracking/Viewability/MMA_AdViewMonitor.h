//
//  AdViewMonitor.h
//  AdCoverDemo
//
//  Created by 黄力 on 2019/5/13.
//  Copyright © 2019 admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMA_AdViewResult.h"
#import <UIKit/UIKit.h>

@interface MMA_AdViewMonitor : NSObject

- (MMA_AdViewResult *)monitorWithAdView:(UIView *)view;

@end
