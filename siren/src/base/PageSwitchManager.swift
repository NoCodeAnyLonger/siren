//
//  PageSwitchManager.swift
//  NewK12
//
//  Created by danqin chu on 2019/7/23.
//  Copyright © 2019 NetEase. All rights reserved.
//

import UIKit

/**
 * - UIViewController（简称 vc) 可以被 push （通过 UINavigationController，简称 nc) 或者 present 出来
 * - 对于 present，如果 vc 正在被 present 或者 dismiss，则等待结束后，再次尝试从顶部 vc present
 * - slideIn 先尝试用 nc push，否则用 present
 * - 如果 vc 是 nc 的 root-vc，方法 slideOut(XXX) 等同于 dismiss，否则，执行 pop
 * - dismiss 调用 vc.presentingVC 的 dismiss，如果 vc 没有 presentingVC，则调用 pop
 */

class PageSwitchManager {

    static let shared = PageSwitchManager(windowClosure: {
        if let d = UIApplication.shared.delegate?.window ?? nil {
            if let window = d.window {
                return window
            }
        }
        return UIApplication.shared.keyWindow
    })
    
    private var windowClosure: () -> UIWindow?
    
    var rootViewController: UIViewController? {
        if let win = windowClosure() {
            return win.rootViewController
        }
        return nil
    }
    
    var topViewController: UIViewController? {
        if let vc = rootViewController {
            return findTopViewController(from: vc)
        }
        return nil
    }
    
    init(windowClosure: @escaping () -> UIWindow?) {
        self.windowClosure = windowClosure
    }
    
    @discardableResult
    func push(viewController: UIViewController, from parent: UIViewController? = nil, animated: Bool = true) -> Bool {
        guard let topVC = parent ?? topViewController else {
            return false
        }
        if !PageSwitchManager.canSwitch(viewController: topVC) {
            return false
        }
        if let nc = topVC.navigationController {
            nc.pushViewController(viewController, animated: animated)
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func pop(from viewController: UIViewController? = nil, toViewController matches: (UIViewController) -> Bool, animated: Bool = true) -> [UIViewController]? {
        var nc: UINavigationController? = nil
        var targetVC: UIViewController!
        if let mnc = viewController as? UINavigationController {
            nc = mnc
            targetVC = mnc
        } else if let fromVC = viewController ?? topViewController {
            nc = fromVC.navigationController
            targetVC = fromVC
        }
        
        if let mnc = nc {
            let children = mnc.viewControllers
            var index: Int
            if let _ = targetVC as? UINavigationController {
                index = children.count - 1
            } else if let i = children.lastIndex(of: targetVC) {
                index = i
            } else {
                index = -1
            }
            while index >= 0 {
                let vc = children[index]
                if matches(vc) {
                    return mnc.popToViewController(vc, animated: animated)
                }
                index = index - 1
            }
        }
        return nil
    }
    
    func pop(viewController: UIViewController?, animated: Bool = true) {
        pop(from: viewController, toViewController: { (vc) -> Bool in
            return vc != viewController
        }, animated: animated)
    }
    
    func popToRoot(from viewController: UIViewController?, animated: Bool = true) {
        let fromVC = viewController ?? topViewController
        if let nc = fromVC as? UINavigationController {
            nc.popToRootViewController(animated: animated)
        } else if let nc = fromVC?.navigationController {
            nc.popToRootViewController(animated: animated)
        }
    }
    
    func present(viewController: UIViewController,
                 hasNavigationBar: Bool = false,
                 animated: Bool = true,
                 completion: (() -> Void)? = nil) {
        guard let topVC = topViewController else {
            // Log
            assert(false)
            return
        }
        presentInternal(topVC, viewController: viewController, hasNavigationBar: hasNavigationBar, animated: animated, completion: completion)
    }
    
    private func presentInternal(_ topVC: UIViewController,
                                 viewController: UIViewController,
                                 hasNavigationBar: Bool,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
        if topVC == viewController || PageSwitchManager.isChildViewController(topVC, viewController) {
            return
        }
        if !PageSwitchManager.canSwitch(viewController: topVC) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.present(viewController: viewController, hasNavigationBar: hasNavigationBar, animated: animated, completion: completion)
            }
            return
        }
        let presentedVC = hasNavigationBar && !viewController.isKind(of: UIAlertController.self) ? UINavigationController(rootViewController: viewController) : viewController
        topVC.present(presentedVC, animated: animated, completion: completion)
    }
    
