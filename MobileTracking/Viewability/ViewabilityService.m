

//
//  ViewbilityService.m
//  ViewbilitySDK
//
//  Created by master on 2017/6/15.
//  Copyright © 2017年 AdMaster. All rights reserved.
//
#import "ViewabilityService.h"
#import "VAMaros.h"
#import "MMA_Log.h"

@interface ViewabilityService ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, VAMonitor *> *monitors;
@property (nonatomic) dispatch_queue_t monitorQueue;   // 监测逻辑线程队列
@property (nonatomic) dispatch_queue_t captureQueue;  // 捕获及处理数据线程

@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) NSDate *lastCacheDate;

@property(nonatomic,assign)BOOL ret;

@end
static const char *view_monitor_queue = "adview.monitor.queue";
static const char *view_capture_queue = "adview.capture.queue";

#define VA_MONITOR_SAVE_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@".va_monitors"]

@implementation ViewabilityService

- (instancetype)initWithConfig:(VAMonitorConfig *)config {
    if(self = [super init]) {
        _monitors = [NSMutableDictionary dictionary];
        _monitorQueue = dispatch_queue_create(view_monitor_queue, DISPATCH_QUEUE_SERIAL);
        _captureQueue = dispatch_queue_create(view_capture_queue, DISPATCH_QUEUE_CONCURRENT);
        _config = config;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
        [self start];
        
    }
    return self;
}


- (void)start {
    if(_timer) {
        dispatch_suspend(self.timer);
        _timer = nil;
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _monitorQueue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, (_config.monitorInterval) * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self monitorAdStatusLoop];
    });
    dispatch_resume(self.timer);
}

- (void)monitorAdStatusLoop {
    NSMutableArray *invalidMonitors = [NSMutableArray array];
    
    [_monitors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VAMonitor * _Nonnull obj, BOOL * _Nonnull stop) {
        
        __block VAMonitorStatus tempStatus;
        __block VAProgressStatus tempProgressStatus;

        dispatch_barrier_sync(_captureQueue, ^{
            tempStatus = obj.status;
            tempProgressStatus = obj.progressStatus;
        });
          
        //进度监测或可视化监测有一个没有结束则不移除
        if(tempStatus == VAMonitorStatusUploaded && tempProgressStatus == VAProgressStatusEnd) {
            NSString *monitorKey = [NSString stringWithFormat:@"%@-%@",obj.domain,obj.adID];
            [invalidMonitors addObject:monitorKey];
            NSLog(@"ID:%@视图上传完成停止监测",obj.adID);
           _ret = NO;
            //可视化监测和进度监测如果有一个没有结束,则继续监测.
        } else if(tempStatus == VAMonitorStatusRuning || tempProgressStatus == VAProgressStatusRuning) {
            dispatch_async(_captureQueue, ^{
#if DEBUG
 
                dispatch_async(dispatch_get_main_queue(), ^{
                      [obj captureAdStatusAndVerify];
                });
#else
          [obj captureAdStatusAndVerify];
#endif
              
                NSLog(@"ID:%@视图捕获状态",obj.adID);
               
            });
             _ret = YES;
        }
    }];
    [_monitors removeObjectsForKeys:invalidMonitors];
    if (_ret==YES) {
           [self saveMonitors];
    }
     
    
}


- (void)addVAMonitor:(VAMonitor *)monitor {
    if(!monitor) {
        NSLog(@"监测管理为nil");
        return;
    }
    dispatch_async(_monitorQueue, ^{
        // 设置monitor 的配置
        if(!monitor.adID || !monitor.adID.length) {
            NSLog(@"adID 不存在");
            return;
        }
        NSLog(@"ID:%@添加监测视图",monitor.adID);
        
        NSString *monitorKey = [NSString stringWithFormat:@"%@-%@",monitor.domain,monitor.adID];
        // 已存在 停止并上报 使用新的监测覆盖
        VAMonitor *exitMonitor = _monitors[monitorKey];
        if(exitMonitor) {
            NSLog(@"ID:%@ domain:%@ 已存在相同广告位监测强制停止上一次监测",monitor.adID,monitor.domain);

            dispatch_async(_captureQueue, ^{
                [exitMonitor stopAndUpload];
            });
            [_monitors removeObjectForKey:monitorKey];
        }
        _monitors[monitorKey] = monitor;

    });
}

- (void)stopVAMonitor:(NSString *)monitorKey {
    dispatch_async(_monitorQueue, ^{
        VAMonitor *exitMonitor = _monitors[monitorKey];
        if(exitMonitor) {
            NSLog(@"Key:%@ 广告存在停止监测",monitorKey);
                   _ret = NO;
            exitMonitor.status = VAMonitorStatusWaitingUpload;
            exitMonitor.progressStatus = VAProgressStatusEnd;
            
            dispatch_async(_captureQueue, ^{
                [exitMonitor stopAndUpload];
            });
            [_monitors removeObjectForKey:monitorKey];
        }
    });
}

- (void)setVAMonitorVisible:(NSString *)monitorKey {
    dispatch_async(_monitorQueue, ^{
        VAMonitor *exitMonitor = _monitors[monitorKey];
        if (exitMonitor) {
            NSLog(@"Key:%@ 广告存在停止监测",monitorKey);
                   _ret = NO;
            [exitMonitor setValidExpose];
            exitMonitor.status = VAMonitorStatusWaitingUpload;
            exitMonitor.progressStatus = VAProgressStatusEnd;
            dispatch_async(_captureQueue, ^{
                [exitMonitor stopAndUpload];
            });
        }
    });
}

- (void)saveMonitors {
  
    @try {
        dispatch_barrier_sync(_captureQueue, ^{
            NSDictionary *monitors = [NSDictionary dictionaryWithDictionary:_monitors];
          NSLog(@"保存检测数据%@",monitors);
            /**只在检测开始， 才进行保存数据判断*/
       
               NSDate * date =  [NSDate date];
            if(!_lastCacheDate || [date timeIntervalSinceDate:_lastCacheDate] > _config.cacheInterval) {
//                 NSLog(@"写入数据%lf",_config.cacheInterval);
                _lastCacheDate = date;
                [NSKeyedArchiver archiveRootObject:monitors toFile:VA_MONITOR_SAVE_PATH];
            }
                
                   
        });
    } @catch (NSException *exception) {
        NSLog(@"#exception# 保存监测崩溃");
    }
}

- (void)processCacheMonitorsWithDelegate:(id <VAMonitorDataProtocol>)delegate {
    dispatch_async(_captureQueue, ^{
        if([[NSFileManager defaultManager] fileExistsAtPath:VA_MONITOR_SAVE_PATH isDirectory:nil]) {
            @try {
                   NSDictionary<NSString *, VAMonitor *> *cacheMonitors = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:VA_MONITOR_SAVE_PATH]];
                         NSLog(@"读取%lu条缓存数据",(unsigned long)[[cacheMonitors allKeys] count]);
                         [cacheMonitors enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, VAMonitor * _Nonnull obj, BOOL * _Nonnull stop) {
                             obj.delegate = delegate;
                             // 如果已经上传过监测数据,则不再上传
                             if(obj.status != VAMonitorStatusUploaded) {
                                 [obj stopAndUpload];
                             }
                         }];
                         [[NSFileManager defaultManager] removeItemAtPath:VA_MONITOR_SAVE_PATH error:nil];
            } @catch (NSException *exception) {
             
            } @finally {
              
            }
         
        }
    });
}

- (void)didEnterBackground {
    [self saveMonitors];
}

@end
