//
//  DMPayManager.h
//  PayExample
//
//  Created by iMac on 16/8/29.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 支付宝回调：
 resultStatus结果码含义
 返回码	含义
 9000	订单支付成功
 8000	正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 4000	订单支付失败
 5000	重复请求
 6001	用户中途取消
 6002	网络连接出错
 6004	支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 其它	其它支付错误
 
 微信支付回调：
 回调中errCode值列表：
 名称	描述      解决方案
 0      成功      展示成功页面
 -1     错误      可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。
 -2     用户取消  无需处理。发生场景：用户不支付了，点击取消，返回APP。
 */

typedef NS_ENUM(NSUInteger, DMPayResult) {
    DMPayResultSuccessful,
    DMPayResultFail,
    DMPayResultCancel
};

typedef NS_ENUM(NSUInteger, DMPayType) {
    DMPayTypeAli,   //支付宝
    DMPayTypeWeChat //微信
};

@protocol DMPayManagerDelegate;

@interface DMPayManager : NSObject

// URL Scheme, 用于支付完成之后，从其他地方回到APP
@property (copy, nonatomic) NSString *schemeString;
// 在微信开放平台注册的APP ID，使用微信支付会用到
//@property (copy, nonatomic) NSString *appIDInWeChat;

@property (weak, nonatomic) id<DMPayManagerDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 *  AppDelegate中openURL的回调
 *
 *  @param url openURL
 */
- (void)applicationOpenURL:(NSURL *)url;

/**
 *  使用支付宝发起支付
 *
 *  @param orderStr 服务器组装并签名后的订单信息
 *  @param block    支付结果回调
 */
- (void)payAliOrderString:(NSString *)orderStr;

/**
 *  使用微信支付，所有数据由服务器传过来
 *
 * {
 *   "appid":"wxb4ba3c02aa476ea1",
 *   "partnerid":"1305176001",
 *   "package":"Sign=WXPay",
 *   "noncestr":"4879c3823d018a595fba5bd575c1a590",
 *   "timestamp":1472539484,
 *   "prepayid":"wx201608301444449587f358710218083832",
 *   "sign":"0FC63A83833E23835556D737967A4D70"
 * }
 *
 *  @param data 微信支付需要的数据字典如上
 */
- (void)payWeChatData:(NSDictionary *)dataDic;

@end

@protocol DMPayManagerDelegate <NSObject>

@required
- (void)dm_payManagerWithResult:(DMPayResult)result resultCode:(NSInteger)code payType:(DMPayType)type;

@end