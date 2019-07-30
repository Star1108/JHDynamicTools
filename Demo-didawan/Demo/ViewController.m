//
//  ViewController.m
//  Demo
//
//  Created by star on 2018/12/14.
//  Copyright © 2018年 star. All rights reserved.
//

#import "ViewController.h"
#import <JHToolsSDKCore/JHToolsSDKCore.h>

@interface ViewController ()<JHToolsSDKDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JHToolsSDK sharedInstance] setDelegate:self];
    
    [self initUI];
}

-(void)initUI{
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];

    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.backgroundColor = [UIColor blackColor];
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 160, 100, 40)];
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    payBtn.backgroundColor = [UIColor blackColor];
    [payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
    
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 220, 100, 40)];
    [uploadBtn setTitle:@"角色上报" forState:UIControlStateNormal];
    uploadBtn.backgroundColor = [UIColor blackColor];
    [uploadBtn addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadBtn];
}

//登录
-(void)login:(UIButton *)btn{
    [[JHToolsSDK sharedInstance] login];
}

//支付
-(void)pay:(UIButton *)btn{
    JHToolsProductInfo* productInfo = [[JHToolsProductInfo alloc] init];
    productInfo.orderID = @"1782341234";
    productInfo.productName = @"礼包1";
    productInfo.productDesc = @"礼包1";
    productInfo.productId = @"com.669.jianqilingyun.600";
    productInfo.price = [NSNumber numberWithInt:1];
    productInfo.buyNum = 1;
    productInfo.coinNum = 900;
    productInfo.roleId = @"12345";
    productInfo.roleName = @"角色";
    productInfo.roleLevel = @"66";
    productInfo.serverId = @"1";
    productInfo.serverName = @"桃源";
    productInfo.vip = @"1";
    productInfo.extension = @"hjghjklhjk";
    productInfo.notifyUrl = @"http://110.54.33.45/game/pay/notify";
    
    [[JHToolsSDK sharedInstance] pay:productInfo];
}

-(void)upload:(UIButton *)btn{
    JHToolsUserExtraData* extraData = [[JHToolsUserExtraData alloc] init];
    extraData.dataType = 1;
    extraData.roleID = @"111";
    extraData.roleName = @"角色名称";
    extraData.serverID = 5;
    extraData.serverName = @"区服名称";
    extraData.roleLevel = @"角色等级";
    extraData.moneyNum = 0.1;
    extraData.roleCreateTime = time(NULL);
    extraData.roleLevelUpTime = time(NULL);
    
    [[JHToolsSDK sharedInstance] submitExtraData:extraData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --<JHToolsSDKDelegate>
-(UIView*) GetView{
    return [self GetViewController].view;;
}

-(UIViewController*) GetViewController{
    return self;
}

//SDK初始化成功回调
-(void) OnPlatformInit:(NSDictionary*)params{
}

//登录成功回调
-(void) OnUserLogin:(NSDictionary*)params{
    
}

//登出回调
-(void) OnUserLogout:(NSDictionary*)params{
}

//支付回调
-(void) OnPayPaid:(NSDictionary*)params{
}

//事件回调
-(void) OnEventCustom:(NSString*)eventName params:(NSDictionary*)params{
}

@end
