//
//  JHToolsSPay.m
//  JHTools充值支付
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JHToolsPay.h"

@implementation JHToolsProductInfo


+(instancetype) productFromJsonString:(NSString*)js
{
    NSError* err = nil;
    NSDictionary* jsonObj = [NSJSONSerialization JSONObjectWithData:[js dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    
    JHToolsProductInfo* ret = [[JHToolsProductInfo alloc] initWithDict:jsonObj];
    
    return ret;
}

-(instancetype) initWithDict:(NSDictionary*)dict
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.orderID = [dict valueForKey:@"orderID"];
    self.productId = [dict valueForKey:@"productId"];
    self.productName = [dict valueForKey:@"productName"];
    self.productDesc = [dict valueForKey:@"productDesc"];
    
    self.price = [dict valueForKey:@"price"];
    self.buyNum = [[dict valueForKey:@"buyNum"] intValue];
    
    self.roleId = [dict valueForKey:@"roleId"];
    self.roleName = [dict valueForKey:@"roleName"];
    self.roleLevel = [dict valueForKey:@"roleLevel"];
    self.vip = [dict valueForKey:@"vip"];
    self.serverId = [dict valueForKey:@"serverId"];
    self.serverName = [dict valueForKey:@"serverName"];
    
    self.extension = [dict valueForKey:@"extension"];
    
    return self;
}

-(NSDictionary*) toDict
{
    NSMutableDictionary* jsonObj = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   @"orderID": self.orderID,
                                                                                   @"productId": self.productId,
                                                                                   @"productName": self.productName,
                                                                                   @"productDesc": self.productDesc,
                                                                                   @"price": self.price,
                                                                                   @"buyNum": [NSNumber numberWithLong:self.buyNum],
                                                                                   @"roleId": self.roleId,
                                                                                   @"roleName": self.roleName,
                                                                                   @"roleLevel": self.roleLevel,
                                                                                   @"vip": self.vip,
                                                                                   @"serverId": self.serverId,
                                                                                   @"serverName": self.serverName
                                                                                   }];
    
    if (self.extension)
    {
        [jsonObj setValue:self.extension forKey:@"extension"];
    }
    
    return jsonObj;
}

-(NSString*) toJsonString
{
    NSDictionary* jsonObj = [self toDict];
    
    NSError* err = nil;
    NSData* jsdata = [NSJSONSerialization dataWithJSONObject:jsonObj options:kNilOptions error:&err];
    
    return [[NSString alloc] initWithData:jsdata encoding:NSUTF8StringEncoding];
}

@end
