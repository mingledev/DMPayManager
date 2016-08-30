//
//  DMPayManager.m
//  PayExample
//
//  Created by iMac on 16/8/29.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "DMPayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface DMPayManager () <WXApiDelegate>

@end

@implementation DMPayManager

+ (instancetype)sharedInstance
{
    static DMPayManager* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DMPayManager new];
    });

    return instance;
}

- (void)applicationOpenURL:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            // 调用支付宝APP支付会从这个地方回调
            [self aliPayCompletionHandle:resultDic];
        }];
    } else {
        [WXApi handleOpenURL:url delegate:self];
    }
}

- (void)payAliOrderString:(NSString *)orderStr {
    [[AlipaySDK defaultService] payOrder:orderStr fromScheme:self.schemeString callback:^(NSDictionary *resultDic) {
        // H5支付会从这个地方回调
        [self aliPayCompletionHandle:resultDic];
    }];
}

- (void)payWeChatData:(NSDictionary *)dataDic {
    static dispatch_once_t registOnceToken;
    dispatch_once(&registOnceToken, ^{
        if (![WXApi registerApp:[dataDic objectForKey:@"appid"]]) {
            NSLog(@"%s---微信注册失败", __FUNCTION__);
        }
    });
    
    NSMutableString *stamp  = [dataDic objectForKey:@"timestamp"];
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.partnerId           = [dataDic objectForKey:@"partnerid"];
    req.prepayId            = [dataDic objectForKey:@"prepayid"];
    req.nonceStr            = [dataDic objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dataDic objectForKey:@"package"];
    req.sign                = [dataDic objectForKey:@"sign"];
    [WXApi sendReq:req];
    //日志输出
    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dataDic objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
}

/**
 *  支付宝操作完成后的处理
 *
 *  @param resultDic 支付宝操作完成后的结果
 */
- (void)aliPayCompletionHandle:(NSDictionary *)resultDic {
    NSLog(@"%s---%@", __FUNCTION__, resultDic);
    NSInteger resultCode;
    if ([[resultDic allKeys] containsObject:@"resultStatus"]) {
        resultCode = [[resultDic objectForKey:@"resultStatus"] integerValue];
    } else {
        resultCode = 4000;// 4000表示支付失败
    }
    if ([self.delegate respondsToSelector:@selector(dm_payManagerWithResult:resultCode:payType:)])
        [self.delegate dm_payManagerWithResult:[self getPayResultWithAliResultCode:resultCode] resultCode:resultCode payType:DMPayTypeAli];
}

- (DMPayResult)getPayResultWithAliResultCode:(NSInteger)code {
    DMPayResult result;
    switch (code) {
        case 9000:
            result = DMPayResultSuccessful;
            break;
        case 6001:
            result = DMPayResultCancel;
            break;
        case 8000:
        case 4000:
        case 5000:
        case 6002:
        case 6004:
        default:
            result = DMPayResultFail;
            break;
    }
    return result;
}

- (DMPayResult)getPayResultWithWeChatResultCode:(NSInteger)code {
    DMPayResult resutl;
    switch (code) {
        case 0:
            resutl = DMPayResultSuccessful;
            break;
        case -2:
            resutl = DMPayResultCancel;
            break;
        case -1:
        default:
            resutl = DMPayResultFail;
            break;
    }
    return resutl;
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSLog(@"%s---微信支付结果:%@", __FUNCTION__, resp.errStr);
        if ([self.delegate respondsToSelector:@selector(dm_payManagerWithResult:resultCode:payType:)])
            [self.delegate dm_payManagerWithResult:[self getPayResultWithWeChatResultCode:resp.errCode] resultCode:resp.errCode payType:DMPayTypeWeChat];
    }
}

@end
