//
//  Login.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import Foundation
import HandyJSON

private let kLoginUsername = "kLoginUsername"

private let kLoginPassword = "kLoginPassword"

struct Login: HandyJSON {
    
    var user: String = ""
    
    var pass: String = ""
    
    var isValid: Bool {
        return user.count > 0 && pass.count > 0
    }
    
    static func lastLogin() -> Login {
        let ud = UserDefaults.standard
        let username = ud.string(forKey: kLoginUsername)
        let password = ud.string(forKey: kLoginPassword)
        return Login(user: username ?? "", pass: password ?? "")
    }
    
    func save() {
        let ud = UserDefaults.standard
        ud.set(user, forKey: kLoginUsername)
        ud.set(pass, forKey: kLoginPassword)
        ud.synchronize()
    }

}


