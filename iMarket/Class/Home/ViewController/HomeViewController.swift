//
//  HomeViewController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import UIKit

class HomeViewController: MktViewController {
    
    var viewModel = HomeViewModel()
    
    var banners: [BannerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }
    
    func commonInit() {
        self.view.backgroundColor = .randomColor
        self.viewModel.getBannerList { [weak self] list in
            guard let self = self else { return }
            self.banners = list
        }
    }
    
    
}
