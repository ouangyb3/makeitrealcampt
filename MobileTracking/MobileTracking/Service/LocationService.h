//
//  LocationService.h
//  MobileTracking
//
//  Created by Wenqi on 14-3-11.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService : NSObject


+ (LocationService *)sharedInstance;

- (void)start;
- (void)stop;
- (BOOL)locationKnown;

- (CLLocation *)getCurrentLocation;

@end
