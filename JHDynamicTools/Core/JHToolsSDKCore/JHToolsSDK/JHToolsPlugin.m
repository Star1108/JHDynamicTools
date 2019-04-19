//
//  JHToolsPlugin.m
//  JHToolsPlugin
//
//  Created by dayong on 15-8-8.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import "JHToolsPlugin.h"


@implementation JHToolsPlugin
{
    NSMutableArray* interfaces;
}

-(instancetype) initWithParams:(NSDictionary*)params
{
    return self;
}

-(BOOL) getBoolForParam:(NSString*)key default:(BOOL)defaultValue
{
    NSNumber* value = [_params valueForKey:key];
    
    if (value)
        return value.boolValue;
    
    return defaultValue;
}

-(UIView*) view
{
    return [[JHToolsSDK sharedInstance].proxy GetView];
}

-(UIViewController*) viewController
{
    return [[JHToolsSDK sharedInstance].proxy GetViewController];
}

-(id) getInterface:(Protocol *)aProtocol
{
    if ([self conformsToProtocol:aProtocol])
    {
        return self;
    }
    
    if (interfaces != nil)
    {
        for (id item in interfaces) {
            if ([item conformsToProtocol:aProtocol])
            {
                return item;
            }
        }
    }
    
    return nil;
}

-(void) registerInterface:(NSObject*)aInterface
{
    if (interfaces == nil)
    {
        interfaces = [NSMutableArray arrayWithObject:aInterface];
    }
    else
    {
        [interfaces addObject:aInterface];
    }
}

-(void) eventPlatformInit:(NSDictionary*) params
{
    [[JHToolsSDK sharedInstance].proxy doPlatformInit:params];
}

-(void) eventUserLogin:(NSDictionary*) params
{
    [[JHToolsSDK sharedInstance].proxy doUserLogin:@{ @"extension":params }];
}

-(void)eventUserLoginAll:(NSDictionary*)params
{
    [[JHToolsSDK sharedInstance].proxy doUserLogin:params];
}

-(void) eventUserLogout:(NSDictionary*) params
{
    [[JHToolsSDK sharedInstance].proxy doUserLogout:params];
}

-(void) eventPayPaid:(NSDictionary*) params
{
    [[JHToolsSDK sharedInstance].proxy doPayPaid:params];
}

-(void) eventCustom:(NSString*)name params:(NSDictionary*)params
{
    [[JHToolsSDK sharedInstance].proxy doCustomEvent:name params:params];
}

@end
