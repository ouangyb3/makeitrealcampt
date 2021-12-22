//
//  MMAViewController.m
//  Demo
//
//  Created by 黄力 on 2019/7/31.
//  Copyright © 2019 Admaster. All rights reserved.
//

#import "MMAViewController.h"
#import "NormalViewController.h"
#import "VideoViewController.h"

@interface MMAViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSArray *titleArray;

@end


//Video可见曝光视频点击url
NSString *const videoClickUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//Video可见曝光视频曝光url
NSString *const videoViewUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video可见曝光（自动播放）视频点击Url
NSString *const videoClickAutoUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video可见曝光（自动播放）视频曝光Url
NSString *const videoViewAutoUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video普通曝光（自动播放）视频点击Url
NSString *const videoRegularClickUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video普通曝光（自动播放）视频曝光Url
NSString *const videoRegularUrl = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video普通曝光（手动播放）视频点击Url
NSString *const videoRegularClickUrlTap = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

//video普通曝光（手动播放）视频曝光Url
NSString *const videoRegularUrlTap = @"http://tyfx.m.cn.miaozhen.com/x/k=2122669&p=7P5QE&dx=__IPDX__&rt=2&ns=__IP__&ni=__IESID__&v=__LOC__&xa=__ADPLATFORM__&tr=__REQUESTID__&mo=__OS__&m0=__OPENUDID__&m0a=__DUID__&m1=__ANDROIDID1__&m1a=__ANDROIDID__&m2=__IMEI__&m4=__AAID__&m5=__IDFA__&m6=__MAC1__&m6a=__MAC__&nd=__DRA__&np=__POS__&nn=__APP__&nc=__VID__&nf=__FLL__&ne=__SLL__&ng=__CTREF__&nx=__TRANSID__&o=";

@implementation MMAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.titleArray = @[@"曝光及点击",@"Display可见曝光",@"Video可见曝光",@"Video可见曝光（Auto-play）",@"Video可见曝光（Click-to-play）"];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableviewCellIdentifier"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.titleArray[indexPath.row]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:{
            NormalViewController *normalVC = [[NormalViewController alloc] initWithType:Normal];
            [self.navigationController pushViewController:normalVC animated:YES];
        }
            break;
        case 1:
        {
            NormalViewController *normalVC = [[NormalViewController alloc] initWithType:Display];
            [self.navigationController pushViewController:normalVC animated:YES];
        }
            break;
        case 2:
        {
            VideoViewController *videoVC = [[VideoViewController alloc] initVideoPlayType:0 title:_titleArray[2] viewUrl:videoViewUrl clickUrl:videoClickUrl];
            [self.navigationController pushViewController:videoVC animated:YES];
        }
            break;
        case 3:
        {
            VideoViewController *videoVC = [[VideoViewController alloc] initVideoPlayType:1 title:_titleArray[3] viewUrl:videoViewAutoUrl clickUrl:videoClickAutoUrl];
            [self.navigationController pushViewController:videoVC animated:YES];
        }
            break;
        case 4:
        {
            VideoViewController *videoVC = [[VideoViewController alloc] initVideoPlayType:2 title:_titleArray[4] viewUrl:videoViewAutoUrl clickUrl:videoClickAutoUrl];
            [self.navigationController pushViewController:videoVC animated:YES];
        }
            break;
        default:
            break;
    }
    
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
