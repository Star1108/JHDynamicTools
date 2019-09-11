#1.info.plist文件增加权限
    infoPlist['NSPhotoLibraryAddUsageDescription'] = "需要为您添加图片"
    infoPlist['NSPhotoLibraryUsageDescription'] = "需要访问您的相册"

#2.增加URL Types
    self.addBundleURLType(CFBundleTypeRole="Editor", CFBundleURLName="SDKScheme", CFBundleURLSchemes=[self.getBundleId()])

#3.增加http请求允许
    infoPlist["NSAppTransportSecurity"] = { "NSAllowsArbitraryLoads": True }

#4.info.plist文件JHToolsSDK下参数修改，并在plugins下增加渠道SDK参数
    self.gameid = [params valueForKey:@"gameid"];

#5.替换库(包含JHToolsSDK_CommonSDK)，去除旧渠道SDK，加入替换渠道SDK

#6.修改名字、Bundle ID、Icon、闪屏


