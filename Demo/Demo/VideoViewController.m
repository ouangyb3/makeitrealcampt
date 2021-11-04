//
//  VideoViewController.m
//  Demo
//
//  Created by huangli on 2018/12/7.
//  Copyright © 2018年 Admaster. All rights reserved.
//

#import "VideoViewController.h"
#import "SecondViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "MobileTracking.h"

@interface VideoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;

@property (nonatomic, strong)   MPMoviePlayerController *mPMoviePlayerController;;
@property (nonatomic, strong)UIView *tapview;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, strong)NSString *navtitle;
@property (nonatomic, strong)NSString *viewUrl;
@property (nonatomic, strong)NSString *clickUrl;

@end



@implementation VideoViewController

- (instancetype)initVideoPlayType:(NSInteger)type title:(NSString *)title viewUrl:(NSString *)viewUrl clickUrl:(NSString *)clickUrl
{
    self = [super init];
    if (self) {
        _navtitle = title;
        _viewUrl = viewUrl;
        _clickUrl = clickUrl;
        _type = type;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _navtitle;
    
    _bottomScrollView.delegate = self;
    
    [self initViews];
    
}
- (void)initViews {
    
//    视频
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Advertisement.mp4" withExtension:nil];
    _mPMoviePlayerController = [[MPMoviePlayerController alloc]initWithContentURL:url];
    _mPMoviePlayerController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320);
    [_bottomScrollView addSubview:_mPMoviePlayerController.view];
    if (_type == 0 || _type == 1) {
        [_mPMoviePlayerController play];
//        广告开始播放的情况下调用；网络的广告资源需要等资源加载成功开始播放的情况下调用
            //    可视化视频曝光
        [[MobileTracking sharedInstance] viewVideo:_viewUrl ad:_mPMoviePlayerController.view videoPlayType:_type];
     
       
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishedPlay) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

//    点击广告，触发事件，进入下一个页面
    _tapview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320)];
    [_mPMoviePlayerController.view addSubview:_tapview];
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [_tapview addGestureRecognizer:tableViewGesture];
    
//    播放的内容提醒：广告&正片
    _remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 50)];
    if (_type == 0 || _type == 1) {
        _remindLabel.text = @"status:前贴片广告播放中...";
    } else {
        _remindLabel.text = @"点击视频窗口开始播放广告";
    }
    [_bottomScrollView addSubview:_remindLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (_mPMoviePlayerController.playbackState == MPMoviePlaybackStatePaused) {
        [_mPMoviePlayerController play];
    }
    
}

//停止监测
- (void)finishedPlay {
    [[MobileTracking sharedInstance]stop:_viewUrl];
    if (_tapview) {
        [_tapview removeFromSuperview];
    }
    _remindLabel.text = @"status:视频播放中...";
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"videoAd.mp4" withExtension:nil];
    _mPMoviePlayerController.contentURL = url;
    [_mPMoviePlayerController play];

}

//点击url
- (void)tapView:(UITapGestureRecognizer *)tap {
    
    if (_mPMoviePlayerController.playbackState == MPMoviePlaybackStateStopped) {
        [_mPMoviePlayerController play];
        [[MobileTracking sharedInstance] viewVideo:_viewUrl ad:_mPMoviePlayerController.view videoPlayType:_type];
       
        _remindLabel.text = @"status:前贴片广告播放中...";
    } else {
        //    可视化视频点击
        [[MobileTracking sharedInstance]click:_clickUrl];
        
        [_mPMoviePlayerController pause];
        SecondViewController *secondVC = [[SecondViewController alloc]init];
        [self.navigationController pushViewController:secondVC animated:YES];
        
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
