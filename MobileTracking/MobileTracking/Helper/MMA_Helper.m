//
//  MMA_Helper.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-13.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_Helper.h"

@implementation MMA_Helper

+ (NSString *)md5HexDigest:(NSString *)url{
    const char *cStr = [url UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
+ (NSString *)URLEncoded:(NSString *)string {
    
    
    NSString *unencodedString = string;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}
@end
