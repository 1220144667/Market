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
            return "jj_ss"
        }
    }
}

struct HomeViewModel {
    
    func getBannerList(_ completion: @escaping (_ list: [BannerModel]) -> Void) {
        let path = HomeRequestPath.bannerList
        Mkt.requestToGet(path: path, type: [BannerModel].self) { response in
            guard let list = response.data else { return }
            completion(list)
        } failure: { error in
            dlog(message: error)
        }
    }
}

struct BannerModel: Codable {
    let url: String
}
