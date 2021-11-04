//
//  AdHelper.m
//  AdCoverDemo
//
//  Created by 黄力 on 2019/5/13.
//  Copyright © 2019 admaster. All rights reserved.
//

#import "MMA_AdHelper.h"

@implementation MMA_AdHelper

+ (NSString *)formatRect:(CGRect) rect {
    return [NSString stringWithFormat:@"%.1fX%.1fX%.1fX%.1f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

@end
