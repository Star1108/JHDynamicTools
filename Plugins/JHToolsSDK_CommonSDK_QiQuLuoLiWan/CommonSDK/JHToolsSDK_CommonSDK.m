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
#import <XYSDK/XYSDK.h>

@interface JHToolsSDK_CommonSDK()<XYSDKDelegate>

@property (nonatomic, copy) NSString *channelUid;//渠道返回的id
@property (nonatomic, copy) NSString *uid;//JHToolsid

@end

@implementation JHToolsSDK_CommonSDK

#pragma mark--implement JHToolsPlugin selector,需要的则重新对应方法
-(instancetype)initWithParams:(NSDictionary *)params
{
    //获取info.plist文件中的配置的参数
    NSString *appID = [params valueForKey:@"qiqu_appid"];
    NSString *appKey = [params valueForKey:@"qiqu_appkey"];
    NSString *channelID = [params valueForKey:@"qiqu_channel"];
 
    // 初始化参数
    [[XYSDK sharedInstance]initSDKWithAppId:appID
                                     AppKey:appKey
                                  ChannelId:channelID
                               AppURLScheme:[[NSBundle mainBundle] bundleIdentifier]
     ];
    // delegate
    [XYSDK sharedInstance].delegate = self;
    
    [JHToolsSDK sharedInstance].defaultUser = self;
    [JHToolsSDK sharedInstance].defaultPay  = self;
    
    return self;
}


#pragma mark--UIApplicationDelegate事件
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation{
    return [[XYSDK sharedInstance]applicationHandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL*)url options:(NSDictionary *)options{
    return [[XYSDK sharedInstance] applicationHandleOpenURL:url];
}

#pragma mark --<IJHToolsUser>
- (void) login{
    [[XYSDK sharedInstance] login];
}

- (void) logout{
    [[XYSDK sharedInstance] logout];
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

- (void)submitUserInfo:(JHToolsUserExtraData *)data {
    XYUserExtraData *extraData = [[XYUserExtraData alloc] init];
    extraData.dataType = data.dataType;
    extraData.roleID = data.roleID;
    extraData.roleName =  data.roleName;
    extraData.roleLevel =  data.roleLevel;
    extraData.serverName =  data.serverName;
    extraData.serverID = data.serverID;
    extraData.moneyNum = data.moneyNum;
    extraData.vip = data.vip;
    extraData.roleCreateTime = data.roleCreateTime;
    extraData.roleLevelUpTime = data.roleLevelUpTime;
    [[XYSDK sharedInstance] submitExtraData:extraData];
}


#pragma mark --<IJHToolsPay>
-(void) pay:(JHToolsProductInfo*) profuctInfo{
    if ([XYSDK sharedInstance].isLogin) {
        [[JHToolsSDK sharedInstance].proxy getOrderWith:profuctInfo responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
            NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
            if (code != nil && [code isEqualToString:@"1"]) {
                NSString *orderNo = [JHToolsUtils stringValue:data[@"data"][@"order_no"]];
                // 发起支付订单
                XYProductInfo* productInfo = [[XYProductInfo alloc] init];
                productInfo.productId = profuctInfo.productId; //充值商品ID，游戏内的商品ID
                productInfo.productName = profuctInfo.productName; // 商品名称，比如100元宝，500钻石...
                productInfo.productDesc = profuctInfo.productDesc; // 商品描述，比如 充值100元宝，赠送20元宝
                productInfo.price = profuctInfo.price; // 充值金额(单位：元)
                productInfo.buyNum = 1;  // 购买数量，一般都是1
                productInfo.coinNum = profuctInfo.coinNum; // 玩家当前身上剩余的游戏币
                productInfo.serverId = profuctInfo.serverId;  // 玩家所在服务器的ID
                productInfo.serverName = profuctInfo.serverName; // 玩家所在服务器的名称
                productInfo.roleId = profuctInfo.roleId;  // 玩家角色ID
                productInfo.roleName = profuctInfo.roleName;  // 玩家角色名称
                productInfo.roleLevel = profuctInfo.roleName; // 玩家角色等级
                productInfo.vip = profuctInfo.vip;   // 玩家vip等级
                productInfo.extension = orderNo;  // 支付成功之后，支付后端原样返回给游戏服务器
                [[XYSDK sharedInstance] pay:productInfo];
            }else{
                [HNPloyProgressHUD showFailure:[NSString stringWithFormat:@"创建聚合订单失败！(%@)", [JHToolsUtils getResponseMsgWithDict:data]]];
            }
        }];
    }else{
        [[XYSDK sharedInstance] login];
    }
}

-(void) closeIAP{
}

-(void) finishTransactionId:(NSString*)transactionId{
}

#pragma mark --<XYSDKDelegate>
- (void) xysdkReturnResult:(NSDictionary *) result forCode: (XYSDKKitReturnResultCode)code{
    id sdkDelegate = [JHToolsSDK sharedInstance].delegate;
    switch (code) {
        case XYSDKKitReturnResultLoginCode://登录成功
            [self loginSuccessWithResult:result];
            break;
        case XYSDKKitReturnResultLogoutCode:
        {
            if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnUserLogout:)]){
                [sdkDelegate OnUserLogout:result];
            }
        }
            break;
        default:
        {
            if (sdkDelegate && [sdkDelegate respondsToSelector:@selector(OnPayPaid:)]){
                [sdkDelegate OnPayPaid:result];
            }
        }
            break;
    }
}

-(void)loginSuccessWithResult:(NSDictionary *)result{
    NSLog(@"SDK登录返回数据：%@", result);
    self.channelUid = [JHToolsUtils stringValue:result[@"uid"]];
    [HNPloyProgressHUD showLoading:@"登录验证..."];
    [[JHToolsSDK sharedInstance].proxy accountVerification:@{@"uid":self.channelUid,@"ticket":[JHToolsUtils stringValue:result[@"token"]]} responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        NSString *code = [JHToolsUtils getResponseCodeWithDict:data];
        if (code != nil && [code isEqualToString:@"1"]) {
            [HNPloyProgressHUD showSuccess:@"登录验证成功！"];
            self.uid = [JHToolsUtils getResponseUidWithDict:data];
            [JHToolsSDK sharedInstance].proxy.userID = self.uid;
            
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

@end
