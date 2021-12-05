



//
//  VAJSViewabilityData.m
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VAJSViewabilityData.h"

@implementation VAJSViewabilityData

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    self.viewabilityString = string;
    self.date = [NSDate date];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.viewabilityString = [aDecoder decodeObjectForKey:@"viewabilityString"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.viewabilityString forKey:@"viewabilityString"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

@end
