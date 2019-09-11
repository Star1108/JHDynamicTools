//
//  YYJPlatform.h
//  YYJ
//
//  Created by Ferryman on 16/10/9.
//  Copyright © 2016年 YYJia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YYJPlatformDefines.h"



@interface YYJPlatform : NSObject

/**
 *   @brief 获取YYJPlatform实例
 */
+ (YYJPlatform *)defaultPlatform;

@end

#pragma mark    YYJPlatform 初始化配置
@interface YYJPlatform (YYJConfiguration)
/**
 *	@brief  平台初始化方法
 *
 *  @param  appId 游戏在接入联运分配的appId
 *
 *
 */
- (void)initializeWithAppId:(NSString *)appId appScheme:(NSString *)appScheme;

/**
 是否开启Log输出

 @param isShowLog YES 开启; NO 关闭.  默认关闭
 */
- (void)yyjIsShowLog:(BOOL)isShowLog;

/**
 是否禁用注册功能, 禁用后点击注册, 弹出提醒框

 @param isForbidRegister YES 开启; NO 关闭.  默认关闭
 */
- (void)yyjIsForbidRegister:(BOOL)isForbidRegister;

/**
 显示悬浮框
 */
- (void)showFloatWindow;

/**
 隐藏悬浮框
 */
- (void)dismissFloatWindow;
@end
#pragma mark-- 用户部分，登录、注销
@interface YYJPlatform (YYJUserCenter)

/**
 *  @brief YYJPlatform 登录界面入口
 *
 */
- (void)YYJUserLogin;


/**
 *  @brief YYJPlatform 注销, 即退出登录
 *
 */
- (void)YYJUserLogout;

/**
 *  @brief 获取本次登录的token,token即sessionid
 */
- (NSString*)YYJToken;

/**
 *  @brief 获取登录的openuid, 用于标记一个用户
 */
- (NSString*)YYJUserUID;

/**
 *  @brief 当前登录用户名
 */
- (NSString *)YYJLoginUserName;

/**
 *  @brief 当前SDK版本
 */
- (NSString *)YYJSDKVersion;

/**
 提交角色信息接口
 提交的时机为: 每次登录 或者每次退出 或者是 角色等级升级的时候 三个时段都调用那是最好的 .  至少满足角色等级升级的时候调用
 
 @param serverid 服务器编号
 @param serverName 服务器名称
 @param charid 角色ID
 @param rolename 角色名称
 @param rolelevel 角色等级 (必填)
 @param roletime 角色创建时间
 */
- (void)submitRoleInfoWithServerid:(NSString *)serverid andServerName:(NSString *)serverName andCharid:(NSString *)charid andRoleName:(NSString *)rolename andRolelevel:(NSString *)rolelevel andRoleTime:(NSString *)roletime;
@end

#pragma mark 充值、 支付
@interface YYJPlatform (YYJBMaiy)

/**
 *  @brief 充值, 该接口首先获取支付渠道，然后支付并进入web支付页面
 *
 *  @param rmb          充值金额 单位元
 *  @param productID    iTunes 苹果后台配置的内购物品的产品ID
 *  @param name         商品名
 *  @param charid       角色ID
 *  @param serverid     服务器ID
 *  @param info         扩展信息
 *  @param cporderid    游戏商订单ID
 *
 */
- (void)YYJBMaiWithMoney:(NSString *)rmb productID:(NSString *)productID productName:(NSString *)name charId:(NSString *)charid serverId:(NSString *)serverid expandInfo:(NSString *)info cporderId:(NSString *)cporderid;

/**
 配置支付回调
 
 @param url url
 @param application application
 */
- (void)processOrderWithBMaimentResult:(NSURL *)url andAapplication:(UIApplication *)application;

/**
 汇付宝微信支付回调,需调用此方法
 */
- (void)yyjSDKBMaiWillEnterForeground;


@end
