//
//  JHToolsShare.h
//  JHToolsShare
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHToolsShareInfo : NSObject

-(id)initWithDictionary:(NSDictionary*)dict;

-(NSString*) title;
-(NSString*) content;
-(NSString*) url;
-(NSString*) imgUrl;

-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)value forKey:(NSString *)key;

@end

//分享接口
@protocol IJHToolsShare

-(void)share:(JHToolsShareInfo*)params;

@end

//分享组件
@protocol IJHToolsShareComponent

-(NSArray*)supportPlatforms;
-(void)shareTo:(NSString*)platform shareParams:(JHToolsShareInfo*)params;

@end

@interface JHToolsShare : NSObject<IJHToolsShare>

/// 分享接口实现
@property (strong, nonatomic) NSObject<IJHToolsShare>* share;

/// 获取JHToolsSDKShare的单例
+(instancetype) sharedInstance;

-(void) registerShareComponent:(NSObject<IJHToolsShareComponent>*)shareComponent;

-(void)share:(JHToolsShareInfo*)params;
-(NSArray*)supportPlatforms;
-(void)shareTo:(NSString*)platform shareParams:(JHToolsShareInfo*)params;

@end
