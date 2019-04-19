//
//  JHToolsPush.h
//  JHToolsSDKCore
//
//  Created by xiezhiyong on 2017/1/10.
//  Copyright © 2017年 JHToolssdk. All rights reserved.
//

#ifndef JHToolsPush_h
#define JHToolsPush_h

#import <Foundation/Foundation.h>

//分享接口
@protocol IJHToolsPush

//  执行通知
-(void)scheduleNotification:(NSString*)args;

//  开始推送
-(void)startPush;

//  停止推送
-(void)stopPush;

//  添加tag
-(void)addTags:(NSString*)tags;

//  删除tag
-(void)removeTags:(NSString*)tag;

//  添加别名
-(void)addAlias:(NSString*)alias;

//  删除别名
-(void)removeAlias:(NSString*)alias;

@end

@interface JHToolsPush : NSObject<IJHToolsPush>

/// 分享接口实现
@property (strong, nonatomic) NSObject<IJHToolsPush>* push;

/// 获取JHToolsSDKShare的单例
+(instancetype) sharedInstance;

@end

#endif /* JHToolsPush_h */
