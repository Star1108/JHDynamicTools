//
//  AppDelegate.m
//  Demo
//
//  Created by star on 2018/12/14.
//  Copyright © 2018年 star. All rights reserved.
//

#import "AppDelegate.h"
#import <JHToolsSDKCore/JHToolsSDKCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ////初始化应该在程序启动时调用, 也就是在didFinishLaunchingWithOptions方法里
    NSDictionary *sdkconfig = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"JHToolsSDK"];
    [[JHToolsSDK sharedInstance] initWithParams:sdkconfig];
    [[JHToolsSDK sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[JHToolsAnalytics sharedInstance] startLevel:@"1"];
    return YES;
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[JHToolsSDK sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    [[JHToolsSDK sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[JHToolsSDK sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[JHToolsSDK sharedInstance] application:application didReceiveLocalNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[JHToolsSDK sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[JHToolsSDK sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[JHToolsSDK sharedInstance] applicationWillEnterForeground:application];
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    return [[JHToolsSDK sharedInstance] application:application supportedInterfaceOrientationsForWindow:window];
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[JHToolsSDK sharedInstance] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[JHToolsSDK sharedInstance] applicationWillTerminate:application];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[JHToolsSDK sharedInstance] application:application handleOpenURL:url];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[JHToolsSDK sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
