//
//  JHToolsUtils.h
//  JHToolsSDK_Template
//
//  Created by Star on 2018/3/17.
//  Copyright © 2018年 Star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHToolsUtils : NSObject

+(NSString *)getResponseCodeWithDict:(NSDictionary *)dict;

+(NSString *)getResponseMsgWithDict:(NSDictionary *)dict;

+(NSString *)getResponseUidWithDict:(NSDictionary *)dict;

+(NSString *)stringValue:(NSString *)str;

+(BOOL)isDictionaryEmpty:(NSDictionary *)dict;

+(NSString *)dictionaryToJson:(NSDictionary *)dic;

+(NSString *)encode:(NSString *)string;

@end
