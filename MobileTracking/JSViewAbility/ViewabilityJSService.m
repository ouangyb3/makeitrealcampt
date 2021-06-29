//
//  ViewabilityJSService.m
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "ViewabilityJSService.h"
#import "VAMonitorConfig.h"
#import "VACompanyRun.h"
#import "VAViewCapture.h"
#import "VAJSMaros.h"
#import "VAJSViewabilityData.h"
#import "VACacheWebView.h"
#import "VADeviceMessage.h"
@interface ViewabilityJSService ()

@property (nonatomic) dispatch_queue_t monitorQueue;   // 监测逻辑线程队列
@property (nonatomic) dispatch_queue_t runQueue;   // 捕获状态
@property (nonatomic) dispatch_queue_t dataQueue;   // 数据监测


@property (nonatomic) dispatch_source_t timer;
@property (nonatomic, strong) NSMutableDictionary <NSString *,VACompanyRun*>* companyRuning;


@end
static const char *view_monitor_queue = "adview.jsmonitor.queue";
static const char *view_run_queue = "adview.jsrun.queue";
static const char *view_data_queue = "adview.jsdata.queue";

@implementation ViewabilityJSService

- (instancetype)initWithJSCompanies:(NSDictionary<NSString *,MMA_Company *> *)companies config:(VAMonitorConfig *)config {
    if(self = [super init]) {
        self.companies = companies;
        // delete outdate data
        [self removeOutdateData];

        _companyRuning = [NSMutableDictionary dictionary];
        _monitorQueue = dispatch_queue_create(view_monitor_queue, DISPATCH_QUEUE_SERIAL);
        _runQueue = dispatch_queue_create(view_run_queue, DISPATCH_QUEUE_CONCURRENT);
        _dataQueue = dispatch_queue_create(view_data_queue, DISPATCH_QUEUE_CONCURRENT);

        _config = config;
        [self start];
        [VACacheWebView start];
        [VADeviceMessage start];
    }
    return self;
}

- (void)removeOutdateData {
    [_companies enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MMA_Company * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *path = [VAJSMaros cachePathWithName:obj.name];
        VAJSViewabilityData *data = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:path]];
        if([[NSDate date] timeIntervalSinceDate:data.date] > VAJS_MAX_SURVIVAL) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            printf("\n移除过期数据,company:%s\n",[obj.name UTF8String]);
        }
    }];
}



- (void)start {
    if(_timer) {
        dispatch_suspend(self.timer);
        _timer = nil;
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _monitorQueue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, (_config.monitorInterval) * NSEC_PER_SEC, 0.001 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self monitorAdStatusLoop];
    });
    dispatch_resume(self.timer);
}

- (void)monitorAdStatusLoop {
   
    [_companyRuning enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VACompanyRun * _Nonnull obj, BOOL * _Nonnull stop) {
            dispatch_async(_runQueue, ^{
                [obj run];
            });
    }];
}

- (void)addJSCapture:(VAViewCapture *)capture {
    dispatch_barrier_async(_dataQueue, ^{
        if(!capture) {
            NSLog(@"capture is nil");
            return ;
        }
        NSLog(@"add js capture : %@",capture.uuid);
        VACompanyRun *run = [self companyRunWithCapture:capture];
        [run addViewCapture:capture];
        
    });
}

- (NSDictionary *)getRuningCompany {
    NSDictionary *runing ;
    runing = [NSDictionary dictionaryWithDictionary:_companyRuning];
    return runing;
}

- (VACompanyRun *)companyRunWithCapture:(VAViewCapture *)capture {
    MMA_Company *company = capture.company;
    VACompanyRun *run = _companyRuning[company.name];
    if(!run) {
        run = [[VACompanyRun alloc] initWithCompany:company];
        if(run) {
            _companyRuning[company.name] = run;
        }
    }
    return run;
}


@end
