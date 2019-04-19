//
//  JHToolsUser.h
//  JHToolsUser
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//JHToolsUser 账号登录相关接口
@protocol IJHToolsUser

- (void) login;
- (void) logout;
- (void) switchAccount;

- (BOOL) hasAccountCenter;
- (void) submitUserInfo:(JHToolsUserExtraData*)userlog;

@optional
- (void) loginCustom:(NSString*)customData;
- (void) showAccountCenter;

@end

__attribute__ ((deprecated))
@protocol JHToolsUser
@end
