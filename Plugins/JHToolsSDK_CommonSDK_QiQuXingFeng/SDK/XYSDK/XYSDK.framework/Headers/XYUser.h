//
//  XYUser.h
//  XYSDK
//
//  Created by evilbeast on 2018/8/14.
//  Copyright © 2018年 xiaoyaogames. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 游戏角色相关事件
typedef NS_ENUM(NSInteger, XYUserExtraDataType)
{
    TYPE_SELECT_SERVER = 1,
    TYPE_CREATE_ROLE,
    TYPE_ENTER_GAME,
    TYPE_LEVEL_UP,
    TYPE_EXIT_GAME
};

@interface XYUserExtraData : NSObject

@property int dataType;
@property (strong, nonatomic)NSString* roleID;
@property (strong, nonatomic)NSString* roleName;
@property (strong, nonatomic)NSString* roleLevel;
@property int serverID;
@property (strong, nonatomic)NSString* serverName;
@property int moneyNum;
@property (strong, nonatomic)NSString* vip;
@property long roleCreateTime;
@property long roleLevelUpTime;

+(instancetype) dataFromJsonString:(NSString*)js;
-(instancetype) initWithDict:(NSDictionary*)dict;
-(NSDictionary*) toDict;
-(NSString*) toJsonString;

@end

