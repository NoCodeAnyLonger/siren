//
//  PayInfo.swift
//  siren
//
//  Created by danqin chu on 2020/3/19.
//  Copyright © 2020 danqin chu. All rights reserved.
//

struct WXPayInfo: Decodable {
    var appid: String = ""
    var partnerid: String = ""
    var prepayid: String = ""
    var timestamp: String = ""
    var noncestr: String = ""
    var package: String = ""
    var sign: String = ""
}

struct UPPayInfo: Decodable {
    var tn: String = ""
}

class PayInfo: Decodable {
    
    enum OrderStatus: Int, Decodable {
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
        
        init(from decoder: any Decoder) throws {
            let value = try decoder.singleValueContainer().decode(String.self)
            if var intValue = Int(value) {
                if intValue > 2 || intValue < 0 {
                    intValue = 0
                }
                self.init(rawValue: intValue)!
            } else {
                self.init(rawValue: 0)!
            }
        }
        
    }
    
    var user: String = ""
    var title: String = ""
    var paytype: String = ""
    var payinfo: String? = nil
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
        if let str = payinfo {
            return WXPayInfo.deserialize(from: str)
        } else {
            return nil
        }
    }
    
    var uppayInfo: UPPayInfo? {
        if let str = payinfo {
            return UPPayInfo.deserialize(from: str)
        } else {
            return nil
        }
    }
    
    required init() {
    }
}
