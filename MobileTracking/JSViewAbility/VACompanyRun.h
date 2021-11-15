//
//  VACompanyRun.h
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VAViewCapture;
@class MMA_Company;
@interface VACompanyRun : NSObject

@property (nonatomic, copy, readonly) MMA_Company *company;

- (instancetype)initWithCompany:(MMA_Company *)company;

- (void)addViewCapture:(VAViewCapture *)capture;

- (void)run;

- (BOOL)canRun;

@end
