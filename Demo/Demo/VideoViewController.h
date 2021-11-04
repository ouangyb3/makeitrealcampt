//
//  VideoViewController.h
//  Demo
//
//  Created by huangli on 2018/12/7.
//  Copyright © 2018年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoViewController : UIViewController

- (instancetype)initVideoPlayType:(NSInteger)type title:(NSString *)title viewUrl:(NSString *)viewUrl clickUrl:(NSString *)clickUrl;

@end

NS_ASSUME_NONNULL_END
