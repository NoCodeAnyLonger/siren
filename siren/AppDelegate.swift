//
//  AppDelegate.swift
//  siren
//
//  Created by danqin chu on 2020/3/16.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit
import nosin
import HandyJSON

struct MModel: HandyJSON {
    var charset: String = ""
    var timestamp: String = ""
}

public let SCHEME = "foosirenbar"

extension UIWindow {
    
    func _load0() {
        self.rootViewController = UINavigationController(rootViewController: WebViewController())
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let dict = [
            "charset": "UTF-8",
            "timestamp": "2020-03-24 11:15:16"
        ]
//        var queryItems = [URLQueryItem]()
//        dict.forEach { (key, value) in
//            let v = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//            let qi = URLQueryItem(name: key, value: v?.replacingOccurrences(of: ",", with: "%2C"))
//            queryItems.append(qi)
//        }
//        queryItems.sort { (qi1, qi2) -> Bool in
//            return qi1.name < qi2.name
//        }
//        var uc = URLComponents()
//        uc.queryItems = queryItems
//        print(uc.query!)
        let model = MModel.deserialize(from: dict)
        print(model)
//        BlackCastle.Commander.open(from: SCHEME, order: uc.query!, onOpen: nil) { (resp) in
//            print(resp.rawCode!)
//        }
        window?._load0()
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return BlackCastle.handleCallback(url: url)
    }

}

