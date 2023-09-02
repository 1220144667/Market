//
//  MktCollectionViewController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/2.
//

import Foundation

class MktCollectionViewController: MktViewController {
    //起始页
    var pageIndex: Int = 1
    //每页条数
    var pageSize: Int = 10
    //布局
    var layout: UICollectionViewFlowLayout?
    //列表
    lazy var collectionView: UICollectionView = {
        let collection: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: self.layout ?? UICollectionViewFlowLayout())
        collection.keyboardDismissMode = .onDrag
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        return collection
    }()
}

// MARK: collectionView 扩展
extension UICollectionView {
    //注册
    func register(_ cellClass: AnyClass) {
        return self.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
    }
    //重用
    func dequeueReusableCell(_ cellClass: AnyClass, _ indexPath: IndexPath) -> UICollectionViewCell? {
        return self.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cellClass), for: indexPath)
    }
}
