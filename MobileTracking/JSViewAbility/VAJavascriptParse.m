//
//  VAJavascriptParse.m
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VAJavascriptParse.h"
NSString *JSScheme = @"mmaviewabilitysdk";

NSString *JSCallGetCache = @"getJSCacheData";
NSString *JSCallSaveData = @"saveJSCacheData";
NSString *JSCallStopViewability = @"stopViewability";

@implementation VAJavascriptParse

- (instancetype)initWithURL:(NSURL *)url withResponder:(id <VAJavascriptBridgeProtocol>)responder{
    if(self = [super init]) {
        if(!url || ![url isKindOfClass:[NSURL class]]) {
            return nil;
        }
        _scheme = [url.scheme copy];
        _jsCallType = [url.host copy];
        _additionParameters = [self parseQueryString:url.query];
        _action = [self selectorWithType:_jsCallType];
        
        if(![self isVaildParse]) {
            return nil;
        }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // delegate api all only one object need input
        if([responder respondsToSelector:_action]) {
            id obj = nil;
            if(_additionParameters.count) {
                obj = _additionParameters[_additionParameters.allKeys[0]];
            }
            [responder performSelector:_action withObject:obj];
        }
#pragma clang diagnostic pop
        
    }
    return self;
}

- (BOOL)isVaildParse {
    BOOL scheme = [_scheme isEqualToString:JSScheme];
    BOOL callType = ([@[JSCallGetCache, JSCallSaveData, JSCallStopViewability] indexOfObject:_jsCallType] != NSNotFound);
    
    return scheme && callType;
}

- (SEL)selectorWithType:(NSString *)type {
    NSDictionary *dictionary = @{
                                 JSCallGetCache : @"getJSCacheData:",
                                 JSCallSaveData : @"saveJSCacheData:",
                                 JSCallStopViewability : @"stopViewability:"
                                 };
    NSString *selectorString = dictionary[type];
    if(selectorString && selectorString.length) {
        return NSSelectorFromString(selectorString);
    }
    return nil;
}


- (NSDictionary *)parseQueryString:(NSString *)query
{
    @try {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSArray *paramArr = [query componentsSeparatedByString:@"&"];
        for (NSString *param in paramArr)
        {
            NSArray * elements = [param componentsSeparatedByString:@"="];
            if ([elements count] <= 1)
            {
                return nil;
            }
            
            NSString *key = [elements objectAtIndex:0];// [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [elements objectAtIndex:1];//[[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [paramDict setObject:value forKey:key];
        }
        
        return paramDict;
        
    } @catch (NSException *exception) {
        return nil;
    }
}
@end
