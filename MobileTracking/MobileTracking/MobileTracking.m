//
//  MobileTracking.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//


#import "MobileTracking.h"
#import "MMA_Macro.h"
#import "MMA_SDKConfig.h"
#import "MMA_XMLReader.h"
#import "MMA_Log.h"
#import "MMA_Task.h"
#import "MMA_TaskQueue.h"
#import "MMA_Helper.h"

#import "MMA_LocationService.h"
#import "MMA_TrackingInfoService.h"
#import "MMASign.h"
#import "MMA_RequestQueue.h"
#import "MMA_GTMNSString+URLArguments.h"
#import "ViewabilityService.h"
#import "VAMonitor.h"
#import "VAMonitorConfig.h"
#import "ViewabilityJSService.h"
#import "VAViewCapture.h"
#import "MMA_IVTInfoService.h"

@interface MobileTracking() <VAMonitorDataProtocol>

@property (atomic, strong) MMA_SDKConfig *sdkConfig;
@property (nonatomic, strong) NSString *sdkConfigURL;
@property (nonatomic, strong) MMA_TaskQueue *sendQueue;
@property (nonatomic, strong) MMA_TaskQueue *failedQueue;
@property (nonatomic, strong) MMA_TrackingInfoService *trackingInfoService;
@property (nonatomic, strong) NSTimer *failedQueueTimer;
@property (nonatomic, strong) NSTimer *sendQueueTimer;
@property (nonatomic, assign) BOOL isTrackLocation;
@property (nonatomic,strong) VAMonitorConfig *viewabilityConfig;
@property (nonatomic,strong) ViewabilityService *viewabilityService;
@property (nonatomic,strong) ViewabilityJSService *viewabilityJSService;

@property (nonatomic, strong) NSMutableDictionary *impressionDictionary;

@end


@interface MMA_VBOpenResult : NSObject
@property (nonatomic) BOOL canOpen;
@property (nonatomic,copy) NSString *url;
//@property (nonatomic,copy) NSString *viewabilityURL;
@property (nonatomic, copy) NSString *redirectURL;
@property (nonatomic, copy) VAMonitorConfig *config;

@end

@implementation MMA_VBOpenResult

- (instancetype)init {
    self = [super init];
    self.canOpen = NO;
    self.url = @""; // 普通曝光或viewabilityURL
//    self.viewabilityURL = @""; // 去噪所有viewability字段的url
    self.redirectURL = @""; // u字段
    return self;
}

@end


@implementation MobileTracking

+ (MobileTracking *)sharedInstance {
    static MobileTracking *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        _trackingInfoService = [MMA_TrackingInfoService sharedInstance];
        _impressionDictionary = [NSMutableDictionary dictionary];
        _isTrackLocation = false;
        
        [self initSdkConfig];
        [self initQueue];
        [self initTimer];
        [self openLBS];
        [self initViewabilityService];
        
        
    }
    return self;
}

- (void)initSdkConfig
{
    @try {
        /**
         *  Old (NSUserDefaults) ----> New(File)
         */
        NSString *SDK_CONFIG_DATA_KEY = @"SDK_CONFIG_DATA_KEY";
        
        NSData *old_sdkData = [[NSUserDefaults standardUserDefaults]  dataForKey:SDK_CONFIG_DATA_KEY];
        
        if(old_sdkData) {
            [old_sdkData writeToFile:SDK_CONFIG_DATA_PATH atomically:YES];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SDK_CONFIG_DATA_KEY];
        }
        /*  Old (NSUserDefaults) ----> New(File) */
        
        NSData *sdkData = [NSData dataWithContentsOfFile:SDK_CONFIG_DATA_PATH];
        if (sdkData) {
            _sdkConfig = [MMA_XMLReader sdkConfigWithData:sdkData];
        } else {
            NSString *localSdkFilePath = [[NSBundle mainBundle] pathForResource:SDK_CONFIG_FILE_NAME ofType:SDK_CONFIG_FILE_EXT];
            NSData *localSdkData = [[NSData alloc] initWithContentsOfFile:localSdkFilePath];
            _sdkConfig = [MMA_XMLReader sdkConfigWithData:localSdkData];
        }
    }
    @catch (NSException *exception) {
        [MMA_Log log:@"MMA_SDK Init SDK Config Exception: %@",exception];
    }
}

- (void)initViewabilityService {
    _viewabilityConfig = [VAMonitorConfig defaultConfig];
    
    if(_sdkConfig.viewability) {
        _viewabilityConfig.maxDuration = _sdkConfig.viewability.maxExpirationSecs; // 总时长
        _viewabilityConfig.monitorInterval = _sdkConfig.viewability.intervalTime * 0.001; // 转换秒
        _viewabilityConfig.exposeValidDuration = _sdkConfig.viewability.viewabilityTime; //目标曝光时间
        _viewabilityConfig.videoExposeValidDuration = _sdkConfig.viewability.viewabilityVideoTime; //目标曝光时间
        _viewabilityConfig.maxUploadCount = _sdkConfig.viewability.maxAmount;
        _viewabilityConfig.vaildExposeShowRate = _sdkConfig.viewability.viewabilityFrame * 0.01; //转换百分比

    }
    _viewabilityService = [[ViewabilityService alloc] initWithConfig:_viewabilityConfig];
    [_viewabilityService processCacheMonitorsWithDelegate:self];
    
    
    //JS服务模块
    _viewabilityJSService = [[ViewabilityJSService alloc] initWithJSCompanies:_sdkConfig.companies config:_viewabilityConfig];
    
    
}

