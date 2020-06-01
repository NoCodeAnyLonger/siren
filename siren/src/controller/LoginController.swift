//
//  LoginController.swift
//  siren
//
//  Created by danqin chu on 2020/3/19.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit

final class LoginController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var saveHandler: ((Login) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let login = Login.lastLogin()
        usernameTextField.text = login.user
        passwordTextField.text = login.pass
        
        if #available(iOS 11.0, *) {} else {
            self.edgesForExtendedLayout = []
        }
        
        self.navigationItem.title = "设置用户"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(onLeftBarButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(onRightBarButtonClicked(_:)))
    }
    
    @objc
    func onLeftBarButtonClicked(_: Any) {
        PageSwitchManager.shared.slideOut(viewController: self)
    }
    @objc
    func onRightBarButtonClicked(_: Any) {
        let cs = CharacterSet.whitespacesAndNewlines
        let username = usernameTextField.text?.trimmingCharacters(in: cs) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: cs) ?? ""
        guard username.count > 0, password.count > 0 else {
            showAlert(title: "请输入用户名和密码", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
            return
        }
        let login = Login(user: username, pass: password)
        login.save()
        NetworkService.login = login
        saveHandler?(login)
        PageSwitchManager.shared.slideOut(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
}
