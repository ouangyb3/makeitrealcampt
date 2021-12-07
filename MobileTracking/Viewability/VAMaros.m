

//
//  VAMaros.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/16.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import "VAMaros.h"
#import <UIKit/UIKit.h>
@implementation VAMaros

+ (NSString *)sizeToString:(CGSize)size {
    return [NSString stringWithFormat:@"%.1fx%.1f",size.width,size.height];
}
+ (NSString *)pointToString:(CGPoint)point {
    return [NSString stringWithFormat:@"%.1fx%.1f",point.x,point.y];
}
+ (NSString *)sizeToPixelString:(CGSize)size {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return [NSString stringWithFormat:@"%.1fx%.1f",size.width * scale,size.height * scale];
}
+ (NSString *)pointToPixelString:(CGPoint)point {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return [NSString stringWithFormat:@"%.1fx%.1f",point.x * scale,point.y * scale];
}

@end
