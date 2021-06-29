//
//  VAJavascriptBridge.h
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VAJavascriptBridgeProtocol <NSObject>
- (void)stopViewability:(NSString *)url;
- (void)saveJSCacheData:(NSString *)data;
- (void)getJSCacheData:(NSString *)clear;

@end

@interface VAJavascriptBridge : NSObject

@property (nonatomic, copy) void(^webFinishBlock)();

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id <VAJavascriptBridgeProtocol>) delegate;
- (void)sendViewabilityMessage:(NSString *)viewabilityMessage;

- (void)sendCacheMessage:(NSString *)cacheViewabilityMessage;
@end
