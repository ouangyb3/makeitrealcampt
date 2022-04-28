//
//  NormalViewController.m
//  Demo
//
//  Created by huangli on 2018/12/7.
//  Copyright © 2018年 Admaster. All rights reserved.
//

#import "NormalViewController.h"
#import "SecondViewController.h"

#import "MobileTracking.h"

@interface NormalViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;
@property (weak, nonatomic) IBOutlet UIButton *adView;

@property (weak, nonatomic) IBOutlet UIImageView *testView;
@property (assign, nonatomic)BOOL isPop;

@property (nonatomic, strong)NSString *clickUrl;

@end

//普通点击url
NSString *const normalClickUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//普通曝光url
NSString *const normalViewUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";


//可视化点击url
NSString *const displayClickUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2128485&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//可视化曝光url
NSString *const displayViewUrl = @"http://e.cn.miaozhen.com/r/k=2128485&p=7Q5OK&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&o=";


#define AScreenHeight           ([UIScreen mainScreen].bounds.size.height == 480 ?  (kScreenHeight/667/0.83):(kScreenHeight/667))
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@implementation NormalViewController

- (instancetype)initWithType:(DisplayType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _isPop = NO;
    _bottomScrollView.delegate = self;
    
  _testView.image =  nil;
//   _testView.tag = 999;
//    _testView.backgroundColor=nil;
 //  _testView.image = [UIImage imageNamed:@"landingPageIcon"];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];

}
- (void)loadData {
    //            广告加载出来后调用
    switch (_type) {
        case Normal:
        {
       
            //    普通曝光
          
 
                
       
            [[MobileTracking sharedInstance] view:normalViewUrl ad:_adView impressionType:1 succeed:^(id result) {
                NSLog(@"%@",result);
            } failed:^{
                NSLog(@"failed");
            }];
            
            _clickUrl = [NSString stringWithFormat:@"%@", normalClickUrl];
            self.title = @"曝光及点击";
            
        }
            break;
        case Display:
        {
            
            //            可视化曝光+可视化点击
            //    可视化曝光
           
                [[MobileTracking sharedInstance] view:displayViewUrl ad:_adView succeed:^(id response) {
                      NSLog(@"%@",response);
                } failed:^{
                     NSLog(@"failed");
                }];
             
            _clickUrl = [NSString stringWithFormat:@"%@", displayClickUrl];
            self.title = @"Display可见曝光";
            
        
        }
            break;
        default:
            break;
    }
}

- (IBAction)pushViewController:(id)sender {
    
    _isPop = YES;
    SecondViewController *secondVC = [[SecondViewController alloc]init];
    [self.navigationController pushViewController:secondVC animated:YES];
//    点击
    [[MobileTracking sharedInstance]click:_clickUrl succeed:^(id response) {
        NSLog(@"点击:%@",response);
    } failed:^{
          NSLog(@"failed");
    }];
    
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
