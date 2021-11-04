//
//  AdViewMonitor.m
//  AdCoverDemo
//
//  Created by 黄力 on 2019/5/13.
//  Copyright © 2019 admaster. All rights reserved.
//

#import "MMA_AdViewMonitor.h"
#import "UIView+MMA_Monitor.h"

@interface MMA_AdViewMonitor()

@property (nonatomic, weak) UIView *monitorView;
@property (nonatomic, strong) MMA_AdViewResult *result;

@end

@implementation MMA_AdViewMonitor

- (MMA_AdViewResult *)monitorWithAdView:(UIView *)view {

    _monitorView = view;
    
    _result = [[MMA_AdViewResult alloc] initWithView:view];
    
    if (self.result.isShowing) {
        [self monitorView:view];
    }
    [self.result calculte];
    return self.result;
}

- (void)monitorView:(UIView *)view {
    
    [self travereRelateViews:_monitorView];

}

/**
 *  节点遍历 保存相交面积(相对Window)
 *  以及所有视图层之上的所有节点(部分跳过遍历)
 */
- (void)travereRelateViews:(UIView *)view {
    
    @try {
        
        if (view == nil) {
            return ;
        }
        
        UIView *superView = view.superview;
        
        if (view == _monitorView.window) {
            return ;
        }
//        无superview 添加最后的window
        if (superView == nil) {
            superView = _monitorView.window;

        }
//        遍历父view的所有view
        NSInteger index = [superView.subviews indexOfObject:view];
        UIView *nextView = nil;
        if (index + 1 < superView.subviews.count) {
            nextView = superView.subviews[index + 1];
            /*  去最低子节点  */
            /* 存在子节点并且当前父节点的clipsToBounds为NO，YES 所有子view被框在父view内不用遍历 */
            if ([nextView mma_isShowing] && nextView.subviews.count != 0 && nextView.clipsToBounds == NO) {
                nextView = nextView.subviews[0];
            }
        } else {
            /* 无相邻节点 遍历父节点 */
            nextView = superView;
        }

        [self.result enqueueView:nextView];
        [self travereRelateViews:nextView];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

@end
