//
//  JHToolsPlugin.h
//  JHTools插件定义
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import "JHToolsSDK.h"

@class JHToolsUserExtraData;

// JHToolsPlugin 插件接口
@protocol JHToolsPluginProtocol

-(instancetype) initWithParams:(NSDictionary*)params;

@optional

-(BOOL) isInitCompleted;
-(void) setupWithParams:(NSDictionary*)params;
-(void) submitExtraData:(JHToolsUserExtraData*)data;

// UIApplicationDelegate事件
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url options:(NSDictionary *)options;

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url;
- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

@end

@interface JHToolsPlugin : NSObject<JHToolsPluginProtocol>

@property (nonatomic, copy) NSDictionary* params;

-(instancetype) initWithParams:(NSDictionary*)params;

-(BOOL) getBoolForParam:(NSString*)key default:(BOOL)defaultValue;

-(UIView*) view;
-(UIViewController*) viewController;

-(id) getInterface:(Protocol *)aProtocol;

-(void) eventPlatformInit:(NSDictionary*) params;
-(void) eventUserLogin:(NSDictionary*) params;
-(void) eventUserLogout:(NSDictionary*) params;
-(void) eventPayPaid:(NSDictionary*) params;
-(void) eventCustom:(NSString*)name params:(NSDictionary*)params;

@end
