//
//  LocationService.h
//  MobileTracking
//
//  Created by master on 2018/3/8.
//  Copyright © 2018年 Admaster. All rights reserved.
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
