//
//  ScrollViewController.m
//  Demo
//
//  Created by master on 2017/6/27.
//  Copyright © 2017年 Admaster. All rights reserved.
//

#import "ScrollViewController.h"
#import "MobileTracking.h"
@interface ScrollViewController ()
@property (weak, nonatomic) IBOutlet UIView *adView;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//测试u字段点击拼接到最后 2g 有无情况下
    NSString *url = @"http://vxyz.admaster.com.cn/w/a86218,b1729679,c3259,i0,m202,8a2,8b2,h,2j";
    NSLog(@"普通曝光链接");
    [[MobileTracking sharedInstance] view:url];
    NSLog(@"viewability曝光链接");
    [[MobileTracking sharedInstance] view:url ad:_adView];
//    NSLog(@"视频曝光链接");
//    [[MobileTracking sharedInstance] viewVideo:url ad:_adView];
    NSLog(@"点击链接");
    [[MobileTracking sharedInstance] click:url];

    // Do any additional setup after loading the view.
    //
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
