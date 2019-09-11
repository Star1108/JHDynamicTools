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
#import <YYJPlatform/YYJPlatform.h>

@interface JHToolsSDK_CommonSDK()

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *channelAppid;

@end

@implementation JHToolsSDK_CommonSDK

#pragma mark--implement JHToolsPlugin selector,需要的则重新对应方法
-(instancetype)initWithParams:(NSDictionary *)params
{
    //获取info.plist文件中的配置的参数
    self.channelAppid = [params valueForKey:@"appid"];
 
    [JHToolsSDK sharedInstance].defaultUser = self;
    [JHToolsSDK sharedInstance].defaultPay  = self;
    
    return self;
}


#pragma mark--UIApplicationDelegate事件
-(void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    /*
     初始化完成之后，会有初始化完成通知（ YYJPlatformInitDidFinishedNotification ）开发者在该回调方法中做登录操作
     该通知应注册在初始化之前
     */
    //添加一个初始化通知观察者，初始化结束后，登录等操作务必在收到该通知后调用
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(yyjPlatformInitFinished) name:YYJPlatformInitDidFinishedNotification object:nil];
    
    // 添加一个支付成功通知观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(yyjBMaiSuccessful) name:YYJPlatformBMaiSuccessfulNotification object:nil];
    
    // 添加一个支付失败通知观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(yyjBMaiFail) name:YYJPlatformBMaiFailNotification object:nil];
    
    
    //添加一个登录成功通知观察者，调用悬浮框等操作务必在收到该通知后调用
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(yyjPlatformLogin) name:YYJPlatformLoginNotification object:nil];
    
    //添加一个注销成功通知观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(yyjPlatformLogout) name:YYJPlatformLogoutNotification object:nil];
    
    // SDK初始化
    [[YYJPlatform defaultPlatform] initializeWithAppId:self.channelAppid appScheme:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[YYJPlatform defaultPlatform]processOrderWithBMaimentResult:url andAapplication:application];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NS Dictionary<NSString*, id> *)options{
    [[YYJPlatform defaultPlatform]processOrderWithBMaimentResult:url andAapplication:app];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[YYJPlatform defaultPlatform]yyjSDKBMaiWillEnterForeground];
}

#pragma mark --<IJHToolsUser>
- (void) login{
    [[YYJPlatform defaultPlatform] YYJUserLogin];
}

- (void) logout{
    [[YYJPlatform defaultPlatform] YYJUserLogout];
    [[YYJPlatform defaultPlatform]dismissFloatWindow];
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
            [[YYJPlatform defaultPlatform] YYJBMaiWithMoney:[profuctInfo.price stringValue] productID:[JHToolsUtils stringValue:profuctInfo.productId] productName:[JHToolsUtils stringValue:profuctInfo.productName] charId:[JHToolsUtils stringValue:profuctInfo.roleId] serverId:[JHToolsUtils stringValue:profuctInfo.serverId] expandInfo:orderNo cporderId:orderNo];
        }else{
            [HNPloyProgressHUD showFailure:@"创建聚合订单失败！"];
        }
    }];
}

-(void) closeIAP{
}

-(void) finishTransactionId:(NSString*)transactionId{
}

#pragma mark ----通知回调方法
- (void)yyjPlatformInitFinished {
    
}

- (void)yyjPlatformLogin {
     [HNPloyProgressHUD showLoading:@"登录验证..."];
     [[JHToolsSDK sharedInstance].proxy accountVerification:@{@"uid":uid,@"ticket":ticket} responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
     NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
     if (code != nil && [code isEqualToString:@"1"]) {
     [HNPloyProgressHUD showSuccess:@"登录验证成功！"];
     [JHToolsSDK sharedInstance].proxy.userID = [JHToolsUtils getResponseUidWithDict:data];
     [[YYJPlatform defaultPlatform]showFloatWindow];
     //回调返回参数
     id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
     if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnUserLogin:)]) {
     [sdkDelegate OnUserLogin:data];
     }
     }else{
     [HNPloyProgressHUD showFailure:[NSString stringWithFormat:@"登录验证失败！(%@)", [JHToolsUtils getResponseMsgWithDict:data]]];
     }
     }];
}

- (void)yyjPlatformLogout {
    
}

- (void)yyjPlatformBMaiSuccessful {
    
}

- (void)yyjPlatformBMaiFail {
    
}

@end
