//
//  MMASign.h
//  MMASign
//
//  Created by master on 2017/12/11.
//  Copyright © 2017年 master. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMASign : NSObject
+ (NSString *)sign:(NSString *)urlString ts:(NSString *)ts sdkv:(NSString *)sdkv;

@end