- (void)initQueue
{
    _sendQueue = [[MMA_TaskQueue alloc] initWithIdentity:SEND_QUEUE_IDENTITY];
    _failedQueue = [[MMA_TaskQueue alloc] initWithIdentity:FAILED_QUEUE_IDENTITY];
    
    [_sendQueue loadData];
    [_failedQueue loadData];
    
}

- (void)initTimer
{
    NSInteger failedQueueInterval = self.sdkConfig.offlineCache.queueExpirationSecs;
    if (!failedQueueInterval) {
        failedQueueInterval = DEFAULT_FAILED_QUEUE_TIMER_INTERVAL;
    }
    _failedQueueTimer = [NSTimer scheduledTimerWithTimeInterval:failedQueueInterval
                                                         target:self
                                                       selector:@selector(handleFailedQueueTimer:)
                                                       userInfo:nil
                                                        repeats:YES];
    
    _sendQueueTimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_SEND_QUEUE_TIMER_INTERVAL
                                                       target:self
                                                     selector:@selector(handleSendQueueTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)handleFailedQueueTimer:(NSTimer *)timer
{
    @try {
        NSInteger netStatus = [self.trackingInfoService networkCondition];
        if (netStatus == NETWORK_STATUS_NO) {
            return;
        }
        while ([self.failedQueue count] > 0) {
            MMA_Task *task = [self.failedQueue pop];
            
            MMA_Company *company = [self confirmCompany:task.url];
            [MMA_Log log:@"##failed_queue_url:%@" ,task.url];
            NSInteger offlineCacheExpiration = company.MMASwitch.offlineCacheExpiration;
            NSInteger now = [[[NSDate alloc] init] timeIntervalSince1970];
            if (task.timePoint + offlineCacheExpiration < now) {
                continue;
            }
            NSURL *URL = [NSURL URLWithString:task.url];
//            NSURLCacheStoragePolicy policy = NSURLRequestReloadIgnoringCacheData;
            NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.sdkConfig.offlineCache.timeout];
            RQOperation *operation = [RQOperation operationWithRequest:request];
            
            operation.completionHandler = ^(__unused NSURLResponse *response, NSData *data, NSError *error)
            {
                if (error) {
                    task.failedCount++;
                    if (task.failedCount <= FAILED_QUEUE_TRY_SEND_COUNT) {
                        [self.failedQueue push:task];
                    }
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUCCEED object:nil];
                }
            };
            [[MMA_RequestQueue mainQueue] addOperation:operation];
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)handleSendQueueTimer:(NSTimer *)timer
{
    NSInteger netStatus = [self.trackingInfoService networkCondition];
    if (netStatus == NETWORK_STATUS_NO) {
        return;
    }
    if ([self.sendQueue count] >= self.sdkConfig.offlineCache.length) {
        while ([self.sendQueue count] > 0) {
            MMA_Task *task = [self.sendQueue pop];
            [MMA_Log log:@"##send_queue_url:%@" ,task.url];
            NSURL *URL = [NSURL URLWithString:task.url];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.sdkConfig.offlineCache.timeout];
            RQOperation *operation = [RQOperation operationWithRequest:request];
            
            operation.completionHandler = ^(__unused NSURLResponse *response, NSData *data, NSError *error)
            {
                if (error) {
                    task.failedCount++;
                    task.hasFailed = true;
                    [self.failedQueue push:task];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SUCCEED object:nil];
                    
                }
            };
            [[MMA_RequestQueue mainQueue] addOperation:operation];
        }
    }
}

- (void)didEnterBackground
{
    if (self.sendQueueTimer) {
        [self.sendQueueTimer invalidate];
        self.sendQueueTimer = nil;
    }
    
    if (self.failedQueueTimer) {
        [self.failedQueueTimer invalidate];
        self.failedQueueTimer = nil;
    }
    
    [self.sendQueue persistData];
    [self.failedQueue persistData];
    
}

- (void)willTerminate
{
    [self didEnterBackground];
}

- (void)didEnterForeground
{
    [self initSdkConfig];
//    [self initQueue];
    [self initTimer];
    [self openLBS];
}

- (void)updateSdkConfig
{
    @try {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakSelf.sdkConfigURL]];
            MMA_SDKConfig *sdkConfig = [MMA_XMLReader sdkConfigWithData:data];
            if (sdkConfig && [sdkConfig.companies count]) {
                
                [data writeToFile:SDK_CONFIG_DATA_PATH atomically:YES];
                
                [[NSUserDefaults standardUserDefaults] setInteger:time(NULL) forKey:SDK_CONFIG_LAST_UPDATE_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }
    @catch (NSException *exception) {
        [MMA_Log log:@"##updateSdkConfig exception:%@" ,exception];
    }
    
}

- (void)configFromUrl:(NSString *)url
{
    @try {
        self.sdkConfigURL = url;
        
        NSInteger now = time(NULL);
        NSInteger sdkLastUpdateTime = [[NSUserDefaults standardUserDefaults] integerForKey:SDK_CONFIG_LAST_UPDATE_KEY];
        NSInteger netStatus = [self.trackingInfoService networkCondition];
        
        if (netStatus == NETWORK_STATUS_3G && now - sdkLastUpdateTime > UPDATE_SDK_CONFIG_3G_INTERVAL) {
            [self updateSdkConfig];
        } else if (netStatus == NETWORK_STATUS_WIFI && now - sdkLastUpdateTime > UPDATE_SDK_CONFIG_WIFI_INTERVAL) {
            [self updateSdkConfig];
        }
    }
    @catch (NSException *exception) {
        [MMA_Log log:@"##configFromURL exception:%@" ,exception];
    }
}


