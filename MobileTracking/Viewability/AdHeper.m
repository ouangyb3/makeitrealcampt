//
//  AdHeper.m
//  AdMaster_Ad_Cheat
//
//  Created by master on 10/12/16.
//  Copyright © 2016 AdMaster. All rights reserved.
//

#import "AdHeper.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation AdHeper


+ (NSString *)formatRect:(CGRect) rect {
    return [NSString stringWithFormat:@"%.1fX%.1fX%.1fX%.1f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
}

@end
