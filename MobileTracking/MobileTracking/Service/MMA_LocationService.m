//
//  MMA_LocationService.m
//  MobileTrackingDevice
//
//  Created by master on 2018/3/8.
//  Copyright © 2018年 Admaster. All rights reserved.
//

#import "MMA_LocationService.h"
#import "MMA_Macro.h"

@interface MMA_LocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isStart;

@end
#define LOGGG(FORMAT, ...) //printf("----------%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@implementation MMA_LocationService
+ (MMA_LocationService *)sharedInstance {
    static MMA_LocationService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentLocation = [[CLLocation alloc] init];
        [self start];
    }
    return self;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
//        不主动弹出弹窗，需要在允许的时候获取
//        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [_locationManager requestWhenInUseAuthorization];
//        }
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    }
    return _locationManager;
}
- (void)start {
    LOGGG(@"开始定位");
    //判断用户定位服务是否开启
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
//        不主动弹出弹窗，需要在允许的时候获取
//        if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [self.locationManager requestWhenInUseAuthorization];
//        }
        [self.locationManager startUpdatingLocation];
        if(!self.isStart) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stop];
            });
            self.isStart = YES;
        }
        return;
    }
    LOGGG(@"停止stop定位");

    [self stop];
}

#pragma mark - <CLLocationManagerDelegate>
//
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    LOGGG(@"定位更新1");

    CLLocation *location = [locations lastObject];
    LOGGG(@"定位更新%f",[location.timestamp timeIntervalSinceNow]);
    if (fabs([location.timestamp timeIntervalSinceNow]) <= LOCATION_UPDATE_INTERVAL) {
        self.currentLocation = location;
        [self stop];
    } else {
        self.currentLocation = location;
        [self start];
    }
}

//
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    LOGGG(@"定位更新2");
    if (fabs([newLocation.timestamp timeIntervalSinceNow]) <= LOCATION_UPDATE_INTERVAL) {
        self.currentLocation = newLocation;
        [self stop];
    } else {
        self.currentLocation = newLocation;
        [self start];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    LOGGG(@"定位失败");
    [self stop];
}


/**
 * 停止定位
 */
-(void)stop {
    LOGGG(@"停止定位");
    self.isStart = NO;
    [_locationManager stopUpdatingLocation];
    _locationManager = nil; //这句话必须加上，否则可能会出现调用多次的情况
}
- (BOOL)locationKnown {
    if (round(self.currentLocation.coordinate.latitude) != 0 && round(self.currentLocation.coordinate.longitude) != 0) {
        return YES;
    } else {
        return NO;
    }
}
- (CLLocation *)getCurrentLocation{
    if (self.locationKnown == YES) {
        if (fabs([self.currentLocation.timestamp timeIntervalSinceNow]) >= LOCATION_UPDATE_INTERVAL) {
            LOGGG(@"%f超过%d",fabs([self.currentLocation.timestamp timeIntervalSinceNow]),LOCATION_UPDATE_INTERVAL);
            [self start];
        }
        return self.currentLocation;
    } else {
        LOGGG(@"没有位置信息");
        [self start];
        return nil;
    }
}


@end