- (void)enableLog:(BOOL)enableLog {
    [MMA_Log setDebug:enableLog];
}

- (BOOL)clearAll
{
    [self.failedQueue clear];
    [self.sendQueue clear];
    return YES;
}

- (BOOL)clearErrorList
{
    [self.failedQueue clear];
    return YES;
}

- (void)openLBS
{
    [self.sdkConfig.companies enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MMA_Company *company = (MMA_Company *)obj;
        if (company.MMASwitch.isTrackLocation) {
            [MMA_LocationService sharedInstance];
            self.isTrackLocation = true;
        }
    }];
}

- (NSString *)getAdIDForURL:(NSString *)url {
    @try {
        MMA_Company *company = [self confirmCompany:url];
        if(!company) {
            [MMA_Log log:@"%@" ,@"company is nil,please check your 'sdkconfig.xml' file"];
            return nil;
        }
        // 找出impressionID
        NSArray *arr = [url componentsSeparatedByString:company.separator];
        for (int i = 1; i<[arr count]; i++) {
            NSString *str = [arr objectAtIndex:i];
            MMA_Argument *argument = [company.config.Adplacement valueForKey:AD_PLACEMENT];
            NSString *key = argument.value;
            if(key && key.length) {
                /*过滤字段的*/
                NSString *checkStr= [NSString stringWithFormat:@"%@%@",key,company.equalizer];//枚举满足关键key+赋值符号的字符串（例如：z=）
                BOOL hasPrefix = [str hasPrefix:checkStr];//监测按分隔符拆分的数组元素，是否包含checkStr前缀。
                if (hasPrefix){
                    str = [str substringFromIndex:key.length];
                    return str;
                }
            }
            
        }
        
        return nil;
    } @catch (NSException *exception) {
        [MMA_Log log:@"##exception getImpressionIDForURL:%@" ,exception];
        return nil;
    }
    
    /********************************************/
}


