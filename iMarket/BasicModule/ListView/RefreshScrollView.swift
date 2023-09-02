//
//  RefreshScrollView.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

extension UIScrollView {
    
    /// 添加下拉刷新
    /// - Parameter refreshHandler: 回调
    func addPullDownRefresh(_ refreshHandler: @escaping MktParamlessClosure) {
        if self.mj_header == nil {
            let header = RefreshGradientTextHeader.init(refreshingBlock: refreshHandler)
            self.mj_header = header
        } else {
            self.mj_header?.refreshingBlock = refreshHandler
        }
    }
    
    /// 添加上拉加载更多
    /// - Parameter moreHandler: 回调
    func addPullUpMore(_ moreHandler: @escaping MktParamlessClosure) {
        if self.mj_footer == nil {
            let footer = MJRefreshAutoNormalFooter.init(refreshingBlock: moreHandler)
            footer.stateLabel?.font = .systemFont(ofSize: 14)
            footer.setTitle("", for: .idle)
            footer.setTitle("", for: .noMoreData)
            footer.isRefreshingTitleHidden = true
            self.mj_footer = footer
        } else {
            self.mj_footer?.refreshingBlock = moreHandler
        }
    }
    
    //主动开始加载
    func beginPullDownRefresh() {
        self.mj_header?.beginRefreshing()
    }
    
    //下拉刷新完成
    func endPullDownRefresh() {
        if self.mj_header?.isRefreshing ?? false {
            self.mj_header?.endRefreshing()
        }
    }
    
    //上拉加载结束
    func endPullUpMore(_ hasMore: Bool) {
        if self.mj_footer?.isRefreshing ?? false {
            if hasMore {
                self.mj_footer?.resetNoMoreData()
                self.mj_footer?.endRefreshing()
            } else {
                self.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
}
