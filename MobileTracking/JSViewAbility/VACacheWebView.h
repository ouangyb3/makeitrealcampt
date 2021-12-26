//
//  VACacheWebView.h
//  MobileTracking
//
//  Created by master on 2017/8/1.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface VACacheWebView : NSObject

+ (void)start;
+ (WKWebView *)getWebView;

@end
