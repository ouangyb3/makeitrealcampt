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
static NSString *kTag=@"[MMA SDK]";


static inline void JCPrint(NSString *format, ...) {
    __block va_list arg_list;
    va_start (arg_list, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString *dataString = [[NSString stringWithFormat:@"%@",localeDate] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    
    printf("%s %s\n",[dataString UTF8String],formattedString.UTF8String);
}

+ (void) setDebug:(BOOL)debug {
    theDebug = debug;
}

+ (void)log:(NSString *)format,... {
    if (theDebug) {
        va_list paramter;
        va_start(paramter, format);
        NSString *par = [[NSString alloc]initWithFormat:format arguments:paramter];
        par = [NSString stringWithFormat:@" %@",par];
        JCPrint(@"%@%@",kTag,par);
        va_end(paramter);
    }
}

@end
