

//
//  VAMaros.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/16.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMaros.h"

@implementation VAMaros

+ (NSString *)sizeToString:(CGSize)size {
    return [NSString stringWithFormat:@"%.1fx%.1f",size.width,size.height];
}
+ (NSString *)pointToString:(CGPoint)point {
    return [NSString stringWithFormat:@"%.1fx%.1f",point.x,point.y];
}

@end
