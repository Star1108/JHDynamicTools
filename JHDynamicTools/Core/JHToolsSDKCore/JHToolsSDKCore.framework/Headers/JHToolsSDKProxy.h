//
//  JHToolsProxy.h
//  JHToolsProxy
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JHToolsProductInfo;
@class JHToolsDeviceInfo;
@class JHToolsUserExtraData;

typedef void (^JHToolsRequestCallback)(NSURLResponse* response, id data, NSError* connectionError);

// JHToolsSDK回调接口
@protocol JHToolsSDKDelegate <NSObject>

-(UIView*) GetView;
-(UIViewController*) GetViewController;

@optional

-(void) OnPlatformInit:(NSDictionary*)params;
-(void) OnUserLogin:(NSDictionary*)params;
-(void) OnUserLogout:(NSDictionary*)params;
-(void) OnPayPaid:(NSDictionary*)params;
-(void) OnEventCustom:(NSString*)eventName params:(NSDictionary*)params;

@end

// JHToolsSDK的代理类，用于处理JHToolsSDK的回调事件，数据统计，和JHToolsServer的通讯
@interface JHToolsProxy : NSObject

@property (strong, nonatomic) NSString* userID;

-(id) init;

-(UIView*) GetView;
-(UIViewController*) GetViewController;

-(void) doPlatformInit:(NSDictionary*)param;
-(void) doUserLogin:(NSDictionary*)param;
-(void) doUserLogout:(NSDictionary*)param;
-(void) doPayPaid:(NSDictionary*)param;
-(void) doCustomEvent:(NSString*)eventName params:(NSDictionary*)param;

// 提交设备统计数据
-(void) submitDeviceInfo:(JHToolsDeviceInfo*)device responseHandler:(JHToolsRequestCallback)handler;

// 提交用户统计数据
-(void) submitUserInfo:(JHToolsUserExtraData*)userlog responseHandler:(JHToolsRequestCallback)handler;

//SDK渠道登录后进行JHTools验证
-(void)accountVerification:(NSDictionary*)params responseHandler:(JHToolsRequestCallback) handler;

//SDK渠道支付先到JHTools生成预订单
-(void)getOrderWith:(JHToolsProductInfo *)productInfo responseHandler:(JHToolsRequestCallback) handler;

-(void) submitPushToken:(NSString *)pushToken withUid:(NSString *)uid extension:(NSString *)extension;
// 账号验证方法
//-(void) AccountValidate:(NSDictionary*)params responseHandler:(JHToolsRequestCallback) handler;

//-(void) requestOrder:(JHToolsProductInfo*)params responseHandler:(JHToolsRequestCallback)handler;

// 充值验证
//-(void) PayValidate:(NSDictionary*)params responseHandler:(JHToolsRequestCallback)handler;

/// NSDictionary转换为Http的URL参数
+(NSString*) encodeHttpParams:(NSDictionary*)params encode:(NSStringEncoding)encoding;

- (NSURL*) getJHToolsServerUrl:(NSString*)relativePath;

/**
 * @brief 向JHToolsServer发送http请求
 * @param httpParams 请求参数
 * @param requestPath 请求的路径
 * @param handler 回调函数
 * @param showprogress 是否显示Loading菊花
 */
-(void) sendHttpRequest:(NSDictionary *)httpParams toJHToolsServer:(NSString *)requestPath responseHandler:(JHToolsRequestCallback)handler showProgess:(Boolean)showprogress;

@end

