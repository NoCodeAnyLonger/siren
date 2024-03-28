//
//  WebViewController.swift
//  siren
//
//  Created by danqin chu on 2020/3/24.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    private let webView: WKWebView = {
        let conf = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: conf)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .green
        return view
    }()
    
    private var leftBBI: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        self.view.backgroundColor = .white
        webView.navigationDelegate = self
        self.view.addSubview(progressView)
        
        self.navigationItem.title = "Readhub"
        leftBBI = UIBarButtonItem(title: "<<", style: .plain, target: self, action: #selector(onGoBack(_:)))
        self.navigationItem.leftBarButtonItem = leftBBI
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc
    func onGoBack(_ sender: Any) {
//        UPPaymentControl.default().startPay("594191447766117011000", fromScheme: SCHEME, mode: "00", viewController: self)
        webView.goBack()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let nv = change?[.newKey] as? String {
                self.navigationItem.title = nv
            }
        } else {
            if let nv = change?[.newKey] as? Double {
                if nv >= 0.0 && nv < 1.0 {
                    progressView.isHidden = false
                    self.view.setNeedsLayout()
                } else {
                    progressView.isHidden = true
                }
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        let r0 = self.view.bounds
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            //webView.frame = r0.inset(by: self.view.safeAreaInsets)
            insets = self.view.safeAreaInsets
        } else {
            //webView.frame = r0.inset(by: UIEdgeInsets(top: self.topLayoutGuide.length, left: 0.0, bottom: self.bottomLayoutGuide.length, right: 0.0))
            insets = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0.0, bottom: self.bottomLayoutGuide.length, right: 0.0)
        }
        webView.frame = r0.inset(by: insets)
        progressView.frame = CGRect(x: insets.left, y: insets.top, width: (r0.width - insets.left - insets.right) * CGFloat(webView.estimatedProgress), height: 1.0)
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func testGoBack() {
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItem = leftBBI
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //testGoBack()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //testGoBack()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //testGoBack()
    }
    
}

extension WebViewController {
    
//    func loadWXH5Pay(prepayId: String, ) {
//        
//    }
    
}
