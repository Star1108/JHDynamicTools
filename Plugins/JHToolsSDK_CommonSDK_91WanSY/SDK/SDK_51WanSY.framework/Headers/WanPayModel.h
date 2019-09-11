//
//  WanPayModel.h
//  Wan669SDKKit
//
//  Created by Star on 2017/3/17.
//  Copyright © 2017年 liuluoxing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WanUserInfo : NSObject

@property (nonatomic, copy) NSString *uid;//用户ID
@property (nonatomic, copy) NSString *serverID;//区服ID
@property (nonatomic, copy) NSString *serVerName;//区服名
@property (nonatomic, copy) NSString *roleName;//角色名
@property (nonatomic, copy) NSString *roleID;//角色id
@property (nonatomic, copy) NSString *roleLevel;//角色等级

@end


@interface WanPayModel : NSObject

@property (nonatomic, copy) NSString *goodsName;//商品名称
@property (nonatomic, copy) NSString *money;//充值金额  单位为元
@property (nonatomic, copy) NSString *balance;//余额
@property (nonatomic, copy) NSString *cpData;//厂商透传信息
@property (nonatomic, copy) NSString *gameid;//游戏id
@property (nonatomic, copy) NSString *gain;//元宝数
@property (nonatomic, copy) NSString *uid;//用户id
@property (nonatomic, copy) NSString *serverid;//区服id
@property (nonatomic, copy) NSString *roleName;//游戏角色名
@property (nonatomic, copy) NSString *desc;//商品描述
@property (nonatomic, copy) NSString *productID;//产品在iTunes中的id

@end
