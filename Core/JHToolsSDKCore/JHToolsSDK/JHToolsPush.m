//
//  JHToolsPush.m
//  JHToolsSDKCore
//
//  Created by xiezhiyong on 2017/1/10.
//  Copyright © 2017年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHToolsPush.h"

@implementation JHToolsPush

static JHToolsPush* _instance = nil;

#define CHECKPLUGIN(RET) if (self.push == nil) return RET;

+(instancetype) sharedInstance
{
    if (_instance == nil)
    {
        _instance = [[JHToolsPush alloc] init];
    }
    return _instance;
}


//  执行通知
-(void)scheduleNotification:(NSString*)args
{
    CHECKPLUGIN();
    
    [_push scheduleNotification:args];
}

//  开始推送
-(void)startPush
{
    CHECKPLUGIN();
    
    [_push startPush];
}

//  停止推送
-(void)stopPush
{
    CHECKPLUGIN();
    
    [_push stopPush];
}

//  添加tag
-(void)addTags:(NSString*)tags
{
    CHECKPLUGIN();
    
    [_push addTags:tags];
}

//  删除tag
-(void)removeTags:(NSString*)tag
{
    CHECKPLUGIN();
    
    [_push removeTags:tag];
}

//  添加别名
-(void)addAlias:(NSString*)alias
{
    CHECKPLUGIN();
    
    [_push addAlias:alias];
}

//  删除别名
-(void)removeAlias:(NSString*)alias
{
    CHECKPLUGIN();
    
    [_push removeAlias:alias];
}

@end
