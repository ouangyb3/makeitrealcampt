//
//  NormalViewController.h
//  Demo
//
//  Created by huangli on 2018/12/7.
//  Copyright © 2018年 Admaster. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSInteger {
    Normal = 0,
    Display
} DisplayType;

@interface NormalViewController : UIViewController

- (instancetype)initWithType:(DisplayType)type;

@property (nonatomic, assign)DisplayType type;

@end

NS_ASSUME_NONNULL_END