// 去掉字段2g 如果有2j 去掉AdMeasurability Adviewability AdviewabilityEvents ImpressionID四个字段生成链接
- (MMA_VBOpenResult *)vbFilterURL:(NSString *)url isForViewability:(BOOL)viewability isVideo:(BOOL)isVideo  videoPlayType:(NSInteger)type{
    @try {
        
        MMA_Company *company = [self confirmCompany:url];
        MMA_VBOpenResult *res = [[MMA_VBOpenResult alloc] init];
        res.config = self.viewabilityConfig; // 初始化默认配置为当前的配置
        res.url = url;
        res.canOpen = NO;
        
        if(!company) {
            res.canOpen = NO;
            res.url = @"";
            res.redirectURL = @"";
            return res;
        }
        
        NSMutableString *trackURL = [NSMutableString stringWithString:url];
        
        /******确保TRACKING_KEY_REDIRECTURL参数传递放在url最后面*******/
        NSString *redirecturl = @"";
        //        for (MMA_Argument *argument in [company.config.arguments objectEnumerator]) {
        MMA_Argument *argument = [company.config.arguments objectForKey:TRACKING_KEY_REDIRECTURL];
        NSString *queryArgsKey = [argument value];
        if([argument.key isEqualToString:TRACKING_KEY_REDIRECTURL]&&argument.isRequired){
            NSString *redirect_key = [NSString stringWithFormat:@"%@%@%@",company.separator,queryArgsKey,company.equalizer];
            NSRange ff = [trackURL rangeOfString:redirect_key];
            if (ff.location !=NSNotFound ) {
                NSRange u_range = [trackURL rangeOfString:redirect_key];
                NSString *subStr = [trackURL substringToIndex:u_range.location];
                redirecturl = [trackURL substringFromIndex:u_range.location];
                trackURL = [NSMutableString stringWithString:subStr];
                res.redirectURL = redirecturl;
            }
        }
        
        NSString *noRedirectURL = [NSString stringWithString:trackURL];
        NSMutableString *filterURL = [[NSMutableString alloc] initWithString:noRedirectURL];
        
        NSArray *exposeKeys = @[IMPRESSIONID, IMPRESSIONTYPE];
        
//        NSArray *viewabilityKeys = @[AD_MEASURABILITY,
//                                     AD_VB,
//                                     AD_VB_RESULT,
//                                     AD_VB_EVENTS,
//                                     IMPRESSIONID];
        
//        NSArray *ignoreKeys    =   @[AD_VB_ENABLE,
//                                    AD_VB_AREA,
//                                    AD_VB_THRESHOLD,
//                                    AD_VB_VIDEODURATION,
//                                     AD_VB_VIDEOPOINT,
//                                     AD_VB_RECORD
//                                     ];
        
     
        //viewability 监测
        if(viewability) {
            res.canOpen = YES;
            NSString *separator = company.separator;
            NSString *equalizer = company.equalizer;
            for (MMA_Argument *argument in [company.config.viewabilityarguments objectEnumerator]) {
                NSString *key = argument.key;
                NSString *reWriteString = @"";
                if (key && key.length) {
                    NSString *value = argument.value;
                    if (value && value.length) {
                        NSString *replacedString = @"";
                        if([key isEqualToString:AD_VB_AREA]) { //2v
                            NSString *parValue = [self getValueFromUrl:filterURL withCompany:company withArgumentKey:value];
                            NSScanner* scan = [NSScanner scannerWithString:parValue];
                            float val;
                            BOOL isfloat = [scan scanFloat:&val] && [scan isAtEnd];
                            if(parValue && parValue.length && isfloat && parValue.floatValue > 0 && parValue.floatValue < 100) {
                                res.config.vaildExposeShowRate = val * 0.01;
                                continue;

                            } else {
                                reWriteString = [NSString stringWithFormat:@"%@%@%@%g",separator,value,equalizer,res.config.vaildExposeShowRate * 100];
                            }
                        } else if([key isEqualToString:AD_VB_THRESHOLD]) { //2u
                            NSString *parValue = [self getValueFromUrl:filterURL withCompany:company withArgumentKey:value];
                            NSScanner* scan = [NSScanner scannerWithString:parValue];
                            float val;
                            BOOL isfloat = [scan scanFloat:&val] && [scan isAtEnd];
                            //配置已存在覆盖video和普通view
                            if(parValue && parValue.length && isfloat && parValue.floatValue > 0) {
                                res.config.videoExposeValidDuration = val;
                                res.config.exposeValidDuration = val;
                                continue;

                            } else {
                                reWriteString = [NSString stringWithFormat:@"%@%@%@%g",separator,value,equalizer,isVideo ? res.config.videoExposeValidDuration : res.config.exposeValidDuration];

                            }
                            
                        } else if([key isEqualToString:AD_VB_VIDEODURATION]) { //2w
                            NSString *parValue = [self getValueFromUrl:filterURL withCompany:company withArgumentKey:value];
                            NSScanner* scan = [NSScanner scannerWithString:parValue];
                            float val;
                            BOOL isfloat = [scan scanFloat:&val] && [scan isAtEnd];
                            //值大于0 才赋值
                            if(parValue && parValue.length && isfloat && parValue.floatValue > 0) {
                                res.config.videoDuration = val;
                            }
                            continue;
                            //config key. get need upload viewability info or not from this key
                        } else if([key isEqualToString:AD_VB_RECORD]) { //va
                            NSString *parValue = [self getValueFromUrl:filterURL withCompany:company withArgumentKey:value];
                            NSScanner* scan = [NSScanner scannerWithString:parValue];
                            int val;
                            BOOL isInt = [scan scanInt:&val] && [scan isAtEnd];
                            //值为0 才设置不监测数据,否则都使用默认值监测
                            if(parValue && parValue.length && isInt && val == 0) {
                                res.config.needRecordData = NO;
                            }
                            continue;
                            //config key. get config from url according to this key.ep.1111
                        } else if([key isEqualToString:AD_VB_VIDEOPOINT]) { //2x
                            NSString *parValue = [self getValueFromUrl:filterURL withCompany:company withArgumentKey:value];
                            // 值的长度必须为四位才赋值,每位只能为1才会添加相关点监测.
                            if(parValue && parValue.length == 4) {
                                VAVideoProgressTrackType type = VAVideoProgressTrackTypeNone;
                                for (int i = 0; i < 4; i++) {
                                    NSString *flag = [parValue substringWithRange:NSMakeRange(i, 1)];
                                    if([flag isEqualToString: @"1"]) {
                                        type = type | ([flag integerValue] << i);
                                    } else if([flag isEqualToString: @"0"]){
                                        continue;
                                    } else {
                                        type = VAVideoProgressTrackTypeNone;
                                        break;
                                    }
                                }
                                res.config.trackProgressPointsTypes = type;
                            }
                            continue;
                            // if include progress upload key in config.xml, set YES to track progress event.
                        } else if([key isEqualToString:AD_VB_VIDEOPROGRESS]) { //2a
                            res.config.needRecordProgress = YES;
                        }
                        /**加入第一次可见曝光监测中videoType vg字段*/
                            else if([key isEqualToString:AD_VB_VIDEOPLAYTYPE]&&isVideo) { //2a
                                                  reWriteString = [NSString stringWithFormat:@"%@%@%@%ld", separator, value, equalizer,(long)type] ;
                          
                                              }
                        // if contain enable key in url set viewability service OPEN(yes)
//                        else if ([key isEqualToString:AD_VB_ENABLE]) { //2p
//                            if([self isExitKey:value inURL:url withCompany:company]) {
//                                res.canOpen = YES;
//                            } else {
//                                res.canOpen = NO;
//                            }
//                            continue;
//                        }
                        [filterURL replaceOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@[^%@]*", separator, value, equalizer, separator] withString:replacedString options:NSRegularExpressionSearch range:NSMakeRange(0, filterURL.length)];
                        if(reWriteString && reWriteString.length) {
                            [filterURL appendString:reWriteString];
                        }
                    }
                }
            }
            // 曝光监测
        } else {
            for (NSString *parmater in exposeKeys) {
                argument = [company.config.viewabilityarguments valueForKey:parmater];
                NSString *key = argument.key;
                if(key && key.length) {
                    if(argument.value && argument.value.length) {
                        NSString *regular = [NSString stringWithFormat:@"%@%@%@[^%@]*", company.separator, argument.value, company.equalizer, company.separator];
                        [filterURL replaceOccurrencesOfString:regular withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, filterURL.length)];
                    }
                }
            }
            res.canOpen = NO;
        }
        res.url = filterURL;
        return res;
    } @catch (NSException *exception) {
        [MMA_Log log:@"##exception vbFilterURL:%@" ,exception];
    }
    
}


