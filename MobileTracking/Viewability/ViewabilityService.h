//
//  ViewbilityService.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAMonitor.h"
@interface ViewabilityService : NSObject
@property (nonatomic, strong, readonly) VAMonitorConfig *config;

- (instancetype)initWithConfig:(VAMonitorConfig *)config;

- (void)addVAMonitor:(VAMonitor *)monitor;
- (void)processCacheMonitorsWithDelegate:(id <VAMonitorDataProtocol>)delegate;
- (void)stopVAMonitor:(NSString *)monitorKey;
@end
