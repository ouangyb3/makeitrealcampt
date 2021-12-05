//
//  SSNetworkInfo.m
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SSNetworkInfo.h"

@implementation SSNetworkInfo

// Get Current IP Address
+ (NSString *)currentIPAddress {
    
    return @"";
}

// Get Current MAC Address
+ (NSString *)currentMACAddress {
    char addr[64];
    int                 mib[6];
    size_t              len;
    char                buf[1024];
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return FALSE;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return FALSE;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return FALSE;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    sprintf(addr, "%.2X:%.2X:%.2X:%.2X:%.2X:%.2X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
    NSString *macAddress = [[NSString alloc] initWithCString:addr encoding:NSASCIIStringEncoding];
    return macAddress;
}

@end
