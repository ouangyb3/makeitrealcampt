//
//  MMA_Task.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_Task.h"

#define MMA_TASK_URL            @"MMA_TASK_URL"
#define MMA_TASK_TIME_POINT     @"MMA_TASK_TIME_POINT"
#define MMA_TASK_FAILED_COUNT   @"MMA_TASK_FAILED_COUNT"
#define MMA_TASK_HASFAILED      @"MMA_TASK_HASFAILED"
#define MMA_TASK_HASLOCK        @"MMA_TASK_HASLOCK"

@interface MMA_Task ()<NSCoding>

@end

@implementation MMA_Task

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super init]) {
        _url = [aDecoder decodeObjectForKey:MMA_TASK_URL];
        _timePoint = [aDecoder decodeDoubleForKey:MMA_TASK_TIME_POINT];
        _failedCount = [aDecoder decodeIntegerForKey:MMA_TASK_FAILED_COUNT];
        _hasFailed = [aDecoder decodeBoolForKey:MMA_TASK_HASFAILED];
        _hasLock = [aDecoder decodeBoolForKey:MMA_TASK_HASLOCK];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder  encodeObject: _url forKey:MMA_TASK_URL];
    [aCoder  encodeDouble: _timePoint forKey:MMA_TASK_TIME_POINT];
    [aCoder  encodeInteger: _failedCount forKey:MMA_TASK_FAILED_COUNT];
    [aCoder  encodeBool: _hasFailed forKey:MMA_TASK_HASFAILED];
    [aCoder  encodeBool: _hasLock forKey:MMA_TASK_HASLOCK];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[MMA_Task class]]) {
        if ([self.url isEqualToString:[(MMA_Task *)object url]]) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.url hash];
}

@end
