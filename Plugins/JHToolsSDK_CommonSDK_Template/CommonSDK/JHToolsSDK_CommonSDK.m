//
//  JHToolsSDK_CommonSDK.m
//  JHToolsSDK_CommonSDK
//
//  Created by star on 2018/12/19.
//  Copyright © 2018年 star. All rights reserved.
//

#import "JHToolsSDK_CommonSDK.h"
#import "JHToolsUtils.h"
#import "HNPloyProgressHUD.h"

@interface JHToolsSDK_CommonSDK()

@property (nonatomic, copy) NSString *uid;

@end

@implementation JHToolsSDK_CommonSDK

#pragma mark--implement JHToolsPlugin selector,需要的则重新对应方法
-(instancetype)initWithParams:(NSDictionary *)params
{
    //获取info.plist文件中的配置的参数
//    NSString *appID = [params valueForKey:@"game_appid"];
 
    [JHToolsSDK sharedInstance].defaultUser = self;
    [JHToolsSDK sharedInstance].defaultPay  = self;
    
    return self;
}


#pragma mark--UIApplicationDelegate事件
//- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation;

//- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url options:(NSDictionary *)options;

//- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url;
//- (void)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
//
//- (void)applicationWillResignActive:(UIApplication *)application;
//- (void)applicationDidEnterBackground:(UIApplication *)application;
//- (void)applicationWillEnterForeground:(UIApplication *)application;
//- (void)applicationDidBecomeActive:(UIApplication *)application;
//- (void)applicationWillTerminate:(UIApplication *)application;
//
//- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
//- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
//
//- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;
//- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;

#pragma mark --<IJHToolsUser>
- (void) login{
    /*
    [HNPloyProgressHUD showLoading:@"登录验证..."];
    [[JHToolsSDK sharedInstance].proxy accountVerification:@{@"uid":uid,@"ticket":ticket} responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
        if (code != nil && [code isEqualToString:@"1"]) {
            [HNPloyProgressHUD showSuccess:@"登录验证成功！"];
            [JHToolsSDK sharedInstance].proxy.userID = [JHToolsUtils getResponseUidWithDict:data];
            //回调返回参数
            id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
            if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnUserLogin:)]) {
                [sdkDelegate OnUserLogin:data];
            }
        }else{
            [HNPloyProgressHUD showFailure:[NSString stringWithFormat:@"登录验证失败！(%@)", [JHToolsUtils getResponseMsgWithDict:data]]];
        }
    }];
    */
}

- (void) logout{
    
}

- (void) switchAccount{
    
}

- (BOOL) hasAccountCenter{
    return NO;
}

- (void) loginCustom:(NSString*)customData{
}

- (void) showAccountCenter{
}

- (void)submitUserInfo:(JHToolsUserExtraData *)userlog {
    
}


#pragma mark --<IJHToolsPay>
-(void) pay:(JHToolsProductInfo*) profuctInfo{
    [[JHToolsSDK sharedInstance].proxy getOrderWith:profuctInfo responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
        if (code != nil && [code isEqualToString:@"1"]) {
            NSString *orderNo = [JHToolsUtils stringValue:data[@"data"][@"order_no"]];
            //SDK支付代码
        }else{
            [HNPloyProgressHUD showFailure:@"创建聚合订单失败！"];
        }
    }];
}

-(void) closeIAP{
}

-(void) finishTransactionId:(NSString*)transactionId{
}

@end
