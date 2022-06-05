//
//  AppDelegate.m
//  Demo
//
//  Created by Wenqi on 14-3-17.
//  Copyright (c) 2014年 Admaster. All rights reserved.
//

#import "AppDelegate.h"
#import "MobileTracking.h"
 
//#import "ViewController.h"
//#import "TabCoverViewController.h"
//#import "PageViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//    if (@available(iOS 14, *)) {
//               // iOS14及以上版本需要先请求权限
//               [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
//                   
//                   if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
//                       NSLog(@"同意授权");
//                
//               
//                   }else{
//                       NSLog(@"被拒绝，请在设置-隐私-广告中打开广告跟踪功能");
//                   }
//               }];
//           }

               
 [[MobileTracking sharedInstance] enableLog:YES];

//    ViewController *vc1 = [[ViewController alloc] init];
//    UINavigationController *navCtrl1 = [[UINavigationController alloc] initWithRootViewController:vc1];
//    vc1.view.backgroundColor = [UIColor whiteColor];
//    vc1.title = @"首页";
//    vc1.tabBarItem.image = [UIImage imageNamed:@"xihuan.png"];
//
//
//    TabCoverViewController *vc2 = [[TabCoverViewController alloc] init];
//    UINavigationController *navCtrl2 = [[UINavigationController alloc] initWithRootViewController:vc2];
//    vc2.view.backgroundColor = [UIColor whiteColor];
//    vc2.title = @"Tab";
//    vc2.tabBarItem.image = [UIImage imageNamed:@"liwu.png"];
//
//    PageViewController *vc3 = [[PageViewController alloc] init];
//    UINavigationController *navCtrl3 = [[UINavigationController alloc] initWithRootViewController:vc3];
//    vc3.view.backgroundColor = [UIColor whiteColor];
//    vc3.title = @"Page";
//    vc3.tabBarItem.image = [UIImage imageNamed:@"wode.png"];
//
//    UITabBarController *tabBarCtrl = [[UITabBarController alloc] init];
//    tabBarCtrl.view.backgroundColor = [UIColor whiteColor];
//    tabBarCtrl.viewControllers = @[navCtrl1, navCtrl2, navCtrl3];
//
//    // 设置窗口的跟视图控制器为分栏控制器
//    self.window.rootViewController = tabBarCtrl;
//
//    UITabBar *tabBar = tabBarCtrl.tabBar;
//    tabBar.barStyle = UIBarStyleDefault;
//    tabBar.translucent = NO;
//    tabBar.barTintColor = [UIColor whiteColor];
//    tabBar.tintColor = [UIColor blackColor];
//
//    //    tabBar.selectionIndicatorImage = [UIImage imageNamed:@"left-circle.png"];
//    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[MobileTracking sharedInstance] didEnterBackground];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[MobileTracking sharedInstance] didEnterForeground];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[MobileTracking sharedInstance] willTerminate];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

@end
