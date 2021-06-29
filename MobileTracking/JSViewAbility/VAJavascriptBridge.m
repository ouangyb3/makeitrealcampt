
//
//  VAJavascriptBridge.m
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VAJavascriptBridge.h"
#import "VAJavascriptParse.h"
#import "VAJSMaros.h"

@interface VAJavascriptBridge () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) id<VAJavascriptBridgeProtocol> delegate;

@end

@implementation VAJavascriptBridge

- (instancetype)initWithWebView:(UIWebView *)webView delegate:(id <VAJavascriptBridgeProtocol>) delegate {
    if(self = [super init]) {
        
        self.webView = webView;
        self.webView.delegate = self;
        self.delegate = delegate;
        // 线程保护: 3s 没有返回自动resume
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.webFinishBlock) {
                _webFinishBlock();
                _webFinishBlock = nil;
            }
        });
    }
    return self;
}

- (void)sendViewabilityMessage:(NSString *)viewabilityMessage {
    NSArray *array = [NSJSONSerialization JSONObjectWithData:[viewabilityMessage dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    static int t = 0;
    for(NSDictionary *dict in array) {
        NSLog(@"%d发送数据->JS : %@",t,dict[AD_VBJS_ID]);
    }
    t++;
    NSString *url = [NSString stringWithFormat:@"MMASDK.sendViewabilityMessage(JSON.stringify(%@))",viewabilityMessage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView stringByEvaluatingJavaScriptFromString:url];
    });
}

- (void)sendCacheMessage:(NSString *)cacheViewabilityMessage {
    NSString *url = [NSString stringWithFormat:@"MMASDK.sendCacheMessage(JSON.stringify(%@))",cacheViewabilityMessage];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView stringByEvaluatingJavaScriptFromString:url];
    });
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    VAJavascriptParse *parse = [[VAJavascriptParse alloc] initWithURL:request.URL withResponder:_delegate];
    NSLog(@"拦截到:%@",NSStringFromSelector(parse.action));

    return ![parse isVaildParse];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
    
    if(self.webFinishBlock) {
        _webFinishBlock();
        _webFinishBlock = nil;
    }

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError");
    if(self.webFinishBlock) {
        _webFinishBlock();
        _webFinishBlock = nil;
    }
}

- (void)dealloc {
    NSLog(@"VACompanyRun Dealloc");
}



@end
