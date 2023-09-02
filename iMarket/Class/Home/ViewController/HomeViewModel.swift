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
        let path = HomeRequestPath.bannerList
        var param: [String: Any] = [:]
        param["access_token"] = "afe6fa65-f8c8-473f-88c6-805bf726e973"
        param["apiVersion"] = "2"
        param["clientVersion"] = "1.1.6"
        param["page"] = "1"
        param["sceneId"] = "12"
        param["size"] = "10"
        param["softType"] = "lyz_ios"
        param["userId"] = "218970"
        Mkt.requestToGet(path: path, query: param, type: [BannerModel].self) { response in
            guard let list = response.retData else { return }
            completion([list])
        } failure: { error in
            dlog(message: error)
        }
    }
}

struct BannerModel: Codable {
    let appCode: String?
}
