//
//  JHToolsSDK.m
//  JHToolsSDK
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import "JHToolsSDK+AppDelegate.h"
#import "JHToolsPlugin.h"

#import <CommonCrypto/CommonDigest.h>

@implementation JHToolsSDK (AppDelegate)

- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)])
        {
            [plugin application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(applicationWillResignActive:)])
        {
            [plugin applicationWillResignActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(applicationDidEnterBackground:)])
        {
            [plugin applicationDidEnterBackground:application];
        }
    }
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(applicationWillEnterForeground:)])
        {
            [plugin applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(applicationDidBecomeActive:)])
        {
            [plugin applicationDidBecomeActive:application];
        }
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(applicationWillTerminate:)])
        {
            [plugin applicationWillTerminate:application];
        }
    }
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)])
        {
            return [plugin application:application supportedInterfaceOrientationsForWindow:window];
        }
    }
    return UIInterfaceOrientationMaskAll;
}

////////// 推送通知相关接口

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)])
        {
            [plugin application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)])
        {
            [plugin application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:didReceiveLocalNotification:)])
        {
            [plugin application:application didReceiveLocalNotification:notification];
        }
    }
}
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:didReceiveRemoteNotification:)])
        {
            [plugin application:application didReceiveRemoteNotification:userInfo];
        }
    }
}

//////////// openURL相关接口
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL ret = NO;
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            ret |= [plugin application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        }
    }
    
    return ret;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url options:(NSDictionary *)options
{
    BOOL ret = NO;
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:openURL:options:)]) {
            ret |= [plugin application:application openURL:url options:options];
        }
    }
    
    return ret;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL ret = NO;
    for (NSObject<JHToolsPluginProtocol>* plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(application:handleOpenURL:)]) {
            ret |= [plugin application:application handleOpenURL:url];
        }
    }
    
    return ret;
}


@end
