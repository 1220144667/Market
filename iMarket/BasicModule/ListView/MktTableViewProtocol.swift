//
//  MktTableViewProtocol.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

extension UITableView {
    /// 使用此方法代替UITableView的reloadData方法，自动实现
    /// - Parameter mkt: 遵守MktTableViewProtocol的类实例
    func mkt_reloadData(_ mkt: any MktTableViewProtocol) {
        mkt.reloadTableViewData()
    }
}

extension UICollectionView {
    /// 使用此方法代替UICollectionView的reloadData方法，自动实现
    /// - Parameter mkt: 遵守MktCollectionViewProtocol的类实例
    func mkt_reloadData(_ mkt: any MktCollectionViewProtocol) {
        mkt.reloadCollectionViewData()
    }
}

public protocol MktEmptyProtocol {
    //返回一个占位的View
    func makeEmptyView() -> UIView?
    
    //是否支持占位View滚动
    func enableScrollToEmpryView() -> Bool
    
    //点击事件
    func didReloadData()
}

public protocol MktTableViewProtocol: MktEmptyProtocol {
    //数据
    func numberInTableView() -> Int
    
    //返回一个tableview
    func makeTableView() -> UITableView
    
    //tableView刷新
    func reloadTableViewData()
}

//默认实现
extension MktTableViewProtocol {
    
    //默认返回一个空数据
    func numberInTableView() -> Int {
        return 0
    }
    //刷新
    func reloadTableViewData() {
        //获取tableView
        let tableView = self.makeTableView()
        //设置tableView是否可滚动
        tableView.isScrollEnabled = self.enableScrollToEmpryView()
        //刷新tableView
        tableView.reloadData()
        //添加空数据背景
        guard let emptyView = self.makeEmptyView() else { return }
        if self.numberInTableView() == 0 && !tableView.isDescendant(of: emptyView) {
            emptyView.frame = tableView.frame
            tableView.addSubview(emptyView)
            return
        }
        emptyView.removeFromSuperview()
    }
    
    //默认可以滚动
    func enableScrollToEmpryView() -> Bool {
        return true
    }
}

public protocol MktCollectionViewProtocol: MktEmptyProtocol {
    //数据
    func numberInCollectionView() -> Int
    //返回一个collectionview
    func makeCollectionView() -> UICollectionView
    
    //collectionView刷新
    func reloadCollectionViewData()
}

extension MktCollectionViewProtocol {
    func numberInCollectionView() -> Int {
        return 0
    }
    
    func reloadCollectionViewData() {
        let collectionView = self.makeCollectionView()
        collectionView.isScrollEnabled = self.enableScrollToEmpryView()
        collectionView.reloadData()
        guard let emptyView = self.makeEmptyView() else { return }
        if self.numberInCollectionView() == 0 && !collectionView.isDescendant(of: emptyView) {
            emptyView.frame = collectionView.frame
            collectionView.addSubview(emptyView)
            return
        }
        emptyView.removeFromSuperview()
    }
    
    //默认可以滚动
    func enableScrollToEmpryView() -> Bool {
        return true
    }
}

//空数据界面事件类型
public enum EmptyActionType: Int {
    case goLogin = 0
    case checkNetwork = 1
    case refresh = 2
}
