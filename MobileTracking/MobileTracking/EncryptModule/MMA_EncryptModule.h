//
//  EncryptModule.h
//  Sign
//
//  Created by tangyumeng on 15-11-06.
//  Copyright (c) 2013年 admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MMA_EncryptModule : NSObject

/**
 *  签名模块的单例
 *
 */
+ (id)sharedEncryptModule;
/**
 *  签名模块的主要方法
 *
 *  @param url 需要签名的url
 *
 *  @return 返回针对传入的url生成的签名串
 */
-(NSString *)signUrl:(NSString *)url;
/**
 *  控制签名串输出到控制台 ,正式发包时不调用，或者传参数为NO
 *
 *  @param flag yes表示输出
 */
- (void)log:(BOOL)flag;
@end