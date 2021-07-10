//
//  VAMontorTimeline.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VAMonitorFrame;
@class VAMonitor;
@interface VAMonitorTimeline : NSObject <NSCoding>
@property (nonatomic) CGFloat exposeDuration;
@property (nonatomic) CGFloat monitorDuration;
@property (nonatomic, weak) VAMonitor *monitor;
@property (nonatomic) BOOL prevIsVisibleSlice;
@property (nonatomic) BOOL isVisibleSlice;

- (instancetype)initWithMonitor:(VAMonitor *)monitor;

- (void)enqueueFrame:(VAMonitorFrame *)frame;

- (NSInteger)count;
- (NSString *)generateUploadEvents;
@end
