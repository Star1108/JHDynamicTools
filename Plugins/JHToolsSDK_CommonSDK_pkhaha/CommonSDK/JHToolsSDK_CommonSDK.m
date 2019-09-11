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
#import "SDK_51WanSY/SDK_51WanSY.h"

@interface JHToolsSDK_CommonSDK()<WanManagerDelegate>

@property (nonatomic, copy) NSString *gameid;
@property (nonatomic, copy) NSString *channelUid;//渠道返回的id
@property (nonatomic, copy) NSString *uid;//JHToolsid

@end

@implementation JHToolsSDK_CommonSDK

#pragma mark--implement JHToolsPlugin selector,需要的则重新对应方法
-(instancetype)initWithParams:(NSDictionary *)params
{
    self.gameid = [params valueForKey:@"gameid"];
    [[WanManager shareInstance] initSDKWithGameID:self.gameid delegate:self];
    [JHToolsSDK sharedInstance].defaultUser = self;
    [JHToolsSDK sharedInstance].defaultPay  = self;
    NSLog(@"插件初始化成功,params=%@", params);
    return self;
}


#pragma mark -- <IJHToolsUser>
- (void) login{
    NSLog(@"-------开始调用渠道登录-------");
    [[WanManager shareInstance] showLoginView];
}

- (void) logout{
    [[WanManager shareInstance] hidenTip];
    id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
    if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnUserLogout:)]) {
        [sdkDelegate OnUserLogout:nil];
    }
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

#pragma mark -- <IJHToolsPay>
-(void) pay:(JHToolsProductInfo*) profuctInfo{
    [[JHToolsSDK sharedInstance].proxy getOrderWith:profuctInfo responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
        if (code != nil && [code isEqualToString:@"1"]) {
            NSString *orderNo = [JHToolsUtils stringValue:data[@"data"][@"order_no"]];
            WanPayModel *payModel = [[WanPayModel alloc] init];
            payModel.goodsName = profuctInfo.productName;//商品名称
            payModel.money = [profuctInfo.price stringValue];//充值金额
            payModel.balance = @"0";//余额
            payModel.cpData = orderNo;//厂商透传信息
            payModel.gameid = self.gameid;//游戏id
            payModel.gain= @"0";//元宝数
            payModel.uid= self.channelUid;//用户id
            payModel.serverid = profuctInfo.serverId;//区服id
            payModel.roleName = profuctInfo.roleName;//游戏角色名
            payModel.desc = profuctInfo.productDesc;//商品描述
            payModel.productID = profuctInfo.productId;//产品在iTunes中的id
            [[WanManager shareInstance] payWithPayModel:payModel];
        }else{
            [HNPloyProgressHUD showFailure:@"创建聚合订单失败！"];
        }
    }];
}

-(void)submitUserInfo:(JHToolsUserExtraData *)data{
    WanUserInfo *userInfo = [[WanUserInfo alloc] init];
    userInfo.uid = self.channelUid;
    userInfo.serverID = [NSString stringWithFormat:@"%d", data.serverID];
    userInfo.serVerName = data.serverName;
    userInfo.roleID = data.roleID;
    userInfo.roleName = data.roleName;
    userInfo.roleLevel = data.roleLevel;
    [[WanManager shareInstance] submitUserInfo:userInfo];
}

-(void) closeIAP{
    
}

-(void) finishTransactionId:(NSString*)transactionId{
    
}

#pragma mark --WanManagerDelegate
-(void)wanSDKReturnResult:(NSDictionary *)result forType:(WanSDKReturnResultType)type{
    id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
    if (type == WanSDKReturnResultTypeLogin) {
        [self loginResult:result];
    }else if (type == WanSDKReturnResultTypePay){
        if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnPayPaid:)]) {
            [sdkDelegate OnPayPaid:nil];
        }
    }
}

-(void)loginResult:(NSDictionary *)result{
    self.channelUid = result[@"uid"];
    [HNPloyProgressHUD showLoading:@"登录验证..."];
    [[JHToolsSDK sharedInstance].proxy accountVerification:@{@"uid":self.channelUid,@"ticket":result[@"ticket"]} responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        
        NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
        if (code != nil && [code isEqualToString:@"1"]) {
            [HNPloyProgressHUD showSuccess:@"登录验证成功！"];
            [JHToolsSDK sharedInstance].proxy.userID = [JHToolsUtils getResponseUidWithDict:data];
            //显示悬浮窗
            [[WanManager shareInstance] showTipWithUid:self.channelUid];
            //回调返回参数
            id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
            if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnUserLogin:)]) {
                [sdkDelegate OnUserLogin:data];
            }
        }else{
            [HNPloyProgressHUD showFailure:@"登录验证失败！"];
        }
    }];
}

// UIApplicationDelegate事件
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation{
    return [[WanManager shareInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url options:(NSDictionary *)options{
    return [[WanManager shareInstance] application:application openURL:url options:options];
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url{
    return [[WanManager shareInstance] application:application handleOpenURL:url];
}

@end
