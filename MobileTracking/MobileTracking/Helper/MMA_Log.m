//
//  MMA_Log.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-12.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_Log.h"

@implementation MMA_Log

static bool theDebug = NO;

+ (void) setDebug:(BOOL)debug {
    theDebug = debug;
}

+ (void)log:(NSString *)format withParameters:(id)parameter, ... {
    if (theDebug) {
        NSLog(format, parameter);
    }
}

@end
