//
//  TabbarController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import Foundation
import ESTabBarController_swift

struct TabbarController {
    static let shared = TabbarController()
    private init() {}
    
    func customBouncesStyle() -> ESTabBarController {
        let tabBarController = ESTabBarController()
        self.applyCurvedShadow(tabBarController.tabBar)
        let v1 = HomeViewController()
        let v2 = MarketViewController()
        let v3 = MessageViewController()
        let v4 = MineViewController()
        v1.tabBarItem = ESTabBarItem.init(BouncesView(), title: "首页", image: UIImage(named: "tabbar_shouye_normal"), selectedImage: UIImage(named: "tabbar_shouye_select"))
        v2.tabBarItem = ESTabBarItem.init(BouncesView(), title: "极速租", image: UIImage(named: "tabbar_fenlei_normal"), selectedImage: UIImage(named: "tabbar_fenlei_select"))
        v3.tabBarItem = ESTabBarItem.init(BouncesView(), title: "客服", image: UIImage(named: "tabbar_kf_normal"), selectedImage: UIImage(named: "tabbar_kf_select"))
        v4.tabBarItem = ESTabBarItem.init(BouncesView(), title: "我的", image: UIImage(named: "tabbar_mine_normal"), selectedImage: UIImage(named: "tabbar_mine_select"))
        let nav1 = MktNavigatonController.init(rootViewController: v1)
        let nav2 = MktNavigatonController.init(rootViewController: v2)
        let nav3 = MktNavigatonController.init(rootViewController: v3)
        let nav4 = MktNavigatonController.init(rootViewController: v4)
        tabBarController.viewControllers = [nav1, nav2, nav3, nav4]
        tabBarController.view.backgroundColor = .white
        return tabBarController
    }
    
    //添加tabbar阴影
    func applyCurvedShadow(_ tabBar: UITabBar) {
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().backgroundImage = UIImage()
        let path = CGMutablePath()
        path.addRect(tabBar.bounds)
        tabBar.layer.shadowPath = path
        path.closeSubpath()
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize.init(width: 0, height: -4)
        tabBar.layer.shadowRadius = 12
        tabBar.layer.shadowOpacity = 0.06
        tabBar.layer.masksToBounds = false
        tabBar.tintColor = .themColor
    }
}
