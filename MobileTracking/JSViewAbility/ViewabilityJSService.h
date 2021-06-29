//
//  ViewabilityJSService.h
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMA_XMLReader.h"
@class VAViewCapture;
@class VAMonitorConfig;
@interface ViewabilityJSService : NSObject
@property (nonatomic, strong, readonly) VAMonitorConfig *config;
@property (nonatomic,strong) NSDictionary<NSString *,MMA_Company *> *companies;
- (instancetype)initWithJSCompanies:(NSDictionary <NSString *,MMA_Company *>*)companies config:(VAMonitorConfig *)config;


- (void)addJSCapture:(VAViewCapture *)capture;
@end
