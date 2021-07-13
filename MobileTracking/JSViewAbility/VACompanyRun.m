//
//  VACompanyRun.m
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "VACompanyRun.h"
#import "VAViewCapture.h"
#import "VAJavascriptBridge.h"
#import "VADeviceMessage.h"
#import "MMA_SDKConfig.h"
#import "VAJSViewabilityData.h"
#import "VAJSMaros.h"
#import "VACacheWebView.h"
#import "MMA_Macro.h"

@interface VACompanyRun () <VAJavascriptBridgeProtocol>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSMutableDictionary <NSString *,VAViewCapture *>*captureObjs;

@property (nonatomic, strong) VAJavascriptBridge *jsBridge;
@property (nonatomic) dispatch_queue_t dataHandleQueue;
@property (nonatomic) dispatch_queue_t dataSendQueue;

@end
static const char *data_handle_queue = "adview.jsmonitor.dataHandle.queue";
static const char *data_send_queue = "adview.jsmonitor.dataSend.queue";


@implementation VACompanyRun

- (instancetype)initWithCompany:(MMA_Company *)company {
    if(self = [super init]) {
        _company = company;
        _captureObjs = [NSMutableDictionary dictionary];
        
        
        NSString *jsPath = [VAJSMaros jsPathWithCompany:company];
        if(!jsPath || !jsPath.length) {
            [MMA_Log log:@"%@ JS 加载失败",company.name];
            return nil;
        }
        NSString *str = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jsPath] encoding:NSUTF8StringEncoding];
        NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html>\n<head lang=\"en\">\n <meta charset=\"UTF-8\">\n  <title></title>\n</head>\n<body style=\"margin:0;padding:0;\">\n  <div id=\"mian\" style=\"width:%dpx;height:%dpx;\">\n<script type=\"text/javascript\">%@</script>\n</div>\n </body>\n</html>",1,1,str];
        
        self.webView = [VACacheWebView getWebView];
//        [[UIApplication sharedApplication].keyWindow addSubview:self.webView];
        self.jsBridge = [[VAJavascriptBridge alloc] initWithWebView:self.webView delegate:self];
        
        __weak typeof(self) weakself = self;
        // send when web load finish
        [self.jsBridge setWebFinishBlock:^{
            dispatch_resume(weakself.dataSendQueue);
        }];

        
        
        [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
        
        
        _dataHandleQueue = dispatch_queue_create(data_handle_queue, DISPATCH_QUEUE_CONCURRENT);
        _dataSendQueue = dispatch_queue_create(data_send_queue, DISPATCH_QUEUE_SERIAL);
        dispatch_suspend(_dataSendQueue);
        
    }
    return self;
}

- (void)addViewCapture:(VAViewCapture *)capture {
    dispatch_barrier_async(_dataHandleQueue, ^{
        if(!capture) {
            return;
        }
        // push new capture to dictionary with a new uuid
        _captureObjs[capture.uuid] = capture;
        
    });
}

- (BOOL)canRun {
    __block BOOL canrun = NO;
    dispatch_sync(self.dataHandleQueue, ^{
        canrun = self.captureObjs.count > 0;
    });
    return canrun;
}

- (NSDictionary *)getCapturesObjs {
    __block NSDictionary *objs;
    dispatch_sync(_dataHandleQueue, ^{
        objs = [NSDictionary dictionaryWithDictionary:_captureObjs];
    });
    return objs;
}

- (void)run {

    NSDictionary *captureObjs = [self getCapturesObjs];
    if(!captureObjs.count) {
        return ;
    }

    NSMutableArray *uploadReady = [NSMutableArray arrayWithCapacity:captureObjs.count];
    NSMutableDictionary *deviceMessage = [NSMutableDictionary dictionaryWithDictionary:[VADeviceMessage deviceMessage:self.company.MMASwitch.isTrackLocation]];

    [captureObjs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VAViewCapture * _Nonnull obj, BOOL * _Nonnull stop) {
        
        deviceMessage[@"ts"] = obj.ts;

        NSDictionary *dictionary = @{
                                     AD_VBJS_ID : obj.uuid,
                                     @"adurl" : obj.url,
                                     @"deviceMessage" : deviceMessage,
                                     @"viewabilityMessage" : [obj captureStatus]
                                     };
        [uploadReady addObject:dictionary];
    }];

    // convert to json string
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:uploadReady options:NSJSONWritingPrettyPrinted error:&error];
    if(error) {
        NSLog(@"JSON parse failed with error :%@",error);
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    dispatch_async(_dataSendQueue, ^{
        [self.jsBridge sendViewabilityMessage:jsonString];
    });
    
}

#pragma mark ----VAJavascriptBridgeProtocol


- (void)stopViewability:(NSString *)uuid {
    dispatch_barrier_async(_dataHandleQueue, ^{
        printf("\n停止:%s\n",[uuid UTF8String]);
        [_captureObjs removeObjectForKey:uuid];
    });
}

- (void)saveJSCacheData:(NSString *)dataString {
    dispatch_async(_dataHandleQueue, ^{
        printf("\n保存:%s\n",[dataString UTF8String]);
        VAJSViewabilityData *data = [[VAJSViewabilityData alloc] initWithString:dataString];
        [NSKeyedArchiver archiveRootObject:data toFile:[VAJSMaros cachePathWithName:_company.name]];
    });
    
}

- (void)getJSCacheData:(NSString *)clear {
    dispatch_async(_dataHandleQueue, ^{
        BOOL needDelete = [clear boolValue];
        
        NSString *path = [VAJSMaros cachePathWithName:_company.name];
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [self.jsBridge sendCacheMessage:@"[]"];
            return ;
        }
        VAJSViewabilityData *data = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:path]];
        printf("\n缓存获取,clear:%s - %s\n",[clear UTF8String],[data.viewabilityString UTF8String]);

        if(needDelete) {
            [[NSFileManager defaultManager] removeItemAtPath:[VAJSMaros cachePathWithName:_company.name] error:nil];
        }
        if(data && data.viewabilityString.length) {
            [self.jsBridge sendCacheMessage:data.viewabilityString];
        }else {
            [self.jsBridge sendCacheMessage:@"[]"];

        }
    });
}


@end
