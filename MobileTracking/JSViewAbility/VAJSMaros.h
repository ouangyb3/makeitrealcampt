//
//  VAJSMaros.h
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMA_SDKConfig.h"
#import "MMA_Log.h"
#import "MMA_Macro.h"

#define VAJS_MAX_SURVIVAL 3 * 24 * 60 * 60
#define NSLog(format,...)
#define printf(format,...)


@interface VAJSMaros : NSObject

+ (NSString *)cachePathWithName:(NSString *)name;
+ (NSString *)jsPathWithCompany:(MMA_Company *)company;
//+ (BOOL)jsFileExitWithCompany:(NSString *)companyName url:(NSString *)urlString;

@end
