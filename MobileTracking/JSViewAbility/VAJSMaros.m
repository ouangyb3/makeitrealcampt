




//
//  VAJSMaros.m
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VAJSMaros.h"

@implementation VAJSMaros


+ (NSString *)cachePathWithName:(NSString *)name {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/.js_viewability_%@",name]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)jsCachePathWithName:(NSString *)companyName {
    NSString *remotePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/ADM_JS"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:remotePath]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:remotePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    remotePath = [remotePath stringByAppendingFormat:@"/%@.js",companyName];
    return remotePath;
}

+ (NSString *)jsPathWithCompany:(MMA_Company *)company {

    NSString *cachePath = [VAJSMaros jsCachePathWithName:company.name];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:company.jsname ofType:nil];

    NSString *jsCacheString = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:nil];
    NSString *jsBundleString = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:nil];
    
    
    BOOL cacheExit = company.jsurl && company.jsurl.length && jsCacheString && jsCacheString.length;
    BOOL bundleExit = jsBundleString && jsBundleString.length;

    if(!cacheExit && !bundleExit) {
        if(company.jsurl && company.jsurl.length) {
            NSData *jsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:company.jsurl]];
            NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
            if(jsString && jsString.length) {
                [jsData writeToFile:cachePath atomically:YES];
            }else {
                return @"";
            }
            return cachePath;
        }
        return @"";
    } else if(cacheExit) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if(company.jsurl && company.jsurl.length) {
                NSData *jsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:company.jsurl]];
                NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
                if(jsString && jsString.length) {
                    [jsData writeToFile:cachePath atomically:YES];
                }
            }
        });
        return cachePath;
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if(company.jsurl && company.jsurl.length) {
                NSData *jsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:company.jsurl]];
                NSString *jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
                if(jsString && jsString.length) {
                    [jsData writeToFile:cachePath atomically:YES];
                }
            }
        });

        return bundlePath;
    }
}

@end