- (void)click:(NSString *)url
{
    MMA_VBOpenResult *result = [self vbFilterURL:url isForViewability:NO isVideo:NO videoPlayType:0];
    url = [NSString stringWithString:result.url];
    MMA_Company *company = [self confirmCompany:url];
    if(!company) {
        [MMA_Log log:@"%@" ,@"company is nil,please check your 'sdkconfig.xml' file"];
        return;
    }
    NSString *adID = [self getAdIDForURL:url];
    if (adID && adID.length) {
        NSString *domain = company.domain[0];
        if(!domain || !domain.length) {
            domain = @"";
        }

        NSString *monitorKey = [NSString stringWithFormat:@"%@-%@",domain,adID];
        [_viewabilityService setVAMonitorVisible:monitorKey];
    }
    NSString *impressKey = [NSString stringWithFormat:@"%@-%@",company.domain[0],adID];
    
    NSString *impressID = _impressionDictionary[impressKey];
    /**
     *  拼接u参数和impressID
     */
    url = [self handleImpressURL:url impression:impressID redirectURL:result.redirectURL additionKey:NO];
    
    [self filterURL:url];
}

// 普通曝光请求: 普通曝光默认不开启viewability. 需要redirectURL
- (void)view:(NSString *)url ad:(UIView *)adView impressionType:(NSInteger)type
{
    @try {
        BOOL viewability = NO;
        MMA_VBOpenResult *result = [self vbFilterURL:url isForViewability:viewability isVideo:NO videoPlayType:0];
        [self view:url ad:adView isVideo:NO videoPlayType:0 handleResult:result impressionType:type];
    }
    @catch (NSException *exception) {
        [MMA_Log log:@"##exception:%@" ,exception];
    }
}

// 视频Viewaility曝光请求: 视频曝光判断是否含有相关AdViewabilityEvents字段决定是否开启viewability 不需要redirectURL
- (void)viewVideo:(NSString *)url ad:(UIView *)adView videoPlayType:(NSInteger)type{
    BOOL viewability = YES;
    MMA_VBOpenResult *result = [self vbFilterURL:url isForViewability:viewability isVideo:YES videoPlayType:type];
    [self view:url ad:adView isVideo:YES videoPlayType:type handleResult:result impressionType:1];
}

// 广告Viewability曝光请求: 同视频Viewability曝光逻辑 不需要redirectURL
- (void)view:(NSString *)url ad:(UIView *)adView {
    BOOL viewability = YES;
    MMA_VBOpenResult *result = [self vbFilterURL:url isForViewability:viewability isVideo:NO videoPlayType:0];
    [self view:url ad:adView isVideo:NO videoPlayType:0 handleResult:result impressionType:1];
}

// 停止可见监测
- (void)stop:(NSString *)url {
    @try {
        NSString *adID = [self getAdIDForURL:url];
        if(!adID || !adID.length) {
            [MMA_Log log:@"adplacement get failed: %@" ,@"no adplacement"];
            return;
        }
        
        MMA_Company *company = [self confirmCompany:url];
        NSString *domain = company.domain[0];
        if(!domain || !domain.length) {
            domain = @"";
        }

        NSString *monitorKey = [NSString stringWithFormat:@"%@-%@",domain,adID];

        [_viewabilityService stopVAMonitor:monitorKey];
    } @catch (NSException *exception) {
        [MMA_Log log:@"##stop: exception:%@" ,exception];
    }
}


