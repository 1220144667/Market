//
//  MktNavigatonController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import UIKit

class MktNavigatonController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var isHidden = true
    
    fileprivate weak var popGestureDelegate: UIGestureRecognizerDelegate?
    
    fileprivate var interactivePopTransition: UIPercentDrivenInteractiveTransition?
    
    fileprivate var popEdgePanGesture: UIScreenEdgePanGestureRecognizer?
    
    //是否开启系统右滑返回
    var isSystemSlidBack: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationBar.isHidden = self.isHidden;
        self.popGestureDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self;
        //默认开启系统右划返回
        self.interactivePopGestureRecognizer?.isEnabled = true;
        self.interactivePopGestureRecognizer?.delegate = self;
        
        //只有在使用转场动画时，禁用系统手势，开启自定义右划手势
        popEdgePanGesture = UIScreenEdgePanGestureRecognizer.init(target: self,
                                                                  action: #selector(handleNavigationTransition(_:)))
        popEdgePanGesture?.edges = UIRectEdge.left;
        popEdgePanGesture?.isEnabled = false
        self.view.addGestureRecognizer(popEdgePanGesture!)
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        } else {
            // Fallback on earlier versions
        }
        let color: UIColor = .textColor
        self.navigationBar.tintColor = color
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
        self.navigationBar.titleTextAttributes = titleTextAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let haveMoreThanOneChildViewController = self.viewControllers.count > 1
        self.hidesBottomBarWhenPushed = haveMoreThanOneChildViewController ? true : false
        self.navigationController?.navigationBar.isHidden = haveMoreThanOneChildViewController ? false : true
    }

    @objc
    func handleNavigationTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        let progress = recognizer.translation(in: self.view).x / self.view.bounds.width
        
        let recognizerState = recognizer.state
        switch recognizerState {
        case .began:
            self.interactivePopTransition = UIPercentDrivenInteractiveTransition.init()
            self.popViewController(animated: true)
        case .changed:
            self.interactivePopTransition?.update(progress)
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: recognizer.view)
            if progress > 0.5 || velocity.x > 100 {
                self.interactivePopTransition?.finish()
            } else {
                self.interactivePopTransition?.cancel()
            }
            self.interactivePopTransition = nil
        default:
            break
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if self.isSystemSlidBack ?? false {
            self.interactivePopGestureRecognizer?.isEnabled = true
            self.popEdgePanGesture?.isEnabled = false
        }else{
            self.interactivePopGestureRecognizer?.isEnabled = false
            self.popEdgePanGesture?.isEnabled = true
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.viewControllers.count == 1 ? false : true
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let hasChildViewController = self.viewControllers.count > 0
        if hasChildViewController {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
        
        if hasChildViewController {
            viewController.navigationController?.navigationBar.isHidden = false
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topViewController = self.topViewController {
            return topViewController.preferredStatusBarStyle
        }
        return self.preferredStatusBarStyle
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactivePopTransition
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}


extension UINavigationController {
    
    class func configNavigationBarAppearance() {
        DispatchQueue.once(NSStringFromClass(UINavigationController.self)) {
            let appearance = UINavigationBar.appearance()
            appearance.shadowImage = UIImage()
            appearance.tintColor = UIColor.textColor //前景色，按钮颜色
            appearance.isTranslucent = false // 导航条背景是否透明
            appearance.barTintColor = .white //背景色，导航条背景色
            appearance.backgroundColor = .white
            let titleColor = UIColor.textColor
            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: titleColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ]
            appearance.titleTextAttributes = titleTextAttributes
            
            if #available(iOS 15.0, *) {
                let newAppearance = UINavigationBarAppearance()
                newAppearance.configureWithOpaqueBackground()
                newAppearance.backgroundColor = .white
                newAppearance.shadowImage = UIImage()
                newAppearance.shadowColor = nil
                newAppearance.titleTextAttributes = titleTextAttributes
                appearance.standardAppearance = newAppearance
                appearance.scrollEdgeAppearance = appearance.standardAppearance
            }
        }
    }
    //设置背景透明度
    fileprivate func setNeedsNavigationBackground(alpha: CGFloat) {
        if let barBackgroundView = navigationBar.subviews.first {
            let valueForKey = barBackgroundView.getIvar(forKey:)
            
            if let shadowView = valueForKey("_shadowView") as? UIView {
                shadowView.alpha = alpha
                shadowView.isHidden = alpha == 0
            }
            
            if navigationBar.isTranslucent {
                if #available(iOS 10.0, *) {
                    if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                        backgroundEffectView.alpha = alpha
                        return
                    }
                    
                } else {
                    if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                        backdropEffectView.alpha = alpha
                        return
                    }
                }
            }
            barBackgroundView.alpha = alpha
        }
    }
}

extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var navBarBgAlpha: CGFloat = 1.0
        static var navBarTintColor: UIColor = UIColor.baseColor
    }
    
    public var navBarBgAlpha: CGFloat {
        get {
            guard let alpha = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgAlpha) as? CGFloat else {
                return 1.0
            }
            return alpha
            
        }
        set {
            let alpha = max(min(newValue, 1), 0) // 必须在 0~1的范围
            
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Update UI
            navigationController?.setNeedsNavigationBackground(alpha: alpha)
        }
    }
    
    public var navBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarTintColor) as? UIColor else {
                return UIColor.baseColor
            }
            return tintColor
        }
        set {
            navigationController?.navigationBar.tintColor = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension NSObject {
    func getIvar(forKey key: String) -> Any? {
        guard let _var = class_getInstanceVariable(type(of: self), key) else {
            return nil
        }
        
        return object_getIvar(self, _var)
    }
}
