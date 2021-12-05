//
//  LocationService.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "LocationService.h"

@interface LocationService() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isStart;

@end

@implementation LocationService

+ (LocationService *)sharedInstance {
    static LocationService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (instancetype)init {
    if (self = [super init]) {
        _currentLocation = [[CLLocation alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [self start];
    }
    return self;
}

- (void)start {
    [self.locationManager startUpdatingLocation];
    if(!self.isStart)
        [NSTimer scheduledTimerWithTimeInterval:10
                                         target:self
                                       selector:@selector(stop)
                                       userInfo:nil
                                        repeats:NO];
    self.isStart = YES;
}

- (void)stop {
    self.isStart = NO;
    [self.locationManager stopUpdatingLocation];
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
        if (abs([self.currentLocation.timestamp timeIntervalSinceNow]) > 120) {
            [self start];
        }
        return self.currentLocation;
    } else {
        [self start];
        return nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    if ( abs([newLocation.timestamp timeIntervalSinceNow]) < 120) {
        self.currentLocation = newLocation;
        [self stop];
    } else {
        
        
        [self start];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self stop];
}


@end