// viewability曝光不需要redirectURL已在前面剔除,普通曝光需要redirectURL
- (void)view:(NSString *)url ad:(UIView *)adView isVideo:(BOOL)isVideo videoPlayType:(NSInteger)type handleResult:(MMA_VBOpenResult *)result  impressionType:(NSInteger)impressionType{
    [[MMA_IVTInfoService sharedInstance] getSensorInfo:^(NSString * _Nonnull l7, NSString * _Nonnull l8, NSString * _Nonnull l9, NSString * _Nonnull l10, NSString * _Nonnull l11, NSString * _Nonnull l12) {
        NSLog(@"=====%@,%@,%@",l7,l8,l9);
           }];
         @try {
                /**
                 *  获取是否含有使用viewability字段
                 */
                result.config.videoPlayType = type;
                
                

                BOOL useViewabilityService = result.canOpen;
                MMA_Company *company = [self confirmCompany:url];
        //        ==========
                result.config.trackPolicy = company.MMASwitch.viewabilityTrackPolicy;
                if(!company) {
                    [MMA_Log log:@"%@" ,@"company is nil,please check your 'sdkconfig.xml' file"];
                    return;
                }
                
                /**
                 *  获取广告位ID,如果没有扔回MMA
                 */
                NSString *adID = [self getAdIDForURL:url];
                if(!adID || !adID.length) {
                    [self filterURL:url];
                    [MMA_Log log:@"adplacement get failed: %@" ,@"no adplacement"];
                    return;
                }
                
                NSString *domain = company.domain[0];
                if(!domain || !domain.length) {
                    domain = @"";
                }
                /**
                 *  拼接impressionID
                 */
                NSString *impressKey = [NSString stringWithFormat:@"%@-%@",domain,adID];
                
                //iOS:MD5(idfa+idfv+广告位ID+时间戳（ms））
                NSString * timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
                NSString * compString = [NSString stringWithFormat:@"%@%@%@%@",[self.trackingInfoService idfa],[self.trackingInfoService idfv],adID,timestamp];
                NSString *impressID  = [MMA_Helper md5HexDigest:compString];
                _impressionDictionary[impressKey] = impressID;
                /**
                 *  发送正常的url 监测使用去噪impressionID曝光url,拼接AD_VB (2f),AD_VB_RESULT(vx)
                 */
                
        //        impressionType=0视为Tracked ads；impressionType=1视为曝光
                if (impressionType == 0) {
                    [self handleImpressionType:@"0" URL:result.url impression:impressID redirectURL:result.redirectURL additionKey:useViewabilityService];
                } else if (impressionType == 1){
                    if(!adView || ![adView isKindOfClass:[UIView class]]) {
        //                view=nil或者view非法的情况下，未达到CBR条件，如果是可见监测停止监测
                        [self handleImpressionType:@"0" URL:result.url impression:impressID redirectURL:result.redirectURL additionKey:useViewabilityService];
                        return;
                    } else {
        //                达到CBR条件，如果是可见监测继续监测
                        [self handleImpressionType:@"1" URL:result.url impression:impressID redirectURL:result.redirectURL additionKey:useViewabilityService];
                    }
                }
                
                /**
                 *  Viewability功能模块
                 */
                if(useViewabilityService) {
                    
                    NSMutableDictionary *keyvalueAccess = [NSMutableDictionary dictionary];
                    [VIEW_ABILITY_KEY enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        MMA_Argument *argument = company.config.viewabilityarguments[obj];
                        if(argument.key&& argument.key.length && argument.value && argument.value.length) {
                            keyvalueAccess[obj] = argument.value;
                        }
                    }];
                    
                    // 如果view非法或为空 不可测量参数置为0
                    if(!adView || ![adView isKindOfClass:[UIView class]]) {
                        return;
        //                NSDictionary *dictionary = @{
        //                                             AD_VB_EVENTS : @"[]",
        //                                             AD_VB : @"0",
        //                                             AD_VB_RESULT : @"2",
        //                                             IMPRESSIONID : impressID,
        //                                             AD_MEASURABILITY : @"0"
        //                                             };
        //                NSMutableDictionary *accessDictionary = [NSMutableDictionary dictionary];
        //                [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * _Nonnull stop) {
        //                    NSString *accessKey = keyvalueAccess[key];
        //                    if(accessKey && accessKey.length) {
        //                        accessDictionary[accessKey] = obj;
        //                    }
        //                }];
        //                NSString *url = [self monitorHandleWithURL:result.url data:accessDictionary redirectURL:@""];
        //                [self filterURL:url];
                    }
                    VAMonitor *monitor = [VAMonitor monitorWithView:adView isVideo:isVideo url:result.url redirectURL:@"" impressionID:impressID adID:adID keyValueAccess:[keyvalueAccess copy] config:result.config domain:domain];
                    monitor.delegate = self;
                    [_viewabilityService addVAMonitor:monitor];
                    
                    
                }
                
                
                
            } @catch (NSException *exception) {
                [MMA_Log log:@"##view:ad: exception:%@" ,exception];
                
            }
//   }];
//   
}

- (void)handleImpressionType:(NSString *)impressionType URL:(NSString *)url impression:(NSString *)impressionID redirectURL:(NSString *)redirectURL additionKey:(BOOL)additionKey  {
    MMA_Company *company = [self confirmCompany:url];
    NSMutableString *trackURL = [NSMutableString stringWithString:url];
    MMA_Argument *impressionTypeArgument = [company.config.viewabilityarguments valueForKey:IMPRESSIONTYPE];
    if(impressionTypeArgument.value) {
        [trackURL appendFormat:@"%@%@%@%@",company.separator,impressionTypeArgument.value,company.equalizer,impressionType];
    }
    [self filterURL:[self handleImpressURL:trackURL impression:impressionID redirectURL:redirectURL additionKey:additionKey]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EXPOSE object:nil];
}

// 普通曝光
- (void)jsView:(NSString *)url ad:(UIView *)adView{
    [self viewVideoJS:url ad:adView isVideo:NO];
}

// 视频可视化监测曝光
- (void)jsViewVideo:(NSString *)url ad:(UIView *)adView {
    [self viewVideoJS:url ad:adView isVideo:YES];
}


- (void)viewVideoJS:(NSString *)url ad:(UIView *)adView isVideo:(BOOL)isVideo {
    MMA_Company *company = [self confirmCompany:url];
    if(company) {
        VAViewCapture *capture = [[VAViewCapture alloc] initWithView:adView url:url company:company isVideo:isVideo];
        [self.viewabilityJSService addJSCapture:capture];
    } else {
        [MMA_Log log:@"js view can not found company" ,nil];
    }
    
}


//Viewability可视化监测Delegate 接收数据
- (void)monitor:(VAMonitor *)monitor didReceiveData:(NSDictionary *)monitorData {
    NSString *url = [self monitorHandleWithURL:monitor.url data:monitorData redirectURL:monitor.redirectURL];
    
    NSLog(@"viewabilityURL-----------------------%@",url);

    [self filterURL:url];
}

- (NSString *)handleImpressURL:(NSString *)url impression:(NSString *)impressionID redirectURL:(NSString *)redirectURL additionKey:(BOOL)additionKey {
    MMA_Company *company = [self confirmCompany:url];
    NSMutableString *trackURL = [NSMutableString stringWithString:url];
    MMA_Argument *impressionArgument = [company.config.viewabilityarguments valueForKey:IMPRESSIONID];
    
    if(impressionArgument.value && impressionID && impressionID.length) {
        [trackURL appendFormat:@"%@%@%@%@",company.separator,impressionArgument.value,company.equalizer,impressionID];
    }
    
    if(additionKey) {
        MMA_Argument *adViewability = [company.config.viewabilityarguments valueForKey:AD_VB];
        if(adViewability.value && adViewability.value.length) {
            [trackURL appendFormat:@"%@%@",company.separator,adViewability.value];
        }
        
        MMA_Argument *adViewabilityResult = [company.config.viewabilityarguments valueForKey:AD_VB_RESULT];
        if(adViewabilityResult.value && adViewabilityResult.value.length) {
            [trackURL appendFormat:@"%@%@%@%@",company.separator,adViewabilityResult.value,company.equalizer,@"0"];
        }
    }
    
    
    if (redirectURL !=nil&&![redirectURL isEqualToString:@""]) {
        [trackURL appendString:redirectURL];
    }
    
    return trackURL;
}

