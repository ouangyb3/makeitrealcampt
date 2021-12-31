//
//  VACacheWebView.m
//  MobileTracking
//
//  Created by master on 2017/8/1.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VACacheWebView.h"

@interface VACacheWebView ()

@property (nonatomic, strong) NSMutableArray *canUsedWebView;

@end

static NSMutableArray *_canUsedWebViews;
static dispatch_queue_t _webViewQueue;


@implementation VACacheWebView

+ (void)start {
    _webViewQueue = dispatch_queue_create("adview.jsmonitor.webview.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_webViewQueue, ^{
        _canUsedWebViews = [NSMutableArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [VACacheWebView generateWebView];
        });

    });
}

+ (void)generateWebView {
    WKWebView *webView = [[WKWebView alloc] init];
 
  
    [_canUsedWebViews addObject:webView];

}

+ (WKWebView *)getWebView {
    __block WKWebView *webView;
    dispatch_sync(_webViewQueue, ^{
        if(!_canUsedWebViews.count) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [VACacheWebView generateWebView];
            });
        }
        webView = [_canUsedWebViews objectAtIndex:0];
        [_canUsedWebViews removeObject:webView];
        if(!_canUsedWebViews.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self generateWebView];
            });
        }
    });
    return webView;

}

@end
