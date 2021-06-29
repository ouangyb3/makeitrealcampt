//
//  MMA_TaskQueue.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMA_Task.h"

@interface MMA_TaskQueue : NSObject

- (instancetype)initWithIdentity: (NSString *)identity;

- (void)push: (MMA_Task *)task;

- (MMA_Task *)pop;

- (void)clear;

- (NSInteger)count;

- (void)loadData;

- (void)persistData;

@end
