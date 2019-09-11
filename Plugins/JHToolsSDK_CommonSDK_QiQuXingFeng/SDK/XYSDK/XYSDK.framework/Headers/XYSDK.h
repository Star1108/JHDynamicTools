//
//  XYSDK.h
//  XYSDK
//
//  Created by iceleaf on 2017/4/20.
//  Copyright © 2017年 xiaoyaogames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "XYUser.h"
#import "XYPay.h"

//XYSDK返回结果Code
typedef enum XYSDKKitReturnResultCode : NSInteger {
    XYSDKKitReturnResultLoginCode = 90000,  // 登录
    XYSDKKitReturnResultLogoutCode = 90001,  // 注销
    XYSDKKitReturnResultPaySuccessCode = 90002,  //支付成功
    XYSDKKitReturnResultPayCancelCode = 90003,  //支付取消
    XYSDKKitReturnResultPayFailCode = 90004,  //支付失败
} XYSDKKitReturnResultCode;

@class XYSDK;

@protocol XYSDKDelegate <NSObject>

@optional
-(void) xysdkReturnResult:(NSDictionary *) result forCode: (XYSDKKitReturnResultCode)code;
@end


// XYSDK
@interface XYSDK : UIViewController

+(XYSDK *)sharedInstance;

@property (nonatomic, assign) id <XYSDKDelegate>delegate;
@property BOOL isLogin;

// 初始化
-(void)initSDKWithAppId:(NSString *)appid AppKey:(NSString *)appKey ChannelId: (NSString *)channelId AppURLScheme:(NSString *)appUrlScheme;

#pragma mark -- 帐号登录接口 --
-(void) login;
-(void) logout;
-(void) switchAccount;

#pragma mark -- 支付充值接口 --
-(void) pay:(XYProductInfo*) productInfo;


#pragma mark -- 扩张接口 --
-(void) submitExtraData:(XYUserExtraData*)data;


//支付宝专用。应用之间接收同步通知结果。
-(BOOL) applicationHandleOpenURL:(NSURL *)url;

// 内部DEBUG专用
-(void) useDebug:(BOOL)debug;

@end
