//
//  UserManager.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

class UserManager {
    //单例
    static var shared = UserManager()
    private init() {}
    
    //用户信息
    var user: UserModel?
    
    var token: String {
        var authorization = ""
        let tokenKey = UserManager.UserKey.tokenKey
        if let token = UserDefaults.standard.object(forKey: tokenKey) as? String {
            authorization = token
        }
        return authorization
    }
    
    //缓存user的key
    struct UserKey {
        static let userInfoKey = "Mkt_UserInfo_key"
        //token
        static let tokenKey = "Mkt_Token_Key"
    }
}

struct UserModel {
    let token: String?
}
