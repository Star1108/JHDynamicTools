//
//  YYJPlatformDefines.h
//  CYUserLogin
//
//  Created by Ferryman on 16/9/19.
//  Copyright © 2016年 YYJia. All rights reserved.
//

#ifndef YYJPlatformDefines_h
#define YYJPlatformDefines_h
#import <UIKit/UIKit.h>
#pragma mark - Notification -----------------------------------------------

UIKIT_EXTERN NSString* const YYJPlatformInitDidFinishedNotification;   //初始化成功
UIKIT_EXTERN NSString* const YYJPlatformInitFinishedFailNotification;  // 初始化失败
UIKIT_EXTERN NSString* const YYJPlatformLogoutNotification;            //注销
UIKIT_EXTERN NSString* const YYJPlatformLoginNotification;             //登录

UIKIT_EXTERN NSString* const YYJPlatformBMaiSuccessfulNotification;     // 支付成功
UIKIT_EXTERN NSString* const YYJPlatformBMaiFailNotification;           // 支付失败

#endif /* YYJPlatformDefines_h */
