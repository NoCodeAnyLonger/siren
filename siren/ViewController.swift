//
//  ViewController.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit
import nosin
import HandyJSON

func alertOnOpenFailed(type: String) {
    let action = UIAlertAction(title: "好", style: .default, handler: nil)
    showAlert(title: "请安装\(type)", message: nil, actions: action)
}

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var data = [PayInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PayInfoCell.self, forCellReuseIdentifier: "0")
        
        NetworkService.authErrorHandler = { _ in
            showAlert(title: "请设置用户名和密码", message: nil, actions: UIAlertAction(title: "好", style: .default, handler: { [weak self] _ in
                self?.showLogin()
            }))
        }
        self.navigationItem.title = "订单列表"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "设置用户", style: .plain, target: self, action: #selector(onLeftBarButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(onRightBarButtonClicked(_:)))
        
        refreshOrders()
    }
    
    @objc
    func onLeftBarButtonClicked(_: Any) {
        showLogin()
    }
    
    @objc
    func onRightBarButtonClicked(_: Any) {
        refreshOrders()
    }
    
    private func showLogin() {
        let vc = LoginController()
        vc.saveHandler = { [weak self] _ in
            self?.refreshOrders()
        }
        PageSwitchManager.shared.present(viewController: vc, hasNavigationBar: true, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = self.view.bounds
    }
    
    func refreshOrders() {
        NetworkService.queryOrders(success: { (value) in
            self.data = value ?? []
            self.tableView.reloadData()
        }) { (error) in
            showAlert(title: "获取订单失败", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
        }
    }
    
    private func handleSuccess(payInfo: PayInfo) {
        NetworkService.updateOrder(with: payInfo.order_id, status: .paid, success: { [weak self] (params) in
            payInfo.status = .paid
            self?.tableView.reloadData()
        }) { (error) in
            showAlert(title: "更新订单失败", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
        }
        
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "0", for: indexPath) as! PayInfoCell
        let info = data[indexPath.row]
        cell.update(with: info)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = data[indexPath.row]
        if info.status == .paid {
            showAlert(title: "已支付", message: "", actions: UIAlertAction(title: "好", style: .default, handler: nil))
            return
        }
        if info.paytype == "微信" {
            guard let wxinfo = info.wxpayInfo else {
                return
            }
            BlackCastle.NightKing.open(with: SCHEME, partnerId: wxinfo.partnerid, prepayId: wxinfo.prepayid, nonceStr: wxinfo.noncestr, timeStamp: wxinfo.timestamp, sign: wxinfo.sign, signType: nil, onOpen: { (os) in
                if os == .failure {
                    alertOnOpenFailed(type: info.paytype)
                }
            }) { [weak self] (resp) in
                if let msg = resp.customErrorMsg {
                    showAlert(title: nil, message: msg, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
                } else {
                    self?.handleSuccess(payInfo: info)
                }
            }
        } else if info.paytype == "支付宝" {
            guard let order = info.alipayInfo else {
                showAlert(title: nil, message: "支付宝订单错误", actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
                return
            }
            BlackCastle.Commander.open(from: SCHEME, order: order, onOpen: { (os) in
                if os == .failure {
                    alertOnOpenFailed(type: info.paytype)
                }
            }) { [weak self] (resp) in
                if let msg = resp.customErrorMsg {
                    showAlert(title: nil, message: msg, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
                } else {
                    self?.handleSuccess(payInfo: info)
                }
            }
        }
    }
    
}

extension BlackCastle.NightKing.Response {
    var customErrorMsg: String? {
        if let code = self.code {
            if code == .success {
                return nil
            } else if code == .userCancelled {
                return "微信支付取消了"
            }
        }
        return "微信支付出错了"
    }
}

extension BlackCastle.Commander.Response {
    var customErrorMsg: String? {
        if let code = self.code {
            if code == .success {
                return nil
            } else if code == .userCancelled {
                return "支付宝支付取消了"
            }
        }
        return "支付宝支付出错了"
    }
}

