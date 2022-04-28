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
#import <AVKit/AVKit.h>
@interface VideoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;

@property (nonatomic, strong)UIView *avMovieView;
@property(nonatomic,strong)AVPlayer * player;
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
     _avMovieView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320)];
    _avMovieView.backgroundColor  = [UIColor blackColor];
    
         [_bottomScrollView addSubview:_avMovieView];
      
      
      AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:url];
       _player = [AVPlayer playerWithPlayerItem:playerItem];
      AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
      playerLayer.frame = _avMovieView.bounds;
      playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

      [_avMovieView.layer addSublayer:playerLayer];
    
    if (_type == 0 || _type == 1) {
     
             
      
//        广告开始播放的情况下调用；网络的广告资源需要等资源加载成功开始播放的情况下调用
            //    可视化视频曝光
        [[MobileTracking sharedInstance] viewVideo:_viewUrl ad:_avMovieView videoPlayType:_type succeed:^(id result) {
            NSLog(@"%@",result);
        } failed:^{
              NSLog(@"failed");
        }];
     
  
    }

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishedPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

//    点击广告，触发事件，进入下一个页面
     
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
 
    [_avMovieView  addGestureRecognizer:tableViewGesture];
    
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
        if (_type == 0 || _type == 1|| self.view.tag ==1) {
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [_player play];
    }
    
        }
}

//停止监测
- (void)finishedPlay {
    [[MobileTracking sharedInstance]stop:_viewUrl];
    for (UIGestureRecognizer * gesture in _avMovieView.gestureRecognizers) {
        [gesture removeTarget:self action:@selector(tapView:)];
    }
    _remindLabel.text = @"status:视频播放中...";
       NSURL *url = [[NSBundle mainBundle] URLForResource:@"videoAd.mp4" withExtension:nil];
     AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
      AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
       playerLayer.frame = _avMovieView.bounds;
       playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        for (CALayer *layer in _avMovieView.layer.sublayers) {
        if ([layer class] == [AVPlayerLayer class]) {
        [layer removeFromSuperlayer];
        }
        }

     
       [_avMovieView.layer addSublayer:playerLayer];
      [_player play];

}

//点击url
- (void)tapView:(UITapGestureRecognizer *)tap {
    
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            self.view.tag =1;
           [_player play];
        
                   [[MobileTracking sharedInstance] viewVideo:_viewUrl ad:_avMovieView videoPlayType:_type succeed:^(id response) {
                       NSLog(@"%@",response);
                   } failed:^{
                         NSLog(@"failed");
                   }];
             
           _remindLabel.text = @"status:前贴片广告播放中...";
    } else {
        //    可视化视频点击
        [[MobileTracking sharedInstance]click:_clickUrl succeed:^(id response) {
            NSLog(@"%@",response);
        } failed:^{
              NSLog(@"failed");
        }];
        
        [_player pause];
        SecondViewController *secondVC = [[SecondViewController alloc]init];
        [self.navigationController pushViewController:secondVC animated:YES];
        
    }

}


 

@end
