//
//  AdViewResult.m
//  AdCoverDemo
//
//  Created by 黄力 on 2019/5/13.
//  Copyright © 2019 admaster. All rights reserved.
//

#import "MMA_AdViewResult.h"
#import "UIView+MMA_Monitor.h"
#import "MMA_AdHelper.h"
#import "MMA_AdCalSize.h"

@interface MMA_AdViewResult ()

@property (nonatomic, weak) UIView *adView;

@property (nonatomic, strong)NSMutableSet *viewList;
@property (nonatomic, strong)NSMutableSet *viewCoverList_Format;
@property (nonatomic, strong) NSMutableSet *viewCoverList;

@property (nonatomic) CGRect showOnWindow; //在父视图中的可见frame
@property (nonatomic) CGRect originFrame; //初始frame on superview
@property (nonatomic) CGFloat coveredSize;  //覆盖

@end

@implementation MMA_AdViewResult

#pragma mark - init
- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        if (view == nil) {
            return nil;
        }
        self.adView = view;
        self.coveredSize = 0;
        [self.viewList addObject:[view mma_properties]];
        
//        view有没有正常显示
        if (!view.mma_isShowing || !view.mma_isSuperviewsShowing || view.mma_width == 0 || view.mma_height == 0 || !CGRectIntersectsRect([view mma_showOnKeyWindow], [UIApplication sharedApplication].keyWindow.frame)) {
            self.isShowing = NO;
        } else {
            self.isShowing = YES;
        }
        
//        使用CGFloat小数点，小数点14位可能出现偏差，所以修改为float
         self.ad_showing =  !self.isShowing;
        /**开启下面方法 视图跑到窗口外时会出现bug*/
//        self.ad_showing =  !self.isShowing || view.mma_sHeight != view.mma_height || view.mma_sWidth != view.mma_width;

        self.showOnWindow = view.mma_showOnKeyWindow;
        self.originFrame = view.frame;
        
    }
    return self;
}

#pragma mark - method
- (void)enqueueView:(UIView *)view {
    //
    @try {
        
        if (!_adView) {
            return ;
        }
        /* 如果这个视图没有显示就不添加进list */
        if (!view.mma_isShowing) {
            return ;
        }
        [self.viewList addObject:view.mma_properties];
        
        CGRect coverRect = [self.adView mma_intersectionWithView:view];
      //  NSLog(@"ViewSizeWidth:%f",coverRect.size.width);
        if (!CGRectEqualToRect(coverRect, CGRectZero)&&coverRect.size.width>0) {
            if (![self.adView mma_isSuper:view]) {
//                限制最大view数量阈值
                if (self.viewCoverList.count < 60) {
                    [self.viewCoverList addObject:NSStringFromCGRect(coverRect)];
                }
//                限制最大格式化的view数量阈值
                if (self.viewCoverList_Format.count < 60) {
                    [self.viewCoverList_Format addObject:[MMA_AdHelper formatRect:coverRect]];
                }
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (void)calculte {
    
    if (!self.viewCoverList.count) {
        self.coveredSize = 0;
        return ;
    }
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
    NSArray *viewCoverList = [_viewCoverList sortedArrayUsingDescriptors:@[sd]];
    MMA_AdCalSize *sizeCal  = [[MMA_AdCalSize alloc] init];
    CGFloat res = [sizeCal calSize:viewCoverList];
    self.coveredSize = res;

}

#pragma mark - set
- (NSMutableSet *)viewList {
    if(!_viewList) {
        _viewList = [NSMutableSet setWithCapacity:0];
    }
    return _viewList;
}

- (NSMutableSet *)viewCoverList {
    if (!_viewCoverList) {
        _viewCoverList = [NSMutableSet setWithCapacity:0];
    }
    return _viewCoverList;
}
- (NSMutableSet *)viewCoverList_Format {
    if(!_viewCoverList_Format) {
        _viewCoverList_Format = [NSMutableSet setWithCapacity:0];
    }
    return _viewCoverList_Format;
}

#pragma mark - output
- (BOOL)isShowing {
    return _isShowing;
}

- (NSString *)ad_frame {
    return [MMA_AdHelper formatRect:self.showOnWindow];
}

- (CGFloat)ad_alpha {
    return self.adView.alpha;
}

- (BOOL)ad_hide {
    return self.adView.hidden;
}

- (BOOL)ad_showing {
    return _ad_showing;
}

- (CGFloat)cover_rate {
    
    /*  总区域 */
    CGFloat areaSize = self.originFrame.size.width * self.originFrame.size.height;
    /*  可视区域 */
    CGFloat showSize = self.showOnWindow.size.width * self.showOnWindow.size.height;
    
    if (areaSize == 0) {
        return 1;
    } else {
        return (areaSize - showSize + self.coveredSize) / areaSize;

    }
    
    
}
- (NSArray *)cover_frame {
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
    return [self.viewCoverList_Format sortedArrayUsingDescriptors:@[sd]];

}

- (NSString *)addescription {
    return [NSString stringWithFormat:@"\n原始frame: %@\nalpha: %f\nis_hidden: %d\nad_showing: %d\n被覆盖率: %f\n",self.ad_frame,self.ad_alpha,self.ad_hide,self.ad_showing,self.cover_rate];
}

@end
