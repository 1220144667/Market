//
//  HomeViewController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import UIKit

class HomeViewController: MktTableViewController {
    
    var viewModel = HomeViewModel()
    
    var banners: [BannerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }
    
    func commonInit() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(HomeCell.self)
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(0)
        }
        self.tableView.addPullDownRefresh { [weak self] in
            guard let self = self else { return }
            self.getDataList()
        }
        self.tableView.beginPullDownRefresh()
    }
    
    func getDataList() {
        self.viewModel.getBannerList { [weak self] list in
            guard let self = self else { return }
            self.banners = list
            self.tableView.mkt_reloadData(self)
            self.tableView.endPullDownRefresh()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.banners.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(HomeCell.self) as! HomeCell
        
        return cell
    }
}

//MktTableViewProtocol
extension HomeViewController: MktTableViewProtocol {
    
    func didReloadData() {
        self.tableView.beginPullDownRefresh()
    }
    
    func numberInTableView() -> Int {
        return self.banners.count
    }
    
    func makeTableView() -> UITableView {
        return self.tableView
    }
    
    func makeEmptyView() -> UIView? {
        return EmptyContentView().show(delegate: self)
    }
}

class HomeCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
