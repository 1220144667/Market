//
//  HomeViewModel.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import Foundation

enum HomeRequestPath: RequestPath {
    
    case bannerList
    
    var path: String {
        switch self {
        case .bannerList:
            return "/mkt/app/info/scene/list"
        }
    }
}

struct HomeViewModel {
    
    func getBannerList(_ completion: @escaping (_ list: [BannerModel]) -> Void) {
        
    }
}

struct BannerModel: Codable {
    let appCode: String?
}
