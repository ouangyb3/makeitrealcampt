//
//  MMA_TrackingInfoService.m
//  MobileTracking
//
//  Created by Wenqi on 14-3-14.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "MMA_TrackingInfoService.h"
#import "MMA_SSNetworkInfo.h"

#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "MMA_Reachability.h"
#import "MMA_Macro.h"
#import <SystemConfiguration/CaptiveNetwork.h>

 


@implementation MMA_TrackingInfoService

+ (MMA_TrackingInfoService *)sharedInstance {
    static MMA_TrackingInfoService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    
    
         
    });
    return _sharedInstance;
}
 

- (NSString *)macAddress
{
    NSString *macAddress = [MMA_SSNetworkInfo currentMACAddress];
    return macAddress ? macAddress : @"";
}

- (NSString *)ipAddress
{
    return [MMA_SSNetworkInfo currentIPAddress];
}

- (NSString *)systemVerstion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)idfa
{
    NSString *idfa = nil;
    if (@available(iOS 14, *)) {
 
                   if ([ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusAuthorized) {
                       idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                   }
        
           } else {
              
               if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                   idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
               }
           }
    

    return idfa ? idfa : @"";
}

- (NSString *)scwh
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    return [NSString stringWithFormat:@"%.2fx%.2f", rect.size.width * scale, rect.size.height * scale];
}

- (NSString *)appKey
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleIdentifierKey];
}

- (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}
 
 

- (NSString *)location
{
 
        return @"";
 
   
}

- (NSString *)term
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform?platform:@"";
}

- (NSString *)idfv
{
    if ([UIDevice.currentDevice respondsToSelector:@selector(identifierForVendor)]) {
        return [UIDevice.currentDevice.identifierForVendor UUIDString];
    }
    return @"";
}

- (NSInteger)networkCondition
{

//    NetworkStatus status = [[MMA_Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    NetworkStatus status = [[MMA_Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            return NETWORK_STATUS_NO;
            break;
        case ReachableViaWiFi:
            return NETWORK_STATUS_WIFI;
            break;
        case ReachableViaWWAN:
            return NETWORK_STATUS_3G;
            break;
    }
}

- (NSString *)wifiSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for ( NSString *ifname in ifs ) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if ( info && [info count] ) break;
    }
    NSString *ssid = [(NSDictionary *)info objectForKey:@"SSID"];
    if(ssid==nil) {
        return @"";
    }
    return ssid;
}
- (NSString *)wifiBSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for ( NSString *ifname in ifs ) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if ( info && [info count] ) break;
    }
    NSString *bssid = [(NSDictionary *)info objectForKey:@"BSSID"];
    if(bssid==nil) {
        return @"";
    }
    bssid = bssid.length < 17 ? [self standardFormateMAC:bssid] : bssid;

    return [[bssid stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];

}

- (NSString *)standardFormateMAC:(NSString *)MAC {
    @try {
        NSArray * subStr = [MAC componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":-"]];
        NSMutableArray * subStr_M = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString * str in subStr) {
            if (1 == str.length) {
                NSString * tmpStr = [NSString stringWithFormat:@"0%@", str];
                [subStr_M addObject:tmpStr];
            } else {
                [subStr_M addObject:str];
            }
        }
        
        NSString * formateMAC = [subStr_M componentsJoinedByString:@":"];
        
        return [formateMAC lowercaseString];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        return @"00:00:00:00:00:00";
    }
}
@end
