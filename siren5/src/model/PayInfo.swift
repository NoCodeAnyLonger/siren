//
//  PayInfo.swift
//  siren
//
//  Created by danqin chu on 2020/3/19.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit
import SmartCodable

struct WXPayInfo: APIModel {
//    var app_id = ""
//    var nonce_str = ""
//    var package = ""
//    var partner_id = ""
//    var prepay_id = ""
//    var sign = ""
//    var time_stamp = ""
    
    var appId: String = ""
    var partnerId: String = ""
    var prepayId: String = ""
    var timestamp: String = ""
    var nonceStr: String = ""
    var package: String = ""
    var sign: String = ""
    var signType: String?
    
    static func mappingForKey() -> [SmartKeyTransformer]? {
        [
            CodingKeys.appId <--- ["app_id", "appId"],
            CodingKeys.nonceStr <--- ["nonce_str", "nonceStr"],
            CodingKeys.partnerId <--- ["partner_id", "partnerId"],
            CodingKeys.package <--- ["package", "packageValue"],
            CodingKeys.prepayId <--- ["prepay_id", "prepayId", "prePayId"],
            CodingKeys.timestamp <--- ["time_stamp", "timeStamp"],
            CodingKeys.sign <--- ["sign", "paySign"],
            CodingKeys.signType <--- ["sign_type", "signType"],
        ]
    }
}

final class PayInfo: APIModel {
    
    enum PayChannel {
        case wechat
        case ali
        case h5(url: URL)
        case unknown
    }
    
    enum OrderStatus: Int, SmartCaseDefaultable {
        case unpaid = 0
        case paying = 1
        case paid = 2
        
        var sortPriority: Int { 
            return 100 - self.rawValue
        }
        
        var description: String {
            switch self {
            case .paid:
                return "已支付"
            case .unpaid:
                return "未支付"
            case .paying:
                return "支付中"
            }
        }
        
        var color: UIColor {
            switch self {
            case .paid:
                return UIColor(hex: 0x3CFF3C)
            case .unpaid:
                return UIColor(hex: 0xF64B50)
            case .paying:
                return UIColor(hex: 0x999999)
            }
        }
    }
    
    var user: String = ""
    var title: String = ""
    var paytype: String = ""
    var payinfo: String = ""
    var ordertime: String = ""
    var sign: String? = nil
//    var num: Any? = nil
    var order_id: String = ""
    var status: OrderStatus = .paying
    var money: String = ""
    
    var alipayInfo: String? {
        return payinfo
    }
    
    var wxpayInfo: WXPayInfo? {
        /*if let dict = payinfo as? Dictionary<String, Any> {
            return WXPayInfo.deserialize(from: dict)
        } else */
        let str = payinfo
        let sad = str.replacingOccurrences(of: "'", with: "\"")
        return WXPayInfo.deserialize(from: sad)
    }
    
    var payChannel: PayChannel {
        let pt = paytype.lowercased()
        if pt == "alipay" {
            return .ali
        } else if pt == "wxpay" {
            return .wechat
        } else if pt == "h5" {
            if let url = URL(string: payinfo) {
                return .h5(url: url)
            }
        }
        return .unknown
    }
}
