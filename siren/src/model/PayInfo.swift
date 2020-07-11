//
//  PayInfo.swift
//  siren
//
//  Created by danqin chu on 2020/3/19.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import HandyJSON

struct WXPayInfo: HandyJSON {
    let appid: String = ""
    let partnerid: String = ""
    let prepayid: String = ""
    let timestamp: String = ""
    let noncestr: String = ""
    let packagestr: String = ""
    let sign: String = ""
    let signType: String = ""
}

class PayInfo: HandyJSON {
    
    enum OrderStatus: Int, HandyJSONEnum {
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
    
    let user: String = ""
    let title: String = ""
    let paytype: String = ""
    let payinfo: Any? = nil
    let ordertime: String = ""
    let sign: String? = nil
    let num: Any? = nil
    let order_id: String = ""
    var status: OrderStatus = .paying
    let money: String = ""
    
    var alipayInfo: String? {
        return payinfo as? String
    }
    
    var wxpayInfo: WXPayInfo? {
        if let dict = payinfo as? Dictionary<String, Any> {
            return WXPayInfo.deserialize(from: dict)
        } else if let str = payinfo as? String {
            return WXPayInfo.deserialize(from: str)
        } else {
            return nil
        }
    }
    
    required init() {
        
    }
}
