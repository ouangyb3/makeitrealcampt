//
//  VAMaros.h
//  ViewbilitySDK
//
//  Created by master on 2017/6/16.
//  Copyright © 2017年 AdMaster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#define VAStringFromSize(x) [VAMaros sizeToString:x]
#define VAStringFromPoint(x) [VAMaros pointToString:x]
//#define NSLog(format,...) MMPrint(format,...)
#define NSLog(format,...)

@interface VAMaros : NSObject

+ (NSString *)sizeToString:(CGSize)size;
+ (NSString *)pointToString:(CGPoint)point;

@end
