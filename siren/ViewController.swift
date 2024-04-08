//
//  ViewController.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit

func alertOnOpenFailed(type: String) {
    let action = UIAlertAction(title: "好", style: .default, handler: nil)
    showAlert(title: "请安装\(type)", message: nil, actions: action)
}

var appVersion: String {
    if let info = Bundle.main.infoDictionary {
        return info["CFBundleShortVersionString"] as? String ?? ""
    }
    
    return ""
}

var buildVersion: String {
    if let info = Bundle.main.infoDictionary {
        return info["CFBundleVersion"] as? String ?? ""
    }
    
    return ""
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
        self.navigationItem.title = "订单列表\(appVersion).\(buildVersion)"
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
            self.sortPayInfos()
            self.tableView.reloadData()
            if self.data.count == 0 {
                showAlert(title: "没有订单", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
            }
        }) { (error) in
            showAlert(title: "获取订单失败", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
        }
    }
    
    private func handlePaying(payInfo: PayInfo) {
        NetworkService.updateOrder(with: payInfo.order_id, status: .paying, success: { [weak self] (params) in
            payInfo.status = .paying
            self?.sortPayInfos()
            self?.tableView.reloadData()
        }) { (error) in
            showAlert(title: "更新订单失败", message: nil, actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
        }
    }
    
    private func handleSuccess(payInfo: PayInfo) {
        NetworkService.updateOrder(with: payInfo.order_id, status: .paid, success: { [weak self] (params) in
            payInfo.status = .paid
            self?.sortPayInfos()
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
        let info = data[indexPath.row]
        return PayInfoCell.fitSize(size: tableView.bounds.size, for: info).height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = data[indexPath.row]
        if info.status == .paid {
            showAlert(title: "已支付", message: "", actions: UIAlertAction(title: "好", style: .default, handler: nil))
            return
        }
        handlePaying(payInfo: info)
        if info.paytype == "微信" {
            guard let wxinfo = info.wxpayInfo else {
                showAlert(title: nil, message: "微信订单错误", actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
                return
            }
            BlackCastle.NightKing.open(with: wxinfo.appid, partnerId: wxinfo.partnerid, prepayId: wxinfo.prepayid, nonceStr: wxinfo.noncestr, timeStamp: wxinfo.timestamp, sign: wxinfo.sign, signType: wxinfo.signType, onOpen: { (os) in
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
        } else if info.paytype == "云闪付" {
            guard let tn = info.uppayInfo?.tn else {
                showAlert(title: nil, message: "云闪付订单错误", actions: UIAlertAction(title: "好", style: .cancel, handler: nil))
                return
            }
            guard UPPaymentControl.default().isPaymentAppInstalled() else {
                alertOnOpenFailed(type: info.paytype)
                return
            }
            UPPaymentControl.default().startPay(tn, fromScheme: SCHEME, mode: "00", viewController: self)
        }
    }
    
    func sortPayInfos() {
        data.sort { (pi1, pi2) -> Bool in
            if pi1.status == pi2.status {
                return pi1.ordertime < pi2.ordertime
            }
            return pi1.status.sortPriority > pi2.status.sortPriority
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

