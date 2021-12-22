//
//  AdViewResult.h
//  AdCoverDemo
//
//  Created by 黄力 on 2019/5/13.
//  Copyright © 2019 admaster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface MMA_AdViewResult : NSObject

@property (nonatomic, assign) BOOL isShowing; //视 图是否在屏幕内可见
@property (nonatomic, strong) NSString *ad_frame; //adview基于屏幕的frame xXyXwidthXheigh
@property (nonatomic, assign) CGFloat ad_alpha;  // 透明度
@property (nonatomic, assign) BOOL ad_hide; // Hide
@property (nonatomic, assign) BOOL ad_showing; // 0 为没有问题正常显示 1 为尺寸缺失或者没有在Window 上或者出屏幕
@property (nonatomic, assign) CGFloat cover_rate; // 被覆盖率 0-1  cover_frame/ad_frame
@property (nonatomic, strong) NSArray *cover_frame;// Conver rect list


- (instancetype)initWithView:(UIView *)view;
- (void)enqueueView:(UIView *)view;
- (void)calculte;
- (NSString *)addescription;
@end