// 处理监测数据 忽略redirectURL 但是没有去掉参数
- (NSString *)monitorHandleWithURL:(NSString *)url data:(NSDictionary *)monitorData redirectURL:(NSString *)redirectURL {
    @try {
        
        MMA_Company *company = [self confirmCompany:url];
        NSMutableString *trackURL = [NSMutableString stringWithString:url];
        
        [monitorData enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString * obj, BOOL * _Nonnull stop) {
            [trackURL appendFormat:@"%@%@%@%@",company.separator,key,company.equalizer,[MMA_Helper URLEncoded:obj]];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VB object:nil];
        
//        NSLog(@"-----------------------%@",trackURL);
        //        [self filterURL:trackURL];
        return trackURL;
    } @catch (NSException *exception) {
        [MMA_Log log:@"##monitorrHandleWithURL exception:%@" ,exception];
        
    }
}

// 从url 获取是否存在关键字key
- (BOOL)isExitKey:(NSString *)key inURL:(NSString *)url withCompany:(MMA_Company *)company {
    if (!key || !key.length) {
        return 0;
    }
    NSString *separator = company.separator;
    NSString *equalizer = company.equalizer;
    NSString *prefix= [NSString stringWithFormat:@"%@%@%@",separator,key,equalizer];
    return [url rangeOfString:prefix].location != NSNotFound;
}

// 从url 获取配置相关参数后面具体的值
- (NSString *)getValueFromUrl:(NSString *)url withCompany:(MMA_Company *)company withArgumentKey:(NSString *)key
{
    if (!key || !key.length) {
        return 0;
    }
    
    NSString *separator = company.separator;
    NSString *equalizer = company.equalizer;
    NSString *prefix= [NSString stringWithFormat:@"%@%@%@",separator,key,equalizer];
    NSScanner *scanner = [NSScanner scannerWithString:url];
    NSString *value;

    if([scanner scanUpToString:prefix intoString:nil]) {
        [scanner scanString:prefix intoString:nil];
        [scanner scanUpToString:separator intoString:&value];
    }
    return value;
}


- (void)filterURL:(NSString *)url
{
    if ([self confirmCompany:url] == nil) {
        [MMA_Log log:@"%@" ,@"company is nil,please check your 'sdkconfig.xml' file"];
        return;
    }
    
    [self pushTask:url];
}

- (MMA_Company *)confirmCompany:(NSString *)url
{
    MMA_Company *company = nil;
    NSString *host = [[NSURL URLWithString:url] host];
    
    for (MMA_Company *__company in [self.sdkConfig.companies objectEnumerator]) {
        for (NSString *domain in __company.domain) {
            /*将公司domain的匹配逻辑改为host的suffix匹配，避免冒充域名的漏洞。*/
            //         if ([host rangeOfString:domain].length > 0) {
            if ([host hasSuffix:domain]) {
                company = __company;
                break;
            }
            /* */
        }
    }
    return company;
}


- (void)pushTask: (NSString *)url
{
    @try {
        NSString *trackURL = [self generateTrackingURL:url];
        MMA_Task *task = [[MMA_Task alloc] init];
        task.url = trackURL;
        task.timePoint = [[[NSDate alloc] init] timeIntervalSince1970];
        task.failedCount = 0;
        task.hasFailed = false;
        task.hasLock = false;
        [self.sendQueue push:task];
    }
    @catch (NSException *exception) {
        [MMA_Log log:@"##pushTask exception:%@" ,exception];
    }
}


