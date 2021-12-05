//
//  VAJavascriptParse.h
//  MobileTracking
//
//  Created by master on 2017/7/31.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAJavascriptBridge.h"

extern NSString *JSScheme;

extern NSString *JSCallGetCache;
extern NSString *JSCallSaveData;
extern NSString *JSCallStopViewability;

@interface VAJavascriptParse : NSObject

@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *jsCallType;
@property (nonatomic) SEL action;
@property (nonatomic, strong) NSDictionary *additionParameters;

- (instancetype)initWithURL:(NSURL *)url withResponder:(id <VAJavascriptBridgeProtocol>)responder;
- (BOOL)isVaildParse;
@end
