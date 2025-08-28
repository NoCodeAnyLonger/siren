//
//  Login.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import Foundation
import SmartCodable

//private let kLoginUsername = "kLoginUsername"
//
//private let kLoginPassword = "kLoginPassword"

private let kLoginSign = "kLoginSign"

struct Login {
    
//    var user: String = ""
//    
//    var pass: String = ""
    
    var sign: String = ""
    
    var isValid: Bool {
//        return user.count > 0 && pass.count > 0
        return !sign.isEmpty
    }
    
    static func lastLogin() -> Login {
//        let ud = UserDefaults.standard
//        let username = ud.string(forKey: kLoginUsername)
//        let password = ud.string(forKey: kLoginPassword)
//        return Login(user: username ?? "", pass: password ?? "")
        let sign = UserDefaults.standard.string(forKey: kLoginSign)
        if let s = sign, !s.isEmpty {
            return Login(sign: s)
        } else {
            return Login(sign: "")
        }
    }
    
    func save() {
        let ud = UserDefaults.standard
//        ud.set(user, forKey: kLoginUsername)
//        ud.set(pass, forKey: kLoginPassword)
        ud.set(sign, forKey: kLoginSign)
        ud.synchronize()
    }
    
    func toJSON() -> [String: Any]? {
        return [
            "apikey": "73e1238b4a480095b3c73163635acfce",
            "sign": sign,
        ]
    }

}


