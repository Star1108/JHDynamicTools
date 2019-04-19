//
//  JHToolsSDK.m
//  JHToolsSDK
//
//  Created by dayong on 15-1-21.
//  Copyright (c) 2015年 JHToolssdk. All rights reserved.
//

#import "JHToolsSDKProxy.h"
#import "JHToolsSDK.h"
#import "JHToolsAnalytics.h"
#import "JHToolsPay.h"
#import "JHToolsProgressHUD.h"

#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/ASIdentifierManager.h>

#import <sys/utsname.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

static NSString * const kAFCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
static NSString * const kAFCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

static NSString *const securityKey = @"YLTWbZoZ4DCQ1zrcN3rqi77ajKLwhuHv";

@implementation JHToolsProxy
{
    JHToolsSDK* JHToolssdk;
}

- (void)showAlertView:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(id) init
{
    JHToolssdk = [JHToolsSDK sharedInstance];
    self.userID = @"";
    [self collectDeviceInfo];
    return self;
}

-(UIView*) GetView
{
    return [JHToolssdk.delegate GetView];
}

-(UIViewController*) GetViewController
{
    return [JHToolssdk.delegate GetViewController];
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char *)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *) uniqueAdvertisingIdentifier
{
    NSUUID *adverSUUID = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *uuidString = @"0";
    if (adverSUUID) {
        uuidString = [adverSUUID UUIDString];
    }
    
    return uuidString;
}

- (NSString *) uniqueIdentifier
{
    UIDevice* device = [UIDevice currentDevice];
    
    NSString* json = nil;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"]!=NSOrderedAscending) {
        json = [NSString stringWithFormat:@"{\"idfv\":\"%@\",\"idfa\":\"%@\",\"model\":\"%@\"}",
                [[device identifierForVendor] UUIDString],
                [self uniqueAdvertisingIdentifier],
                [device model]];
    }
    else{
        json = [NSString stringWithFormat:@"{\"mac\":\"%@\",\"model\":\"%@\"}",
                [self macaddress],
                [device model]];
    }
    
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* base64 = nil;
    if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        base64 = [data base64EncodedStringWithOptions:kNilOptions];
    }
    else
    {
        base64 = [data base64Encoding];
    }
    
    return [NSString stringWithFormat:@"ios-%@", base64];
}

-(void) collectDeviceInfo
{
    JHToolsDeviceInfo* devInfo = [[JHToolsDeviceInfo alloc] init];
    
    UIDevice* device = [UIDevice currentDevice];
    
    devInfo.deviceID = [self uniqueIdentifier];
    devInfo.appID = [[JHToolssdk.sdkParams objectForKey:@"AppID"] intValue];
    devInfo.channelID = JHToolssdk.channelId;
    devInfo.mac = [self macaddress];
    devInfo.deviceType = [self iphoneType];
    devInfo.deviceOS = 2;
    devInfo.deviceDpi = @"";
    [self submitDeviceInfo:devInfo responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        if (connectionError)
        {
            NSLog(@"submitDevice Error: %@", connectionError);
        }
        else
        {
            NSLog(@"submitDevice: %@", data);
        }
    }];
}

-(void) doPlatformInit:(NSDictionary*)param
{
    [JHToolssdk.delegate OnPlatformInit:param];
}

