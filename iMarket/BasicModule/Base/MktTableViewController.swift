//
//  MktTableViewController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/2.
//

import Foundation

class MktTableViewController: MktViewController {
    //起始页
    var page: Int = 1
    //每页条数
    var pageSize: Int = 10
    //style
    var style: UITableView.Style = .plain
    //insert
    var insert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: Mkt.safe_bottom, right: 0)
    //列表
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.scrollsToTop = true
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        tableView.contentInset = insert
        return tableView
    }()
}

// MARK: tableivew 扩展
extension UITableView {
    //注册
    func register(_ cellClass: AnyClass) {
        self.register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }
    //重用
    func dequeueReusableCell(_ cellClass: AnyClass) -> UITableViewCell? {
        self.dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier)
    }
}
