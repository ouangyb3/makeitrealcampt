//
//  MMA_Log.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMA_Log : NSObject

+ (void)setDebug:(BOOL)debug;

+ (void)log:(NSString *)format withParameters:(id)parameter, ...;

@end
