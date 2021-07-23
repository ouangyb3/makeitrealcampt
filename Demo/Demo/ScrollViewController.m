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
//    NSString *url = @"http://vxyz.admaster.com.cn/pppp,2g1111,2j1111,2t1111,2k1111,2l1111,2m1111,2n1111,2o1111,2r1111,2s1111,2f1111,2a1111,1g1111,2d1111,2j1111,2h1111,2v60,2u1.8,2w15,2x0001,va1,b123456,uhttp://redirecturl.com";
    /* 去噪测试
     以下参数不覆盖原值: AdviewabilityEnable AdviewabilityConfigArea AdviewabilityConfigThreshold AdviewabilityVideoDuration AdviewabilityVideoProgressPoint AdviewabilityRecord
     */
//    NSString *url = @"http://v.admaster.com.cn/i/a90981,b1899467,c2,i0,m202,8a2,8b2,h,2j,2u2,2v50,2w15,2x1111,2d1234,va1";

    /* 去噪测试
     以下参数不覆盖原值: AdviewabilityEnable AdviewabilityConfigArea AdviewabilityConfigThreshold AdviewabilityVideoDuration AdviewabilityVideoProgressPoint AdviewabilityRecord
     */
    NSString *url = @"http://v.admaster.com.cn/i/a90981,b1899467,c2,i0,m202,8a2,8b2,h,2p,2jtt,2w15,2x1101,2d1234,va1,2g0101,uhttp://www.baidu.com";
    //    NSString *url2 = @"http://v.miaozhen.com/i/a90981,p1899467,c2,i0,m202,8a2,8b2,h,2p,2jtt,2w15,2x1101,2d1234,va1,2g0101";
    NSString *url2 = @"http://v.admaster.com.cn/i/a90981,b1899467,c2,i0,m202,8a2,8b2,h,2p,2jtt,2w15,2x1101,2d1234,va1,2g0101";


//    NSLog(@"普通曝光链接");
//    [[MobileTracking sharedInstance] view:url];
    
    static BOOL vb = YES;
//    if(vb = !vb) {
        printf("\n-----------------------viewability曝光链接\n");
        [[MobileTracking sharedInstance] view:url ad:_adView];
//    [[MobileTracking sharedInstance] viewVideo:@"http://test.m.cn.miaozhen.com/x/k=test1234&p=test5678&va=1&vb=15&vj=1111&vi=5&vh=80&o=www.baidu.com" ad:_adView videoPlayType:2];

//        [[MobileTracking sharedInstance] view:url2 ad:_adView];

        
       
//    } else {
//        printf("\n-----------------------viewability视频曝光链接\n");
//        [[MobileTracking sharedInstance] viewVideo:url ad:_adView videoPlayType:11];
//    }
    
//    NSLog(@"视频曝光链接");
//    [[MobileTracking sharedInstance] viewVideo:url ad:_adView];
//    NSLog(@"点击链接");
//    [[MobileTracking sharedInstance] click:url];

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