-(void) doUserLogin:(NSDictionary*)param
{
    [self accountVerification:param responseHandler:^(NSURLResponse *response, id data, NSError *err)
     {
         NSString* alertMsg = nil;
         
         if (err)
         {
             alertMsg = [NSString stringWithFormat:@"账号验证失败: %@", [err localizedDescription]];
         }
         else if (!data)
         {
             NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"Invalid response type");
             
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             alertMsg = [NSString stringWithFormat:@"账号验证失败: %@", [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
         }
         else
         {
             NSDictionary* json = (NSDictionary*)data;
             NSDictionary* jsonFieldData = [json valueForKey:@"data"];
             
             if ([[json valueForKey:@"state"] intValue] == 1)
             {
                 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                 self.userID = [jsonFieldData objectForKey:@"userID"];
                 [dict setValuesForKeysWithDictionary:jsonFieldData];
                 [JHToolssdk.delegate OnUserLogin:dict];
             }
             else
             {
                 NSLog(@"verify failed. state:%@", [json valueForKey:@"state"]);
                 alertMsg =[json valueForKey:@"message"];
                 if (alertMsg == nil)
                 {
                     alertMsg = @"账号验证失败";
                 }
             }
         }
         
         if (alertMsg)
         {
             [self showAlertView:alertMsg];
         }
     }];
}

-(void) doUserLogout:(NSDictionary*)param
{
    [JHToolssdk.delegate OnUserLogout:param];
}

-(void) doPayPaid:(NSDictionary*)param
{
    /*
     [self PayValidate:param responseHandler:^(NSURLResponse *response, id data, NSError *err)
     {
     NSString* alertMsg = nil;
     
     if (err)
     {
     alertMsg = [NSString stringWithFormat:@"订单验证失败: %@", [err localizedDescription]];
     }
     else if (!data)
     {
     NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"Invalid response type");
     
     NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     alertMsg = [NSString stringWithFormat:@"订单验证失败: empty response！%@", [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
     }
     else
     {
     NSDictionary* json = (NSDictionary*)data;
     
     if ([[json valueForKey:@"state"] intValue] == 1)
     {
     [[JHToolsSDK sharedInstance] finishTransaction:[param valueForKey:@"transactionIdentifier"]];
     [JHToolssdk.delegate OnPayPaid:nil];
     }
     else
     {
     alertMsg =[json valueForKey:@"message"];
     }
     }
     
     if (alertMsg)
     {
     [self showAlertView:alertMsg];
     }
     }];
     */
}

-(void) doCustomEvent:(NSString*)eventName params:(NSDictionary*)params
{
    [JHToolssdk.delegate OnEventCustom:eventName params:params];
}

- (NSString *) stringMd5:(NSString*)src
{
    if(self == nil || [src length] == 0)
        return nil;
    
    const char *value = [src UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

-(void) submitPushToken:(NSString *)pushToken withUid:(NSString *)uid extension:(NSString *)extension{
    [self submitPushToken:pushToken withUid:uid extension:extension  responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
        if (connectionError)
        {
            NSLog(@"submitPushToken Error: %@", connectionError);
        }
        else
        {
            NSLog(@"submitPushToken: %@", data);
        }
    }];
}

-(void) submitPushToken:(NSString *)pushToken withUid:(NSString *)uid extension:(NSString *)extension  responseHandler:(JHToolsRequestCallback)handler
{
    if (JHToolssdk.sdkParams == nil) return;
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
    NSString *appID = [JHToolssdk.sdkParams objectForKey:@"AppID"];
    NSString *channelID = [NSString stringWithFormat:@"%zd", JHToolssdk.channelId];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"appID":appID, @"channelID":channelID, @"pushToken":[NSString stringWithFormat:@"%@", pushToken], @"uID":[NSString stringWithFormat:@"%@", uid], @"deviceOS":@"2", @"extension":[NSString stringWithFormat:@"%@", extension]}];
    [httpParams setObject:data forKey:@"data"];
    [httpParams setObject:@"addPushToken" forKey:@"service"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
    
    NSString *dataStr = [self ascendingFieldForDic:data];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@", @"addPushToken", [NSString stringWithFormat:@"%.0f", time], dataStr, securityKey] ;
    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
    
    [self sendHttpRequest:httpParams responseHandler:handler showProgess:YES];
}

-(void) submitDeviceInfo:(JHToolsDeviceInfo *)device responseHandler:(JHToolsRequestCallback)handler
{
    if (JHToolssdk.sdkParams == nil) return;
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"appID": [NSString stringWithFormat:@"%ld", (long)device.appID],
                                                                                @"channelID": [NSString stringWithFormat:@"%ld", (long)device.channelID],
                                                                                @"deviceDpi": device.deviceDpi == nil ? @"" : device.deviceDpi,
                                                                                @"deviceID": device.deviceID == nil ? @"" : device.deviceID,
                                                                                @"deviceType":[NSString stringWithFormat:@"%ld", (long)device.deviceOS],
                                                                                @"deviceOS":device.deviceType,
                                                                                @"mac":device.mac == nil ? @"" : device.mac
                                                                                }];
    [httpParams setObject:data forKey:@"data"];
    [httpParams setObject:@"addDevice" forKey:@"service"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
    
    NSString *dataStr = [self ascendingFieldForDic:data];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@", @"addDevice", [NSString stringWithFormat:@"%.0f", time], dataStr, securityKey] ;
    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
    
    [self sendHttpRequest:httpParams responseHandler:handler showProgess:YES];
}

