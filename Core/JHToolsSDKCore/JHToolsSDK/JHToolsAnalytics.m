//
//  JHToolsAnalytics.m
//  JHTools统计分析
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//
#import "JHToolsAnalytics.h"

@implementation JHToolsDeviceInfo

-(NSDictionary*) toDict
{
    return @{
             @"deviceID": self.deviceID,
             @"appID": [NSNumber numberWithLong:self.appID],
             @"channelID": [NSNumber numberWithLong:self.channelID],
             @"mac": self.mac,
             @"deviceType": self.deviceType,
             @"deviceOS": [NSNumber numberWithLong:self.deviceOS],
             @"deviceDpi": self.deviceDpi
             };
}

-(NSString*) toJsonString
{
    NSDictionary* jsonObj = [self toDict];
    
    NSError* err = nil;
    NSData* jsdata = [NSJSONSerialization dataWithJSONObject:jsonObj options:kNilOptions error:&err];
    
    return [[NSString alloc] initWithData:jsdata encoding:NSUTF8StringEncoding];
}

@end


@implementation JHToolsUserExtraData

+(instancetype) dataFromJsonString:(NSString*)js
{
    NSError* err = nil;
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:[js dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    
    JHToolsUserExtraData* ret = [[JHToolsUserExtraData alloc] initWithDict:jsonObj];
    
    return ret;
}

-(instancetype) initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.dataType = [[dict valueForKey:@"dataType"] intValue];
    self.roleID = [dict valueForKey:@"roleID"];
    self.roleName = [dict valueForKey:@"roleName"];
    self.roleLevel = [dict valueForKey:@"roleLevel"];
    self.serverID = [[dict valueForKey:@"serverID"] intValue];
    self.serverName = [dict valueForKey:@"serverName"];
    self.moneyNum = [[dict valueForKey:@"moneyNum"] intValue];
    
    return self;
}

-(NSDictionary*) toDict
{
    NSDictionary* map = @{
                              @"dataType": [NSNumber numberWithInt:self.dataType],
                              @"roleID": self.roleID,
                              @"roleName": self.roleName,
                              @"roleLevel": self.roleLevel,
                              @"serverID": [NSNumber numberWithInt:self.serverID],
                              @"serverName": self.serverName,
                              @"moneyNum": [NSNumber numberWithInt:self.moneyNum]
                              };
    return map;
}

-(NSString*) toJsonString
{
    NSDictionary* jsonObj = [self toDict];
    
    NSError* err = nil;
    NSData* jsdata = [NSJSONSerialization dataWithJSONObject:jsonObj options:kNilOptions error:&err];
    
    return [[NSString alloc] initWithData:jsdata encoding:NSUTF8StringEncoding];
}

@end

#pragma mark --- JHToolsAnalytics ----

@implementation JHToolsAnalytics

#define CHECKPLUGIN() if (self.analytics == nil) return;

static JHToolsAnalytics* _instance = nil;

+(instancetype) sharedInstance
{
    if (_instance == nil)
    {
        _instance = [[JHToolsAnalytics alloc] init];
    }
    return _instance;
}

//开始关卡的时候，调用
-(void) startLevel:(NSString*)level
{
    CHECKPLUGIN();
    
    [self.analytics startLevel:level];
}

//关卡失败时，调用
-(void) failLevel:(NSString*)level
{
    CHECKPLUGIN();
    
    [self.analytics failLevel:level];
}
//关卡结束时，调用
-(void) finishLevel:(NSString*)level
{
    CHECKPLUGIN();
    
    [self.analytics finishLevel:level];
}

//充值的时候调用
-(void) pay:(double)money coin:(int)coin source:(int)source
{
    CHECKPLUGIN();
    
    [self.analytics pay:money coin:coin source:source];
}

-(void) pay:(double)money item:(NSString*)item num:(int)num price:(double)price source:(int)source
{
    CHECKPLUGIN();
    
    [self.analytics pay:money item:item num:num price:price source:source];
}

//游戏中所有虚拟消费，比如用金币购买某个道具都使用 buy 方法
-(void) buy:(NSString*)item num:(int)num price:(double)price
{
    CHECKPLUGIN();
    
    [self.analytics buy:item num:num price:price];
}

-(void) use:(NSString*)item num:(int)num price:(double)price
{
    CHECKPLUGIN();
    
    [self.analytics use:item num:num price:price];
}

//额外获取虚拟币时，trigger 触发奖励的事件, 取值在 1~10 之间，“1”已经被预先定义为“系统奖励”， 2~10 需要在网站设置含义。
-(void) bonus:(NSString*)item num:(int)num price:(double)price trigger:(int)trigger
{
    CHECKPLUGIN();
    
    [self.analytics bonus:item num:num price:price trigger:trigger];
}


//登录的时候调用
-(void) login:(NSString*)userID
{
    CHECKPLUGIN();
    
    [self.analytics login:userID];
}

//登出的时候调用
-(void) logout
{
    CHECKPLUGIN();
    
    [self.analytics logout];
}

//当玩家建立角色或者升级时，需调用此接口
-(void) levelup:(int)level
{
    CHECKPLUGIN();
    
    [self.analytics levelup:level];
}

@end
