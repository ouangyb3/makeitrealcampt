//
//  VAViewCapture.h
//  MobileTracking
//
//  Created by master on 2017/7/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMA_Company;
@interface VAViewCapture : NSObject
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) MMA_Company *company;
@property (nonatomic, copy, readonly) NSString *uuid;
@property (nonatomic, copy, readonly) NSString *ts;
@property (nonatomic, readonly) BOOL isVideo;


- (instancetype)initWithView:(UIView *)view url:(NSString *)url company:(MMA_Company *)company isVideo:(BOOL)isVideo;

- (NSDictionary *)captureStatus;

@end
