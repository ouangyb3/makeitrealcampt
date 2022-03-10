//
//  MMA_TaskQueue.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_TaskQueue.h"

@interface MMA_TaskQueue()

@property (atomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSString *identity;

@end

@implementation MMA_TaskQueue

- (instancetype)initWithIdentity: (NSString *)identity
{
    if (self = [super init]) {
        _queue = [NSMutableArray array];
        _identity = identity;
    }
    return self;
}

- (void)push:(MMA_Task *)task
{
    @synchronized(self.queue) {
           if ([self.queue indexOfObject:task] == NSNotFound) {
             [self.queue addObject:task];
         }
    
    }
 
}

- (MMA_Task *)pop
{
    @synchronized(self.queue) {
        if ([self.queue count] == 0) {
            return nil;
        }
        
        MMA_Task *task = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        return task;
    }
}

- (void)clear
{
    @synchronized(self.queue) {
        [self.queue removeAllObjects];
        [self persistData];
    }
}

- (NSInteger)count
{
    return [self.queue count];
}

- (void)loadData
{
    NSData *queueData = [[NSUserDefaults standardUserDefaults] objectForKey:self.identity];
    if (queueData) {
        self.queue = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:queueData];
    }
}

- (void)persistData
{
    NSData *queueData = [NSKeyedArchiver archivedDataWithRootObject:self.queue];
    [[NSUserDefaults standardUserDefaults] setObject:queueData forKey:self.identity];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
