//
//  LJHToolsProgressHUD.m
//  LJHToolsang
//
//  Created by rao on 15/11/20.
//  Copyright © 2015年 辣妈帮. All rights reserved.
//

// 背景视图的宽度/高度
#define BGVIEW_WIDTH 100.0f
// 文字大小
#define TEXT_SIZE    16.0f

#define delaySecond 1.5f

#import "HNPloyProgressHUD.h"

@implementation HNPloyProgressHUD

+ (instancetype)sharedHUD {
    
    static HNPloyProgressHUD *hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hud = [[HNPloyProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    });
    return hud;
}

+ (void)showStatus:(LJHToolsProgressHUDStatus)status text:(NSString *)text {
    
    HNPloyProgressHUD *hud = [HNPloyProgressHUD sharedHUD];
    [hud show:YES];
    [hud setDetailsLabelText:text];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud setDetailsLabelFont:[UIFont boldSystemFontOfSize:TEXT_SIZE]];
    [hud setMinSize:CGSizeMake(BGVIEW_WIDTH, BGVIEW_WIDTH)];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    
    
    switch (status) {
            
        case LJHToolsProgressHUDStatusSuccess: {
            
            UIImage *sucImage = [UIImage imageNamed:@"hud_success"];
            
            hud.mode = JHToolsProgressHUDModeCustomView;
            UIImageView *sucView = [[UIImageView alloc] initWithImage:sucImage];
            hud.customView = sucView;
            [hud hide:YES afterDelay:delaySecond];
        }
            break;
            
        case LJHToolsProgressHUDStatusError: {
            
            UIImage *errImage = [UIImage imageNamed:@"hud_error"];
            
            hud.mode = JHToolsProgressHUDModeCustomView;
            UIImageView *errView = [[UIImageView alloc] initWithImage:errImage];
            hud.customView = errView;
            [hud hide:YES afterDelay:delaySecond];
        }
            break;
            
        case LJHToolsProgressHUDStatusWaitting: {
            
            hud.mode = JHToolsProgressHUDModeIndeterminate;
        }
            break;
            
        case LJHToolsProgressHUDStatusInfo: {
            
            UIImage *infoImage = [UIImage imageNamed:@"hud_info"];
            
            hud.mode = JHToolsProgressHUDModeCustomView;
            UIImageView *infoView = [[UIImageView alloc] initWithImage:infoImage];
            hud.customView = infoView;
            [hud hide:YES afterDelay:delaySecond];
        }
            break;
            
        default:
            break;
    }
}

+ (void)showMessage:(NSString *)text {
    
    HNPloyProgressHUD *hud = [HNPloyProgressHUD sharedHUD];
    [hud show:YES];
    [hud setDetailsLabelText:text];
    [hud setMinSize:CGSizeZero];
    [hud setMode:JHToolsProgressHUDModeText];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud setLabelFont:[UIFont boldSystemFontOfSize:TEXT_SIZE]];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud hide:YES afterDelay:delaySecond];
}

+ (void)showInfoMsg:(NSString *)text {
    
    [self showStatus:LJHToolsProgressHUDStatusInfo text:text];
}

+ (void)showFailure:(NSString *)text {
    
    [self showStatus:LJHToolsProgressHUDStatusError text:text];
}

+ (void)showSuccess:(NSString *)text {
    
    [self showStatus:LJHToolsProgressHUDStatusSuccess text:text];
}

+ (void)showLoading:(NSString *)text {
    
    [self showStatus:LJHToolsProgressHUDStatusWaitting text:text];
}

+ (void)hide {
    [[HNPloyProgressHUD sharedHUD] hide:YES];
}

+ (void)hideAfterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}

@end