// 提交用户统计数据
-(void) submitUserInfo:(JHToolsUserExtraData*)userExtraInfo responseHandler:(JHToolsRequestCallback)handler
{
    int opCode = 0;
    BOOL sendable = YES;
    switch (userExtraInfo.dataType) {
        case TYPE_CREATE_ROLE:
            opCode = OP_CREATE_ROLE;
            break;
        case TYPE_ENTER_GAME:
            opCode = OP_ENTER_GAME;
            break;
        case TYPE_LEVEL_UP:
            opCode = OP_LEVEL_UP;
            break;
        case TYPE_EXIT_GAME:
            opCode = OP_EXIT;
            break;
        default:
            sendable = FALSE;
            break;
    }
    
    if(!sendable) return;
    
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   @"appID": [JHToolssdk.sdkParams valueForKey:@"AppID"],
                                                                                   @"channelID": [JHToolssdk.sdkParams valueForKey:@"Channel"],
                                                                                   @"serverID": [NSString stringWithFormat:@"%zd", userExtraInfo.serverID],
                                                                                   @"serverName": [NSString stringWithFormat:@"%@", userExtraInfo.serverName],
                                                                                   @"roleID": [NSString stringWithFormat:@"%@", userExtraInfo.roleID],
                                                                                   @"roleName": [NSString stringWithFormat:@"%@", userExtraInfo.roleName],
                                                                                   @"roleLevel": [NSString stringWithFormat:@"%@", userExtraInfo.roleLevel],
                                                                                   @"deviceID": [self uniqueIdentifier],
                                                                                   @"opType": [NSString stringWithFormat:@"%zd", opCode],
                                                                                   @"userID": self.userID,
                                                                                   @"type": @"1"
                                                                                   }];
    
    [httpParams setObject:dataDic forKey:@"data"];
    [httpParams setObject:@"addUserLog" forKey:@"service"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
    
    NSString *dataStr = [self ascendingFieldForDic:dataDic];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@", @"addUserLog", [NSString stringWithFormat:@"%.0f", time], dataStr, securityKey] ;
    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
    
    [self sendHttpRequest:httpParams responseHandler:handler showProgess:NO];
}

//SDK渠道登录后进行JHTools验证
-(void)accountVerification:(NSDictionary*)params responseHandler:(JHToolsRequestCallback) handler{
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"appID": [JHToolssdk.sdkParams valueForKey:@"AppID"],@"channelID": [JHToolssdk.sdkParams valueForKey:@"Channel"], @"sdkVersionCode": [JHToolssdk.sdkParams valueForKey:@"sdkVersion"], @"deviceID": [self uniqueIdentifier], @"extension": [self dictionaryToJson:params]}];
    
    [httpParams setObject:data forKey:@"data"];
    [httpParams setObject:@"login" forKey:@"service"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
    
    NSString *dataStr = [self ascendingFieldForDic:data];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@", @"login", [NSString stringWithFormat:@"%.0f", time], dataStr, securityKey] ;
    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
    
    [self sendHttpRequest:httpParams responseHandler:handler showProgess:YES];
    
    [self alipayPwdRed];
}

