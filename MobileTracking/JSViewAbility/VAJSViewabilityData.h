//
//  VAJSViewabilityData.h
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAJSViewabilityData : NSObject <NSCoding>

@property (nonatomic, copy) NSString *viewabilityString;
@property (nonatomic, strong) NSDate *date;


- (instancetype)initWithString:(NSString *)string;

@end
