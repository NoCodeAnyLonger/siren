//
//  UPPayment.swift
//  siren
//
//  Created by danqin chu on 2024/3/27.
//  Copyright © 2024 danqin chu. All rights reserved.
//

import Foundation



final class UPPayment {
    
    static func process(tn: String) {
        
    }
    
    static func handle(url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        UPPaymentControl.default().handlePaymentResult(url) { code, data in
            showAlert(title: "云闪付", message: code, actions: UIAlertAction(title: "好", style: .default, handler: nil))
//            //结果code为成功时，先校验签名，校验成功后做后续处理
//            if([code isEqualToString:@"success"]) {
//                
//                //判断签名数据是否存在
//                if(data == nil){
//                    //如果没有签名数据，建议商户app后台查询交易结果
//                    return;
//                }
//                
//                //数据从NSDictionary转换为NSString
//                NSData *signData = [NSJSONSerialization dataWithJSONObject:data
//                                                                   options:0
//                                                                     error:nil];
//                NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
//                
//                
//                
//                //验签证书同后台验签证书
//                //此处的verify，商户需送去商户后台做验签
//                if([self verify:sign]) {
//                    //支付成功且验签成功，展示支付成功提示
//                }
//                else {
//                    //验签失败，交易结果数据被篡改，商户app后台查询交易结果
//                }
//            }
//            else if([code isEqualToString:@"fail"]) {
//                //交易失败
//            }
//            else if([code isEqualToString:@"cancel"]) {
//                //交易取消
//            }
            
        }
    }
    
}