    func dismiss(viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if !PageSwitchManager.canSwitch(viewController: viewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.dismiss(viewController: viewController, animated: animated, completion: completion)
            }
            return
        }
        if let presentingVC = viewController.presentingViewController {
            presentingVC.dismiss(animated: animated, completion: completion)
        } else {
            // OOPS! viewController may be pushed into UINavigationController
            pop(viewController: viewController, animated: animated)
        }
    }
    
    func dismissTopViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let topVC = topViewController {
            dismiss(viewController: topVC, animated: animated, completion: completion)
        }
    }
    
    func dismiss(from viewController: UIViewController? = nil, toViewController matches: (UIViewController) -> Bool, animated: Bool, completion: (() -> Void)? = nil) {
        var currentVC = viewController ?? topViewController
        while let vc = currentVC {
            if matches(vc) {
                break
            }
            currentVC = vc.presentingViewController
        }
        if let vc = currentVC?.presentedViewController {
            dismiss(viewController: vc, animated: animated, completion: completion)
        }
    }
    
    func slideIn(viewController: UIViewController, animated: Bool = true) {
        guard let topVC = topViewController else {
            return
        }
        if !push(viewController: viewController, from: topVC, animated: animated) {
            presentInternal(topVC, viewController: viewController, hasNavigationBar: true, animated: animated, completion: nil)
        }
    }
    
    func slideOut(viewController: UIViewController, animated: Bool = true) {
        if let nc = viewController.navigationController {
            let children = nc.viewControllers
            if let index = children.lastIndex(of: viewController) {
                if index == 0 { // first and top vc
                    dismiss(viewController: viewController, animated: animated, completion: nil)
                } else if index == children.count - 1 {
                    // viewController is the top one
                    nc.popViewController(animated: animated)
                } else {
                    nc.popToViewController(children[index-1], animated: animated)
                }
            } else {
                assert(false) // should not happened, no-op in release mode
            }
        } else {
            dismiss(viewController: viewController, animated: animated, completion: nil)
        }
    }
    
    func slideOutTopViewController(animated: Bool = true) {
        if let topVC = topViewController {
            self.slideOut(viewController: topVC)
        }
    }
    
    func slideOut(from viewController: UIViewController? = nil, toViewController matches: (UIViewController) -> Bool, animated: Bool) {
        let startVC = viewController ?? topViewController
        var presentedVC = startVC
        while presentedVC != nil {
            if matches(presentedVC!) {
                break
            }
            if let nvc = pop(from: presentedVC, toViewController: matches, animated: animated), nvc.count > 0 {
                break
            }
            presentedVC = presentedVC?.presentingViewController
        }
        // startViewController 在最顶层，则移除掉 toViewController 上面的 VC
        if startVC?.presentedViewController == nil, let vc = presentedVC?.presentedViewController {
            dismiss(viewController: vc, animated: animated, completion: nil)
        }
    }
    
    func slideOutToRoot(from: UIViewController? = nil, animated: Bool = true) {
        if let rootVC = rootViewController, let vc = rootVC.presentedViewController {
            popToRoot(from: from, animated: false)
            dismiss(viewController: vc, animated: animated) {
                self.popToRoot(from: rootVC, animated: animated)
            }
        } else {
            popToRoot(from: from, animated: animated)
        }
    }
}

extension PageSwitchManager {
    
    private static func canSwitch(viewController: UIViewController) -> Bool {
        var vc = viewController
        while true {
            if !_canSwitch(viewController: vc) {
                return false
            }
            if let avc = vc.parent {
                vc = avc
            } else {
                return true
            }
        }
    }
    
    private static func _canSwitch(viewController: UIViewController) -> Bool {
        return !viewController.isBeingDismissed && !viewController.isBeingPresented && !viewController.isMovingToParent && !viewController.isMovingFromParent
    }
    
    private static func isChildViewController(_ child: UIViewController, _ parent: UIViewController) -> Bool {
        var vc = child
        while let p = vc.parent {
            if p == parent {
                return true
            }
            vc = p
        }
        return false
    }
    
    private func findTopViewController(from vc: UIViewController) -> UIViewController {
        if let presentedVC = vc.presentedViewController {
            return findTopViewController(from: presentedVC)
        } else if let splitVC = vc as? UISplitViewController {
            if let lastVC = splitVC.viewControllers.last {
                return findTopViewController(from: lastVC)
            }
        } else if let nav = vc as? UINavigationController {
            if let topVC = nav.topViewController {
                return findTopViewController(from: topVC)
            }
        } else if let tab = vc as? UITabBarController {
            if let selectedVC = tab.selectedViewController {
                return findTopViewController(from: selectedVC)
            }
        }
        return vc
    }
    
}
