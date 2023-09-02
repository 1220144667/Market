//
//  CategoryTableView.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/2.
//

import Foundation

class CategoryTableView: MktTableViewController, MktTableViewProtocol {
    
    typealias Model = BannerModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.mkt_reloadData(self)
    }
    
    func makeDataList() -> [Model] {
        return []
    }
    
    func makeTableView() -> UITableView {
        return self.tableView
    }
    
    func makeCustomEmptyView() -> UIView? {
        return nil
    }
    
    func didActionEvent(_ type: EmptyActionType) {
        
    }
    
}
