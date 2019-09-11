//
//  WanManager.h
//  WanAppStroeSDK
//
//  Created by Star on 2017/5/17.
//  Copyright © 2017年 liuluoxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WanManagerDelegate.h"
#import "WanPayModel.h"

@interface WanManager : NSObject

/**
 * 获取单例实体对象，所有方法都使用该实例对象进行调用
 */
+(instancetype)shareInstance;

/**
 * 获取SDK配置信息
 * @pragram gameid游戏ID
 */
-(void)initSDKWithGameID:(NSString *)gameid delegate:(id<WanManagerDelegate>)wanDelegate;

/**
 * 显示登录视图
 * @pragram view 登录视图的父视图
 * @pragram gameID 游戏ID
 * @pragram loginSuccess 登录成功后的回调
 */
-(void)showLoginView;

/**
 * 显示服务窗点击图标
 * @pragram gameid 游戏ID
 * @pragram uid 用户id(此ID为登录后获取的uid)
 */
-(void)showTipWithUid:(NSString *)uid;

/**
 *隐藏服务窗点击图标
 */
-(void)hidenTip;

/**
 * 支付窗口
 * @view  支付窗口所在父视图
 * @payModel 支付model
 */
-(void)payWithPayModel:(WanPayModel *)payModel;

/**
 * 上传游戏数据
 *  @userInfo  上报角色对象模型
 */
-(void)submitUserInfo:(WanUserInfo *)userInfo;

/*
 *  @method 支付回跳调用方法
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString*)sourceApplication
         annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url;
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

@end
