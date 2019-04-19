//
//  JHToolsAnalytics.h
//  JHTools统计分析接口
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 游戏角色相关事件
typedef NS_ENUM(NSInteger, UserOperateCode)
{
    OP_CREATE_ROLE = 1,
    OP_ENTER_GAME,
    OP_LEVEL_UP,
    OP_EXIT
};

/// 游戏角色相关事件
typedef NS_ENUM(NSInteger, UserExtraDataType)
{
    TYPE_SELECT_SERVER = 1,//选择区服
    TYPE_CREATE_ROLE,//创建角色
    TYPE_ENTER_GAME,//进入游戏
    TYPE_LEVEL_UP,//等级提升
    TYPE_EXIT_GAME,//退出游戏
    TYPE_ENTER_FUBEN,//进入游戏副本
    TYPE_EXIT_FUBEN,//退出游戏副本
    TYPE_VIP_UP//VIP升级
};

/// 设备信息
@interface JHToolsDeviceInfo : NSObject

@property (strong, nonatomic)NSString* deviceID;
@property int appID;
@property int channelID;
@property (strong, nonatomic)NSString* mac;
@property (strong, nonatomic)NSString* deviceType;
@property int deviceOS;
@property (strong, nonatomic)NSString* deviceDpi;

-(NSDictionary*) toDict;
-(NSString*) toJsonString;

@end


/***
 * 用户扩展数据
 * 已经登录的角色相关数据
 * 有的渠道需要统计角色相关数据
 * @author dayong
 */
@interface JHToolsUserExtraData : NSObject

@property int dataType;
@property (strong, nonatomic)NSString* roleID;
@property (strong, nonatomic)NSString* roleName;
@property (strong, nonatomic)NSString* roleLevel;
@property int serverID;
@property (strong, nonatomic)NSString* serverName;
@property int moneyNum;
@property long roleCreateTime;
@property long roleLevelUpTime;
@property (strong, nonatomic)NSString* vip;

+(instancetype) dataFromJsonString:(NSString*)js;
-(instancetype) initWithDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
-(NSString*) toJsonString;

@end

@protocol IJHToolsAnalytics

//开始关卡的时候，调用
-(void) startLevel:(NSString*)level;
//关卡失败时，调用
-(void) failLevel:(NSString*)level;
//关卡结束时，调用
-(void) finishLevel:(NSString*)level;

//充值的时候调用
-(void) pay:(double)money coin:(int)coin source:(int)source;
-(void) pay:(double)money item:(NSString*)item num:(int)num price:(double)price source:(int)source;
//游戏中所有虚拟消费，比如用金币购买某个道具都使用 buy 方法
-(void) buy:(NSString*)item num:(int)num price:(double)price;

//消耗物品的时候，调用
-(void) use:(NSString*)item num:(int)num price:(double)price;

//额外获取虚拟币时，trigger 触发奖励的事件, 取值在 1~10 之间，“1”已经被预先定义为“系统奖励”， 2~10 需要在网站设置含义。
-(void) bonus:(NSString*)item num:(int)num price:(double)price trigger:(int)trigger;


//登录的时候调用
-(void) login:(NSString*)userID;

//登出的时候调用
-(void) logout;

//当玩家建立角色或者升级时，需调用此接口
-(void) levelup:(int)level;

@end


@interface JHToolsAnalytics : NSObject<IJHToolsAnalytics>

/// 统计接口实现
@property (strong, nonatomic) id analytics;

+(instancetype) sharedInstance;

@end


