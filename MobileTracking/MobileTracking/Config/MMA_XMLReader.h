//
//  MMA_XMLReader.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMA_SDKConfig.h"

@interface MMA_XMLReader : NSObject

+ (MMA_SDKConfig *)sdkConfigWithString:(NSString *)xmlString;
+ (MMA_SDKConfig *)sdkConfigWithData:(NSData *)data;

@end
