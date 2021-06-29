
//
//  NSDate+VASDK.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/16.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "NSDate+VASDK.h"

@implementation NSDate (VASDK)
- (NSString *)timestamp {
    long long timestamp = [self timeIntervalSince1970];
    return [NSString stringWithFormat:@"%lld",timestamp];
}

- (NSString *)mtimestamp {
    long long timestamp = [self timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%lld",timestamp];
}
@end