-(void)getOrderWith:(JHToolsProductInfo *)productInfo responseHandler:(JHToolsRequestCallback) handler{
    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
               @"appID": [JHToolssdk.sdkParams valueForKey:@"AppID"],
               @"channelID": [JHToolssdk.sdkParams valueForKey:@"Channel"],
               @"user_id": [NSString stringWithFormat:@"%@", self.userID],
//               @"money": [NSString stringWithFormat:@"%d", [productInfo.price intValue]],
               @"money": [NSString stringWithFormat:@"%.0f", [productInfo.price floatValue]*100],
//               @"money": [NSString stringWithFormat:@"%.0f", [productInfo.price floatValue]],
               @"role_id": [NSString stringWithFormat:@"%@", productInfo.roleId],
               @"role_name": [NSString stringWithFormat:@"%@", productInfo.roleName],
               @"server_id": [NSString stringWithFormat:@"%@", productInfo.serverId],
               @"server_name": [NSString stringWithFormat:@"%@", productInfo.serverName],
               @"product_id": [NSString stringWithFormat:@"%@", productInfo.productId],
               @"product_name": [NSString stringWithFormat:@"%@", productInfo.productName],
               @"product_desc": [NSString stringWithFormat:@"%@", productInfo.productDesc],
               @"sdkid": @"",
               @"extension": [NSString stringWithFormat:@"%@", productInfo.extension]
               }];
    
    [httpParams setObject:data forKey:@"data"];
    [httpParams setObject:@"prepayOrder" forKey:@"service"];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
    
    NSString *dataStr = [self ascendingFieldForDic:data];
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@", @"prepayOrder", [NSString stringWithFormat:@"%.0f", time], dataStr, securityKey] ;
    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
    NSLog(@"预订单参数：%@", httpParams);
    [self sendHttpRequest:httpParams responseHandler:handler showProgess:YES];
}


-(void)alipayPwdRed{
//    NSMutableDictionary *httpParams = [NSMutableDictionary dictionary];
//
//    [httpParams setObject:@"alipayPwdRed" forKey:@"service"];
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//    [httpParams setObject:[NSString stringWithFormat:@"%.0f", time] forKey:@"time"];
//    NSString *sign = [NSString stringWithFormat:@"%@%@%@", @"alipayPwdRed", [NSString stringWithFormat:@"%.0f", time], securityKey] ;
//    [httpParams setObject:[[self md5:sign] lowercaseStringWithLocale:[NSLocale currentLocale]] forKey:@"sign"];
//
//    [self sendHttpRequest:httpParams responseHandler:^(NSURLResponse *response, id data, NSError *connectionError) {
//        if ([data isKindOfClass:[NSDictionary class]] && data !=nil) {
//            NSDictionary *dict = data;
//            if (dict.count > 0 && dict[@"data"] !=nil) {
//                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//                pasteboard.string = dict[@"data"][@"alipaypwdred"];
//            }
//        }
//    } showProgess:NO];
}

/*
 //账号验证方法
 -(void) AccountValidate:(NSDictionary*)params responseHandler:(JHToolsRequestCallback) handler
 {
 NSMutableDictionary* httpParams = [NSMutableDictionary dictionaryWithDictionary:@{
 @"appID": [JHToolssdk.sdkParams valueForKey:@"AppId"],
 @"channelID": [JHToolssdk.sdkParams valueForKey:@"Channel"],
 @"sdkVersionCode": @"1"
 }];
 
 id extension = [params valueForKey:@"extension"];
 
 if (!extension)
 {
 extension = @"";
 }
 else if (![extension isKindOfClass:[NSString class]])
 {
 NSError* err = nil;
 NSData* jsonData = [NSJSONSerialization dataWithJSONObject:extension options:kNilOptions error:&err];
 extension = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
 }
 
 [httpParams setValuesForKeysWithDictionary:params];
 
 NSString* sign = [NSString stringWithFormat:@"appID=%@channelID=%@extension=%@%@",
 [JHToolssdk.sdkParams valueForKey:@"AppId"],
 [JHToolssdk.sdkParams valueForKey:@"Channel"],
 extension,
 [JHToolssdk.sdkParams valueForKey:@"AppKey"]];
 
 sign = [[self stringMd5:sign] lowercaseString];
 
 [httpParams setValue:sign forKey:@"sign"];
 
 [self sendHttpRequest:httpParams
 toJHToolsServer:@"user/getToken"
 responseHandler:handler showProgess:YES];
 }
 */
