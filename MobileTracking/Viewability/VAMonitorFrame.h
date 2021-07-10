//
//  VAMonitorFrame.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAMonitorFrame : NSObject <NSCoding>

@property (nonatomic,readonly) CGRect frame;   // 当前frame

@property (nonatomic,readonly) CGRect windowFrame;  // 翻译到window 的frame

@property (nonatomic,readonly) CGRect showFrame;     // 相对于window可视frame

@property (nonatomic,readonly) CGFloat alpha;

@property (nonatomic,readonly) BOOL hidden;

@property (nonatomic,readonly) BOOL isForground;   // 是否前台运行 0/后 1/前

@property (nonatomic,readonly) NSDate *captureDate;   // 监测日期

@property (nonatomic,readonly) CGFloat coverRate;  // 被覆盖比例

- (instancetype)initWithView:(UIView *)view isMZURL:(BOOL)isMZURL;

- (BOOL)isVisible;

- (BOOL)isEqualFrame:(VAMonitorFrame *)frame;

//- (void)resetToUnMeasured;

@end
