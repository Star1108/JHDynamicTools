//
//  LJHToolsProgressHUD.h
//  LJHToolsang
//
//  Created by rao on 15/11/20.
//  Copyright © 2015年 辣妈帮. All rights reserved.
//

#import "JHToolsProgressHUD.h"

typedef NS_ENUM(NSInteger, LJHToolsProgressHUDStatus) {
    
    /** 成功 */
    LJHToolsProgressHUDStatusSuccess,
    
    /** 失败 */
    LJHToolsProgressHUDStatusError,
    
    /** 提示 */
    LJHToolsProgressHUDStatusInfo,
    
    /** 等待 */
    
    LJHToolsProgressHUDStatusWaitting
};

@interface HNPloyProgressHUD : JHToolsProgressHUD

/** 返回一个 HUD 的单例 */
+ (instancetype)sharedHUD;

/** 在 window 上添加一个 HUD */
+ (void)showStatus:(LJHToolsProgressHUDStatus)status text:(NSString *)text;
#pragma mark - 建议使用的方法

/** 在 window 上添加一个只显示文字的 HUD */
+ (void)showMessage:(NSString *)text;

/** 在 window 上添加一个提示`信息`的 HUD */
+ (void)showInfoMsg:(NSString *)text;

/** 在 window 上添加一个提示`失败`的 HUD */
+ (void)showFailure:(NSString *)text;

/** 在 window 上添加一个提示`成功`的 HUD */
+ (void)showSuccess:(NSString *)text;

/** 在 window 上添加一个提示`等待`的 HUD, 需要手动关闭 */
+ (void)showLoading:(NSString *)text;

/** 手动隐藏 HUD */
+ (void)hide;

+ (void)hideAfterDelay:(NSTimeInterval)delay;

@end
