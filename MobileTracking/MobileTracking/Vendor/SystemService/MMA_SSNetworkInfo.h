//
//  MMA_SSNetworkInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "MMA_SystemServicesConstants.h"

@interface MMA_SSNetworkInfo : NSObject

// Network Information

// Get Current IP Address
+ (NSString *)currentIPAddress;

// Get Current MAC Address
+ (NSString *)currentMACAddress;

@end
