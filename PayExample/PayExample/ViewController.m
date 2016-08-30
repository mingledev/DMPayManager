//
//  ViewController.m
//  PayExample
//
//  Created by iMac on 16/8/29.
//  Copyright © 2016年 Mingle. All rights reserved.
//

#import "ViewController.h"
#import "DMPayManager.h"

@interface ViewController () <DMPayManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)weChatPay:(id)sender {
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
    NSDictionary *dataDic = @{@"appid": @"wxb4ba3c02aa476ea1", @"partnerid": @"1305176001", @"package": @"Sign=WXPay", @"noncestr": @"4879c3823d018a595fba5bd575c1a590", @"timestamp": @"1472539484", @"prepayid": @"wx201608301444449587f358710218083832", @"sign": @"0FC63A83833E23835556D737967A4D70"};
    DMPayManager *payManager = [DMPayManager sharedInstance];
    payManager.delegate = self;
    [payManager payWeChatData:dataDic];
}

- (void)dm_payManagerWithResult:(DMPayResult)result resultCode:(NSInteger)code payType:(DMPayType)type {
    switch (result) {
        case DMPayResultSuccessful:
            NSLog(@"%s 支付成功", __FUNCTION__);
            break;
        case DMPayResultFail:
            NSLog(@"%s 支付失败", __FUNCTION__);
            break;
        case DMPayResultCancel:
            NSLog(@"%s 支付取消", __FUNCTION__);
            break;
        default:
            break;
    }
}

@end
