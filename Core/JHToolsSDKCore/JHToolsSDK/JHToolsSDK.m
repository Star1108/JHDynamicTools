//
//  JHToolsSDK.m
//  JHToolsSDK
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import "JHToolsSDK.h"
#import "JHToolsPlugin.h"
#import "JHToolsUser.h"
#import "JHToolsPay.h"
#import "JHToolsAnalytics.h"

#import <CommonCrypto/CommonDigest.h>


@interface JHToolsSDK()

@property (strong, nonatomic) NSMutableArray* plugins;

@end

@implementation JHToolsSDK

static JHToolsSDK* _instance = nil;

+(JHToolsSDK*) sharedInstance
{
    if (_instance == nil)
    {
        _instance = [[JHToolsSDK alloc] init];
    }
    return _instance;
}

- (id)init {
    self.plugins = [NSMutableArray array];
    self.supportedOrientations = UIInterfaceOrientationMaskLandscape;
    return self;
}

-(void) initWithParams:(NSDictionary*)params
{
    if (params == nil) return;
    
    self.sdkParams = params;
    
    // TODO 从配置文件读取需要加载的插件
    NSArray* configPlugins = [params valueForKey:@"Plugins"];
    for (NSDictionary* pluginConfig in configPlugins) {
        NSString* className = [pluginConfig valueForKey:@"name"];
        if (![className hasPrefix:@"JHToolsSDK_"])
        {
            className = [@"JHToolsSDK_" stringByAppendingString:className];
        }
        Class pluginClass = NSClassFromString(className);
        if (pluginClass != nil)
        {
            JHToolsPlugin* plugin = [pluginClass alloc];
            [plugin setParams:pluginConfig];
            [self registerPlugin:[plugin initWithParams:pluginConfig]];
        }
        else
        {
            NSLog(@"unable loadPlugin: %@", className);
        }
    }
    
    if (self.proxy == nil)
    {
        self.proxy = [[JHToolsProxy alloc] init];
    }
}

-(int) channelId
{
    return [[_sdkParams valueForKey:@"Channel"] intValue];
}

-(NSString*) channelName
{
    return [_sdkParams valueForKey:@"ChannelName"];
}

-(BOOL) IsSupportFunction:(SEL)function
{
    for (NSObject<JHToolsPluginProtocol>* plugin in _plugins) {
        if ([plugin respondsToSelector:function])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isInitCompleted
{
    for (NSObject<JHToolsPluginProtocol>* plugin in _plugins) {
        if ([plugin respondsToSelector:@selector(isInitCompleted)])
        {
            if (![plugin isInitCompleted])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

-(void) registerPlugin:(NSObject<JHToolsPluginProtocol>*)plugin
{
    if (plugin)
    {
        [_plugins addObject:plugin];
    }
}

-(NSObject*) getInterfaceByName:(NSString*)name andProtocol:(Protocol *)aProtocol
{
    for (JHToolsPlugin* plugin in _plugins) {
        NSString* pluginClassName = NSStringFromClass([plugin class]);
        
        if (![name hasPrefix:@"JHToolsSDK_"])
        {
            name = [@"JHToolsSDK_" stringByAppendingString:name];
        }
        if ([pluginClassName compare:name] == NSOrderedSame)
        {
            if (aProtocol == nil)
                return plugin;
            else
            {
                return [plugin getInterface:aProtocol];
            }
        }
    }
    
    return nil;
}

-(NSArray*) plugins
{
    return _plugins;
}

-(void) setupWithParams:(NSDictionary*)params
{
    for (NSObject<JHToolsPluginProtocol>* plugin in _plugins) {
        if ([plugin respondsToSelector:@selector(setupWithParams:)])
        {
            [plugin setupWithParams:params];
        }
    }
}

-(void) submitExtraData:(JHToolsUserExtraData*)data
{
    if (_defaultUser != nil) {
        [_defaultUser submitUserInfo:data];
    }
    
    if (_plugins == nil)
        return;
    
    for (NSObject<JHToolsPluginProtocol>* plugin in _plugins) {
        if ([plugin respondsToSelector:@selector(submitExtraData:)])
        {
            [plugin submitExtraData:data];
        }
    }
   
    [self.proxy submitUserInfo:data
               responseHandler:^(NSURLResponse *response, id data, NSError *error) {
                   if (error)
                   {
                       NSLog(@"Fail to submitExtraData: %@", error.description);
                   }
                   else
                   {
                       NSLog(@"submitExtraData: %@", data);
                   }
               }];
}

-(void)login
{
    if (_defaultUser != nil)
    {
        [_defaultUser login];
    }
}

-(void)logout
{
    if (_defaultUser != nil)
    {
        [_defaultUser logout];
    }
}

-(void)switchAccount
{
    if (_defaultUser != nil)
    {
        [_defaultUser switchAccount];
    }
}

- (BOOL) hasAccountCenter
{
    if (_defaultUser != nil)
    {
        return [_defaultUser hasAccountCenter];
    }
    
    return NO;
}


- (void) loginCustom:(NSString*)customData
{
    if (_defaultUser != nil)
    {
        return [_defaultUser loginCustom:customData];
    }
}

- (void) showAccountCenter
{
    if (_defaultUser != nil)
    {
        return [_defaultUser showAccountCenter];
    }
}

-(void) submitUserInfo:(JHToolsUserExtraData*)userlog{
    if (_defaultUser != nil) {
        return [_defaultUser submitUserInfo:userlog];
    }
}

-(void)openIAP:(NSDictionary *)params
{
    if (_defaultPay && [_defaultPay respondsToSelector:@selector(openIAP:)])
    {
        [_defaultPay openIAP:params];
    }
}

-(void) pay:(JHToolsProductInfo*) productInfo
{
    if (self.defaultPay) {
        [self.defaultPay pay:productInfo];
    }
    /*
    if (self.proxy == nil)
        return;
    
    [self.proxy requestOrder:productInfo
             responseHandler:^(NSURLResponse *response, id responseJson, NSError *requestError) {
                 if (requestError)
                 {
                     NSLog(@"requestOrder Error: %@", requestError);
                 }
                 else
                 {
                     if ([[responseJson valueForKey:@"state"] intValue] == 1)
                     {
                         id data = [responseJson valueForKey:@"data"];
                         productInfo.orderID = [[data valueForKey:@"orderID"] stringValue];
                         productInfo.extension = [data valueForKey:@"extension"];
                         [self.defaultPay pay:productInfo];
                     }
                     else
                     {
                         NSLog(@"requestOrder Fail: %@", responseJson);
                     }
                 }
             }];
     */
}

-(void) finishTransaction:(NSString*)transactionIdentifier
{
    if (self.defaultPay != nil && [self.defaultPay respondsToSelector:@selector(finishTransactionId:)])
    {
        [self.defaultPay finishTransactionId:transactionIdentifier];
    }
}

@end