- (NSString *)generateTrackingURL: (NSString *)url
{
    
    MMA_Company *company = [self confirmCompany:url] ;
    NSMutableString *trackURL = [NSMutableString stringWithString:url];
    
    /******确保TRACKING_KEY_REDIRECTURL参数传递放在url最后面*******/
    NSString *redirecturl = @"";
    for (MMA_Argument *argument in [company.config.arguments objectEnumerator]) {
        NSString *queryArgsKey = [(MMA_Argument *)[company.config.arguments objectForKey:argument.key] value];
        if([argument.key isEqualToString:TRACKING_KEY_REDIRECTURL]&&argument.isRequired){
            NSString *redirect_key = [NSString stringWithFormat:@"%@%@%@",company.separator,queryArgsKey,company.equalizer];
            NSRange ff = [trackURL rangeOfString:redirect_key];
            if (ff.location !=NSNotFound ) {
                NSRange u_range = [trackURL rangeOfString:redirect_key];
                NSString *subStr = [trackURL substringToIndex:u_range.location];
                redirecturl = [trackURL substringFromIndex:u_range.location];
                trackURL = [NSMutableString stringWithString:subStr];
            }
        }
    }
    /********************************************/
    
    
    /*确保过滤掉xml文件里需要重新拼接的字段*/
    NSArray *arr = [trackURL componentsSeparatedByString:company.separator];
    for (int i = 1; i<[arr count]; i++) {
        NSString *str = [arr objectAtIndex:i];
        for (MMA_Argument *argument in [company.config.arguments objectEnumerator]) {
            
            NSString *queryArgsKey = [(MMA_Argument *)[company.config.arguments objectForKey:argument.key] value];
            
            /*过滤字段的bug*/
            NSString *checkStr= [NSString stringWithFormat:@"%@%@",queryArgsKey,company.equalizer];//枚举满足关键key+赋值符号的字符串（例如：z=）
            BOOL hasPrefix = [str hasPrefix:checkStr];//监测按分隔符拆分的数组元素，是否包含checkStr前缀。
            if (hasPrefix){//如果包含前缀，从原始串中删除该字段（分隔符+符合格式的字段）
                NSString *deleteStr = [NSString stringWithFormat:@"%@%@",company.separator,str];
                NSRange deleteStrRange = [trackURL rangeOfString:deleteStr];
                if (deleteStrRange.location !=NSNotFound) {
                    [trackURL deleteCharactersInRange:deleteStrRange];
                }
            }
        }
    }
    /********************************************/
    NSString *ts = @"";
    for (MMA_Argument *argument in [company.config.arguments objectEnumerator]) {
        NSString *queryArgsKey = [(MMA_Argument *)[company.config.arguments objectForKey:argument.key] value];
        if ([argument.key isEqualToString:TRACKING_KEY_OS]) {
            [trackURL appendFormat:@"%@%@%@%d", company.separator, queryArgsKey, company.equalizer, TRACKING_KEY_OS_VALUE];
        } else if ([argument.key isEqualToString:TRACKING_KEY_MAC] && IOSV < IOS7) {
            NSString *macAddress = self.trackingInfoService.macAddress;
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, [MMA_Helper md5HexDigest:macAddress]];
        } else if ([argument.key isEqualToString:TRACKING_KEY_IDFA] && IOSV >= IOS6) {
            NSString *idfa = [[self.trackingInfoService idfa] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, idfa];
            
            /*判断有无idfa_md5字段,2015.7.9新增*/
        }else if ([argument.key isEqualToString:TRACKING_KEY_IDFAMD5] && IOSV >= IOS6) {
            NSString *idfa = [[self.trackingInfoService idfa] gtm_stringByEscapingForURLArgument];
            NSDictionary *encrptDic = company.MMASwitch.encrypt;
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer,[MMA_Helper md5HexDigest:idfa]];
            /************/
        } else if ([argument.key isEqualToString:TRACKING_KEY_OPENUDID]) {
            
            NSString *openUDID = [[self.trackingInfoService openUDID] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, openUDID];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_TS]) {
            /*增加了根据配置文件选择客户端传输的时间精度为妙或者毫秒*/
            NSDate *date = [NSDate date];
            NSString *timestamp = [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970] * 1000];
            /**
             Modify Date: 2017年12月28日18:24:17
             timestamp添加逻辑去秒级的时间戳不进行四舍五入向下取整(floor函数),与Android进行统一,进行sign用毫秒取出秒级时间戳
             */
            if (company.timeStampUseSecond) {//使用秒级
                timestamp = [NSString stringWithFormat:@"%.0f",floor([date timeIntervalSince1970])];
            }
            ts = [NSString stringWithFormat:@"%.0f",floor([date timeIntervalSince1970])];
            /**/
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, timestamp];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_LBS] && self.isTrackLocation) {
            /*
             2018.04.22修改
             开启位置捕获则添加
             不开启则拼接",l="
             */
            NSString *location = [self.trackingInfoService location];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, company.MMASwitch.isTrackLocation ? location : @""];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_OSVS]) {
            
            NSString *osVersion = [[self.trackingInfoService systemVerstion] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, osVersion];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_TERM]) {
            
            NSString *term = [[self.trackingInfoService term] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, term];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_WIFI]) {
            
            NSInteger netStatus = [self.trackingInfoService networkCondition];
            [trackURL appendFormat:@"%@%@%@%d", company.separator, queryArgsKey, company.equalizer,(int)netStatus];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_WIFISSID]) {
            
            NSString *ssid = [[self.trackingInfoService wifiSSID] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer,ssid];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_WIFIBSSID]) {
            
            NSString *bssid = [self.trackingInfoService wifiBSSID];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer,[MMA_Helper md5HexDigest:bssid]];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_SCWH]) {
            
            NSString *scwh = [self.trackingInfoService scwh];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, scwh];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_AKEY]) {
            
            NSString *appKey = [[self.trackingInfoService appKey] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, appKey];
            
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_ANAME]) {
            
            NSString *appName = [[self.trackingInfoService appName] gtm_stringByEscapingForURLArgument];
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, appName];
            
        } else if ([argument.key isEqualToString:TRACKING_KEY_SDKVS]) {
            
            [trackURL appendFormat:@"%@%@%@%@", company.separator, queryArgsKey, company.equalizer, MMA_SDK_VERSION];
        }
    }
    
    // 添加签名加密模块
    NSString *signString = [MMASign sign:trackURL ts:ts sdkv:MMA_SDK_VERSION];
    [MMA_Log log:@"signString: %@"  ,signString];
    [trackURL appendFormat:@"%@%@%@%@", company.separator, company.signature.paramKey, company.equalizer, signString];
    
    if (redirecturl !=nil&&![redirecturl isEqualToString:@""]) {
        [trackURL appendString:redirecturl];
    }
    
    [MMA_Log log:@"trackURL: %@"  ,trackURL];
    
    return trackURL;
    
}
@end
