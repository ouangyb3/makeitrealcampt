//
//  MMA_Task.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
//定义枚举类型
typedef enum _taskType {
    CLICK  = 0,
    IMPRESSION,
    VIEWABLE,
    NONVIEWABLE,
    UNMEASURED,
} taskType;
#define TaskTypeAry @[@"CLICK",@"IMPRESSION",@"VIEWABLE",@"NONVIEWABLE",@"UNMEASURED"]
@interface MMA_Task : NSObject
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSTimeInterval timePoint;
@property (nonatomic, assign) NSInteger failedCount;
@property (nonatomic, assign) BOOL hasFailed;
@property (nonatomic, assign) BOOL hasLock;
@property (nonatomic, copy) NSString * tType;
@property(nonatomic,copy)void(^succeedBlock)(id);
@property(nonatomic,copy)void(^failedBlock)();
@end
