//
//  WanManagerDelegate.h
//  SDK_51WanSY
//
//  Created by Star on 2018/1/24.
//  Copyright © 2018年 Star. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WanSDKReturnResultType) {
    WanSDKReturnResultTypeSDKConfig = 0,
    WanSDKReturnResultTypeLogin,
    WanSDKReturnResultTypeLogout,
    WanSDKReturnResultTypePay,
    WanSDKReturnResultTypeSubmitInfo,
};

@protocol WanManagerDelegate <NSObject>

//SDK回调
-(void)wanSDKReturnResult:(NSDictionary *)result forType:(WanSDKReturnResultType)type;

@end
