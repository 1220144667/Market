//
//  Extension+APP.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

extension Mkt {
    
    struct APP {
        //是否已登录
        static var isLogin: Bool {
            return !UserManager.shared.token.isEmpty
        }
        
    }
}