-(void) requestOrder:(JHToolsProductInfo*)params responseHandler:(JHToolsRequestCallback) handler
{
    NSMutableDictionary* httpParams = [NSMutableDictionary dictionary];
    
    [httpParams setValue:self.userID forKey:@"userID"];
    
    [httpParams setValue:params.productId forKey:@"productID"];
    [httpParams setValue:params.productName forKey:@"productName"];
    [httpParams setValue:params.productDesc forKey:@"productDesc"];
    [httpParams setValue:[NSString stringWithFormat:@"%d", (int)([params.price floatValue]*100+0.5)] forKey:@"money"];
    [httpParams setValue:params.roleId forKey:@"roleID"];
    [httpParams setValue:params.roleLevel forKey:@"roleLevel"];
    [httpParams setValue:params.roleName forKey:@"roleName"];
    [httpParams setValue:params.serverId forKey:@"serverID"];
    [httpParams setValue:params.serverName forKey:@"serverName"];
    [httpParams setValue:@"md5" forKey:@"signType"];
    
    NSString* extension = params.extension != NULL ? params.extension : @"";
    if (params.extension)
    {
        [httpParams setValue:params.extension forKey:@"extension"];
    }
    if (params.notifyUrl)
    {
        [httpParams setValue:params.notifyUrl forKey:@"notifyUrl"];
    }
    
    NSString* sign = [NSString stringWithFormat:@"userID=%@&"
                      @"productID=%@&"
                      @"productName=%@&"
                      @"productDesc=%@&money=%@&roleID=%@&roleName=%@&roleLevel=%@&serverID=%@&serverName=%@&extension=%@",
                      self.userID,
                      params.productId == nil ? @"" : params.productId,
                      params.productName == nil ? @"" : params.productName,
                      params.productDesc == nil ? @"" : params.productDesc,
                      [httpParams valueForKey:@"money"],
                      params.roleId == nil ? @"" : params.roleId,
                      params.roleName == nil ? @"" : params.roleName,
                      params.roleLevel == nil ? @"" : params.roleLevel,
                      params.serverId == nil ? @"" : params.serverId,
                      params.serverName == nil ? @"" : params.serverName,
                      extension];
    
    if (params.notifyUrl)
    {
        sign = [sign stringByAppendingString:[NSString stringWithFormat:@"&notifyUrl=%@", params.notifyUrl]];
    }
    
    sign = [sign stringByAppendingString:[JHToolssdk.sdkParams objectForKey:@"AppKey"]];
    
    NSLog(@"sign: %@", sign);
    
    sign = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)sign,
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString,
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    
    NSLog(@"sign encode: %@", sign);
    sign = [[self stringMd5:sign] lowercaseString];
    NSLog(@"sign md5: %@", sign);
    
    [httpParams setValue:sign forKey:@"sign"];
    
    [self sendHttpRequest:httpParams
            toJHToolsServer:@"pay/getOrderID"
          responseHandler:handler showProgess:YES];
}

// JHTools官方提供的充值验证方法
-(void) PayValidate:(NSDictionary*)params responseHandler:(JHToolsRequestCallback) handler
{
    NSMutableDictionary* httpParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"appID": [JHToolssdk.sdkParams valueForKey:@"AppId"],
                                                                                      @"channelID": [JHToolssdk.sdkParams valueForKey:@"Channel"],
                                                                                      @"sdkVersionCode": @"1"
                                                                                      }];
    
    [httpParams setValuesForKeysWithDictionary:params];
    [httpParams removeObjectForKey:@"method"];
    
    NSString *payValidatePath = [NSString stringWithFormat:@"pay/%@", [params valueForKey:@"method"]];
    
    [self sendHttpRequest:httpParams
            toJHToolsServer:payValidatePath
          responseHandler:handler showProgess:YES];
}

- (NSURL*) getJHToolsServerUrl:(NSString*)relativePath
{
    NSURL *JHToolsUrl = [NSURL URLWithString:[JHToolssdk.sdkParams valueForKey:@"JHToolsUrl"]];
    
    return [NSURL URLWithString:relativePath relativeToURL:JHToolsUrl];
}

