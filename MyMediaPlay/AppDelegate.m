//
//  AppDelegate.m
//  MyMediaPlay
//
//  Created by Yinjw on 16/9/8.
//  Copyright © 2016年 Yinjw. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioPlayerViewController.h"
#import "VideoPlayerViewController.h"
#import "PhotoAndVideoPickViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController* tabCtrl = [[UITabBarController alloc] init];
    
    AudioPlayerViewController* audioPlayer = [[AudioPlayerViewController alloc] init];
    UINavigationController* audioNaviCtrl = [[UINavigationController alloc] initWithRootViewController:audioPlayer];
    audioNaviCtrl.tabBarItem.title = @"音频播放";
    audioNaviCtrl.tabBarItem.image = [UIImage imageNamed:@"music"];
    
    VideoPlayerViewController* videoPlayer = [[VideoPlayerViewController alloc] init];
    UINavigationController* videoNaviCtrl = [[UINavigationController alloc] initWithRootViewController:videoPlayer];
    videoNaviCtrl.tabBarItem.title = @"视频播放";
    videoNaviCtrl.tabBarItem.image = [UIImage imageNamed:@"film"];
    
    PhotoAndVideoPickViewController* photoAndVideoPicker = [[PhotoAndVideoPickViewController alloc] init];
    UINavigationController* photoAndvideoNaviCtrl = [[UINavigationController alloc] initWithRootViewController:photoAndVideoPicker];
    photoAndVideoPicker.tabBarItem.title = @"照片/视频";
    photoAndVideoPicker.tabBarItem.image = [UIImage imageNamed:@"film"];
    
    tabCtrl.viewControllers = @[audioNaviCtrl, videoNaviCtrl, photoAndvideoNaviCtrl];
    
    self.window.rootViewController = tabCtrl;
    [self.window makeKeyAndVisible];
    
    //后台播放
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //允许远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
