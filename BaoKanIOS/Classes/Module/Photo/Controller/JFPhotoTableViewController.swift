//
//  JFPhotoTableViewController.swift
//  BaoKanIOS
//
//  Created by jianfeng on 16/1/1.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit
import SDCycleScrollView
import MJRefresh
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class JFPhotoTableViewController: UITableViewController, SDCycleScrollViewDelegate {
    
    /// 分类数据
    var classid: Int? {
        didSet {
            loadNews(classid!, pageIndex: 1, method: 0)
        }
    }
    
    // 页码
    var pageIndex = 1
    
    /// 模型数组
    var photoList = [JFArticleListModel]()
    
    /// 新闻cell重用标识符
    let newsReuseIdentifier = "newsReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(JFPhotoListCell.self, forCellReuseIdentifier: newsReuseIdentifier)
        tableView.rowHeight = 200
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let headerRefresh = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(updateNewData))
        headerRefresh?.lastUpdatedTimeLabel.isHidden = true
        tableView.mj_header = headerRefresh
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }
    
    /**
     下拉加载最新数据
     */
    @objc fileprivate func updateNewData() {
        loadNews(classid!, pageIndex: 1, method: 0)
    }
    
    /**
     上拉加载更多数据
     */
    @objc fileprivate func loadMoreData() {
        pageIndex += 1
        loadNews(classid!, pageIndex: pageIndex, method: 1)
    }
    
    /**
     根据分类id、页码加载数据
     
     - parameter classid:    当前栏目id
     - parameter pageIndex:  当前页码
     - parameter method:     加载方式 0下拉加载最新 1上拉加载更多
     */
    fileprivate func loadNews(_ classid: Int, pageIndex: Int, method: Int) {
        
        JFArticleListModel.loadNewsList("photo", classid: classid, pageIndex: pageIndex, type: 1) { (articleListModels, error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            guard let list = articleListModels else {
                return
            }
            
            if error != nil {
                return
            }
            
            
            if list.count == 0 {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
                return
            }
            
            // id越大，文章越新
            let maxId = self.photoList.first?.id ?? "0"
            let minId = self.photoList.last?.id ?? "0"
            
            if method == 0 {
                // 0下拉加载最新 - 会直接覆盖数据，用最新的10条数据
                if Int(maxId) < Int(list[0].id!) {
                    self.photoList = list
                }
            } else {
                // 1上拉加载更多 - 拼接数据
                if Int(minId) > Int(list[0].id!) {
                    self.photoList = self.photoList + list
                } else {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsReuseIdentifier) as! JFPhotoListCell
        cell.postModel = photoList[indexPath.row]
        cell.cellHeight = 200
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentListModel = photoList[indexPath.row]
        let detailVc = JFPhotoDetailViewController()
        detailVc.photoParam = (currentListModel.classid!, currentListModel.id!)
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! JFPhotoListCell).cellOffset()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let array = tableView.visibleCells
        for cell in array {
            // 里面的图片跟随移动
            (cell as! JFPhotoListCell).cellOffset()
        }
        
    }
    
}
