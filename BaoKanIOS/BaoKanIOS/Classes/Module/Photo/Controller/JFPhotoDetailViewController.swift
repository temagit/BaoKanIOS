//
//  JFPhotoDetailViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, JFPhotoDetailCellDelegate {
    
    // MARK: - 属性
    /// 文章详情请求参数
    var photoParam: (classid: String, id: String)? {
        didSet {
            loadPhotoDetail(photoParam!.classid, id: photoParam!.id)
        }
    }
    
    let photoIdentifier = "photoDetail"
    var photoModels = [JFPhotoDetailModel]()
    
    // 导航栏/背景颜色
    let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.9)
    
    /// 当前页显示的文字数据
    var currentPageData: (page: Int, text: String)? {
        didSet {
            captionLabel.text = "\(currentPageData!.page)/\(photoModels.count)  \(currentPageData!.text)"
            updateBottomBgViewConstraint()
        }
    }
    
    /// 内容视图
    lazy var collectionView: UICollectionView = {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.itemSize = CGSize(width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT)
        myLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        myLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT), collectionViewLayout: myLayout)
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(JFPhotoDetailCell.self, forCellWithReuseIdentifier: self.photoIdentifier)
        return collectionView
    }()
    
    /// 自定义导航栏
    lazy var navigationBarView: UIView = {
        let navigationBarView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64))
        navigationBarView.backgroundColor = self.bgColor
        
        // 导航栏左边返回按钮
        let leftButton = UIButton(type: UIButtonType.Custom)
        leftButton.setImage(UIImage(named: "top_navigation_back"), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: #selector(didTappedLeftBarButtonItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        leftButton.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        
        // 导航栏右边举报按钮
        let rightButton = UIButton(type: UIButtonType.Custom)
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        rightButton.setTitle("举报", forState: UIControlState.Normal)
        rightButton.setTitleColor(UIColor(red:0.545, green:0.545, blue:0.545, alpha:1), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: #selector(didTappedRightBarButtonItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.frame = CGRect(x: SCREEN_WIDTH - 60, y: 20, width: 40, height: 40)
        
        navigationBarView.addSubview(leftButton)
        navigationBarView.addSubview(rightButton)
        
        return navigationBarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        bottomBgView.removeFromSuperview()
        bottomToolView.removeFromSuperview()
        navigationBarView.removeFromSuperview()
    }
    
    /**
     准备UI
     */
    private func prepareUI() {
        
        self.edgesForExtendedLayout = .None
        self.automaticallyAdjustsScrollViewInsets = false
        
        UIApplication.sharedApplication().keyWindow?.addSubview(navigationBarView)
        view.addSubview(collectionView)
        UIApplication.sharedApplication().keyWindow?.addSubview(bottomToolView)
        bottomToolView.addSubview(commentButton)
        bottomToolView.addSubview(starButton)
        bottomToolView.addSubview(shareButton)
        bottomToolView.addSubview(fontButton)
        UIApplication.sharedApplication().keyWindow?.addSubview(bottomBgView)
        bottomBgView.addSubview(captionLabel)
        
        bottomToolView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        
        bottomBgView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomToolView.snp_top)
            make.height.equalTo(20)
        }
        
        captionLabel.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.width.equalTo(SCREEN_WIDTH - 40)
        }
        
        updateBottomBgViewConstraint()
        
        commentButton.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(bottomToolView.width - 220)
        }
        
        starButton.snp_makeConstraints { (make) in
            make.left.equalTo(commentButton.snp_right).offset(30)
            make.centerY.equalTo(bottomToolView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        shareButton.snp_makeConstraints { (make) in
            make.left.equalTo(starButton.snp_right).offset(30)
            make.centerY.equalTo(bottomToolView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        fontButton.snp_makeConstraints { (make) in
            make.left.equalTo(shareButton.snp_right).offset(30)
            make.centerY.equalTo(bottomToolView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    /**
     更新底部详情视图的高度
     */
    private func updateBottomBgViewConstraint() {
        UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
        
        bottomBgView.snp_updateConstraints { (make) in
            make.height.equalTo(captionLabel.height + 20)
        }
    }
    
    // 滚动停止后调用，判断当然显示的第一张图片
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        
        let page = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        let model = photoModels[page]
        
        currentPageData = (page + 1, model.text!)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier, forIndexPath: indexPath) as! JFPhotoDetailCell
        cell.delegate = self
        cell.model = photoModels[indexPath.item]
        return cell
    }
    
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadPhotoDetail(classid: String, id: String) {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id
        ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    let morepic = successResult["data"]["content"]["morepic"].arrayValue
                    for picJSON in morepic {
                        let dict = [
                            "title" : picJSON.dictionaryValue["title"]!.stringValue, // 图片标题
                            "picurl" : picJSON.dictionaryValue["url"]!.stringValue,  // 图片url
                            "text" : picJSON.dictionaryValue["caption"]!.stringValue // 图片文字描述
                        ]
                        
                        let model = JFPhotoDetailModel(dict: dict)
                        self.photoModels.append(model)
                    }
                    
                    self.scrollViewDidEndDecelerating(self.collectionView)
                    // 刷新视图
                    self.collectionView.reloadData()
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    // MARK: - JFPhotoDetailCellDelegate
    /**
     单击事件
     */
    func didOneTappedPhotoDetailView(scrollView: UIScrollView) -> Void {
        let alpha: CGFloat = UIApplication.sharedApplication().statusBarHidden == false ? 0 : 1
        
        UIView.animateWithDuration(0.25, animations: {
            // 状态栏
            UIApplication.sharedApplication().statusBarHidden = !UIApplication.sharedApplication().statusBarHidden
            
            // 底部视图
            self.bottomBgView.alpha = alpha
            self.bottomToolView.alpha = alpha
            
            // 顶部导航栏
            self.navigationBarView.alpha = alpha
        }) { (_) in
            
        }
    }
    
    /**
     双击事件
     */
    func didDoubleTappedPhotoDetailView(scrollView: UIScrollView, touchPoint: CGPoint) -> Void {
        
        if scrollView.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + scrollView.contentOffset.x
            let scaleY = touchPoint.y + scrollView.contentOffset.y
            scrollView.zoomToRect(CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    // MARK: - 各种tap事件
    func didTappedLeftBarButtonItem(item: UIBarButtonItem) -> Void {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func didTappedRightBarButtonItem(item: UIBarButtonItem) -> Void {
        print("didTappedRightBarButtonItem")
    }
    
    func didTappedCommentButton(button: UIButton) -> Void {
        print("didTappedCommentButton")
    }
    
    func didTappedStarButton(button: UIButton) -> Void {
        print("didTappedStarButton")
    }
    
    func didTappedShareButton(button: UIButton) -> Void {
        print("didTappedShareButton")
    }
    
    func didTappedFontButton(button: UIButton) -> Void {
        print("didTappedFontButton")
    }
    
    // MARK: - 懒加载
    /// 底部文字透明背景视图
    lazy var bottomBgView: UIView = {
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = self.bgColor
        return bottomBgView
    }()
    
    /// 文字描述
    lazy var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        captionLabel.numberOfLines = 0
        captionLabel.font = UIFont.systemFontOfSize(15)
        return captionLabel
    }()
    
    /// 底部工具条
    lazy var bottomToolView: UIView = {
        let bottomToolView = UIView()
        bottomToolView.backgroundColor = self.bgColor
        return bottomToolView
    }()
    
    /// 评论
    lazy var commentButton: UIButton = {
        let commentButton = UIButton(type: UIButtonType.Custom)
        commentButton.setBackgroundImage(UIImage(named: "toolbar_light_comment"), forState: UIControlState.Normal)
        commentButton.addTarget(self, action: #selector(didTappedCommentButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return commentButton
    }()
    
    /// 收藏
    lazy var starButton: UIButton = {
        let starButton = UIButton(type: UIButtonType.Custom)
        starButton.setBackgroundImage(UIImage(named: "article_item_favor"), forState: UIControlState.Normal)
        starButton.addTarget(self, action: #selector(didTappedStarButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return starButton
    }()
    
    /// 分享
    lazy var shareButton: UIButton = {
        let shareButton = UIButton(type: UIButtonType.Custom)
        shareButton.setBackgroundImage(UIImage(named: "article_item_share"), forState: UIControlState.Normal)
        shareButton.addTarget(self, action: #selector(didTappedShareButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return shareButton
    }()
    
    /// 字体
    lazy var fontButton: UIButton = {
        let fontButton = UIButton(type: UIButtonType.Custom)
        fontButton.setBackgroundImage(UIImage(named: "bottom_bar_font_normal"), forState: UIControlState.Normal)
        fontButton.addTarget(self, action: #selector(didTappedFontButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        return fontButton
    }()
    
}
