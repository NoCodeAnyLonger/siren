//
//  UIExtensions.swift
//  siren
//
//  Created by danqin chu on 2020/3/17.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit
    
func showAlert(title: String?,
               message: String?,
               actions: UIAlertAction...) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for a in actions {
        ac.addAction(a)
    }
    PageSwitchManager.shared.present(viewController: ac, hasNavigationBar: false, animated: true)
}

public extension UIColor {

    convenience init(hex hexValue: Int32, alpha:CGFloat = 1) {
        self.init(
            red: CGFloat((Float)((hexValue&0xFF0000)>>16)/255.0),
            green: CGFloat((Float)((hexValue&0xFF00)>>8)/255.0),
            blue: CGFloat((Float)(hexValue&0xFF)/255.0),
            alpha:alpha)
    }
    
}
