//
//  JHToolsShare.m
//  JHToolsShare
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JHToolsSDK.h"
#import "JHToolsShare.h"
#import "JHToolsPlugin.h"

@implementation JHToolsShareInfo
{
    NSMutableDictionary* _dict;
}

-(id)init
{
    if (self = [super init])
    {
        _dict = [NSMutableDictionary dictionary];
        return self;
    }
    
    return nil;
}

-(id)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init])
    {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        return self;
    }
    
    return nil;
}

-(NSString*)title
{
    return [_dict valueForKey:@"title"];
}

-(NSString*)content
{
    return [_dict valueForKey:@"content"];
}

-(NSString*)url
{
    return [_dict valueForKey:@"url"];
}

-(NSString*)imgUrl
{
    return [_dict valueForKey:@"imgUrl"];
}

-(id)valueForKey:(NSString *)key
{
    return [_dict valueForKey:key];
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [_dict setValue:value forKey:key];
}

@end

#pragma mark ---- JHToolsShare ----

@interface JHToolsShare()
@property NSMutableDictionary* sharePlatforms;
@end

@implementation JHToolsShare

#define CHECKPLUGIN(RET) if (self.share == nil) return RET;

static JHToolsShare* _instance = nil;

+(instancetype) sharedInstance
{
    if (_instance == nil)
    {
        _instance = [[JHToolsShare alloc] init];
    }
    return _instance;
}

-(instancetype) init
{
    self.sharePlatforms = [NSMutableDictionary dictionary];
    
    for (JHToolsPlugin* plugin in [[JHToolsSDK sharedInstance] plugins])
    {
        NSObject<IJHToolsShareComponent>* shareComponent = [plugin getInterface:@protocol(IJHToolsShareComponent)];
        if (shareComponent)
        {
            [self registerShareComponent:shareComponent];
        }
    }
    
    return [super init];
}

-(void) registerShareComponent:(NSObject<IJHToolsShareComponent>*)shareComponent
{
    NSArray* platforms = [shareComponent supportPlatforms];
    
    for (NSString* platform in platforms)
    {
        [_sharePlatforms setObject:shareComponent forKey:platform];
    }
}

-(NSArray*)supportPlatforms
{
    return [self.sharePlatforms allKeys];
}

-(void)shareTo:(NSString*)platform shareParams:(JHToolsShareInfo*)params
{
    NSObject<IJHToolsShareComponent>* shareComponent = [self.sharePlatforms objectForKey:platform];
    if (shareComponent == nil)
    {
        NSLog(@"Unsupported platform: \"%@\"", platform);
    }
    
    [shareComponent shareTo:platform shareParams:params];
}

-(void)share:(JHToolsShareInfo*)params
{
    CHECKPLUGIN();
    
    return [self.share share:params];
}

@end