-(void)sendHttpRequest:(NSDictionary *)httpParams responseHandler:(JHToolsRequestCallback)handler showProgess:(Boolean)showprogress
{
    JHToolsProgressHUD* progressHUD = nil;
    
    // Show with the default type.
    
    if (showprogress)
    {
        UIView* view = [self GetView];
        if (view)
        {
            progressHUD = [JHToolsProgressHUD showHUDAddedTo:view animated:YES];
        }
    }
    
    NSURL* url = [self getJHToolsServerUrl:@""].absoluteURL;
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:httpParams options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (progressHUD != nil)
         {
             [progressHUD hideAnimated:NO];
         }
         
         if (connectionError != nil || !data || [data length] == 0)
         {
             handler(response, nil, connectionError);
         }
         else
         {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             
             if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
             {
                 NSError* error;
                 NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 handler(response, json, error);
             }
             else
             {
                 handler(response, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]);
             }
         }
     }];
}

-(void) sendHttpRequest:(NSDictionary *)httpParams toJHToolsServer:(NSString *)requestPath responseHandler:(JHToolsRequestCallback)handler showProgess:(Boolean)showprogress
{
    JHToolsProgressHUD* progressHUD = nil;
    
    // Show with the default type.
    
    if (showprogress)
    {
        UIView* view = [self GetView];
        if (view)
        {
            progressHUD = [JHToolsProgressHUD showHUDAddedTo:view animated:YES];
        }
    }
    
    NSURL* url = [self getJHToolsServerUrl:requestPath].absoluteURL;
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString* strParams = [JHToolsProxy encodeHttpParams:httpParams encode:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[strParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (progressHUD != nil)
         {
             [progressHUD hideAnimated:NO];
         }
         
         if (connectionError != nil || !data || [data length] == 0)
         {
             handler(response, nil, connectionError);
         }
         else
         {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             
             if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
             {
                 NSError* error;
                 NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 handler(response, json, error);
             }
             else
             {
                 handler(response, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]);
             }
         }
     }];
}

// 序列化http请求参数
+(NSString*) encodeHttpParams:(NSDictionary*)params encode:(NSStringEncoding)encoding
{
    NSMutableArray* paramsArray = [NSMutableArray array];
    
    for (NSString* key in params) {
        id value = [params valueForKey:key];
        
        NSString* strValue = nil;
        
        if ([value isKindOfClass:[NSDictionary class]] ||
            [value isKindOfClass:[NSArray class]] ||
            [value isKindOfClass:[NSData class]] ||
            [value isKindOfClass:[NSSet class]])
        {
            NSError* err = nil;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:value options:kNilOptions error:&err];
            strValue = [[NSString alloc] initWithData:jsonData encoding:encoding];
        }
        else if ([value isKindOfClass:[NSString class]])
        {
            strValue = value;
        }
        else
        {
            strValue = [value description];
        }
        
        NSString* strKey = (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                  kCFAllocatorDefault,
                                                                                                  (__bridge CFStringRef)key,
                                                                                                  (__bridge CFStringRef)kAFCharactersToLeaveUnescapedInQueryStringPairKey,
                                                                                                  (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
        
        strValue = (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          kCFAllocatorDefault,
                                                                                          (__bridge CFStringRef)strValue,
                                                                                          NULL,
                                                                                          (__bridge CFStringRef)kAFCharactersToBeEscapedInQueryString,
                                                                                          CFStringConvertNSStringEncodingToEncoding(encoding));
        
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", strKey, strValue]];
    }
    
    return [paramsArray componentsJoinedByString:@"&"];
}


-(NSString *)ascendingFieldForDic:(NSDictionary *)dict{
    NSMutableArray *arr = [NSMutableArray array];
    //取出key
    for (NSString *key in dict) {
        [arr addObject:key];
    }
    //key升序排列
    NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range =NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    
    NSArray *sortArray = [arr sortedArrayUsingComparator:sort];
    //根据升序key取值拼接字符串
    NSMutableString *ascendStr =  [[NSMutableString alloc] init];
    for (NSString *key in sortArray) {
        if (dict[key] != nil) {
            [ascendStr appendFormat:@"%@", [NSString stringWithFormat:@"%@=%@", key, dict[key]]];
        }
    }
    return ascendStr;
}


-(NSString *)md5:(NSString *)str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

-(NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString *)iphoneType {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
}

@end

