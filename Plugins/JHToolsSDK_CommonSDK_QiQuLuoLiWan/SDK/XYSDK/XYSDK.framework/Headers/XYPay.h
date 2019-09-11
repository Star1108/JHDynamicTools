//
//  XYPay.h
//  XYSDK
//
//  Created by evilbeast on 2018/8/14.
//  Copyright © 2018年 xiaoyaogames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYProductInfo : NSObject

@property (strong, nonatomic)NSString* productId;
@property (strong, nonatomic)NSString* productName;
@property (strong, nonatomic)NSString* productDesc;

@property (strong, nonatomic)NSNumber* price;
@property NSInteger buyNum;
@property NSInteger coinNum;

@property (strong, nonatomic)NSString* roleId;
@property (strong, nonatomic)NSString* roleName;
@property (strong, nonatomic)NSString* roleLevel;
@property (strong, nonatomic)NSString* vip;
@property (strong, nonatomic)NSString* serverId;
@property (strong, nonatomic)NSString* serverName;

@property (strong, nonatomic)NSString* extension;

+(instancetype) productFromJsonString:(NSString*)js;
-(instancetype) initWithDict:(NSDictionary*)dict;
-(NSString*) toJsonString;
-(NSDictionary*) toDict;

@end

