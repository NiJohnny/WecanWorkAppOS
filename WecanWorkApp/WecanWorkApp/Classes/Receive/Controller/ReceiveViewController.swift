//
//  ReceiveViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/25.
//

import UIKit
let kTitleViewH : CGFloat = 40

class ReceiveViewController: UIViewController{
    var timeString :String?
    var searchItem : UIBarButtonItem? = nil
    let queryController = ReceiveQueryViewController()
    let operateController = ReceiveOperateViewController()
    // MARK:- 懒加载属性
    fileprivate lazy var pageTitleView : PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH, width: kScreenW, height: kTitleViewH)
        let titles = ["操作", "查询"]
        let titleView = PageTitleView(frame: titleFrame, titles: titles)
        
        titleView.delegate = self
        return titleView
    }()
    
    fileprivate lazy var pageContentView : PageContentView = {[weak self] in
        // 1.确定内容的frame
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH
        let contentFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH + kTitleViewH, width: kScreenW, height: contentH)
        
        // 2.确定所有的子控制器
        var childVcs = [UIViewController]()
        childVcs.append(ReceiveOperateViewController())
        queryController.delegate = self
        childVcs.append(queryController)
        let contentView = PageContentView(frame: contentFrame, childVcs: childVcs, parentViewController: self)
        contentView.delegate = self
        return contentView
    }()
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        title  = timeString
        // 设置UI界面
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    //视图将要出现的时候执行
//    override func viewWillAppear(_ animated: Bool) {
//        operateController.setBtn()
//    }
    
}


extension ReceiveViewController: ReceiveSearchViewDelegate {
    func showView(_ entity: ReceiveEntity?) {
        
        let ov : ReceiveOperateViewController = pageContentView.getCurrentController(0) as! ReceiveOperateViewController
        ov.setOperateView(entity: entity!)
        //        ov.mawb.text=entity?.mawb
        //        ov.finishman.text=entity?.nodeman
        //        ov.finishdate.setTitle(entity?.hbrq, for: .normal)
        pageContentView.setCurrentIndex(0)
        pageTitleView.setTitleWithProgress(1, sourceIndex: 1, targetIndex: 0)
        navigationItem.rightBarButtonItem = nil
        //        let predicate = NSPredicate(format: "mawb = '\((entity?.mawb)!)'")
        //        let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: predicate) as! [Marker]
        //        print(items)
        //        if items.count>0 {
        //            ov.setPhotoBtn(canPhoto: true)
        //        }else{
        //            ov.setPhotoBtn(canPhoto: false)
        //        }
    }
    
    
}

// MARK:- 设置UI界面
extension ReceiveViewController {
    fileprivate func setupUI() {
//        setBackGround(layerView: self.view)
        // 0.不需要调整UIScrollView的内边距
        automaticallyAdjustsScrollViewInsets = false
        // 1.设置导航栏
        setupNavigationBar()
        
        // 2.添加TitleView
        view.addSubview(pageTitleView)
        pageTitleView.backgroundColor=UIColor.clear
        // 3.添加ContentView
        view.addSubview(pageContentView)
    }
    
    fileprivate func setupNavigationBar() {
        // 1.设置左侧的Item
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "logo")
        
        // 2.设置右侧的Item
        searchItem = UIBarButtonItem(imageName: "搜索", highImageName: "搜索", size: CGSize(width: 40, height: 40),target: self,action: #selector(showSearchView))
        //                navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func showSearchView(){
        queryController.searchView.changSearchView()
    }
}


// MARK:- 遵守PageTitleViewDelegate协议
extension ReceiveViewController : PageTitleViewDelegate {
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index: Int) {
        pageContentView.setCurrentIndex(index)
        print("inde----\(index)")
        if index == 0{
            navigationItem.rightBarButtonItem = nil
        }
        else {
            navigationItem.rightBarButtonItem = searchItem
        }
        self.view.endEditing(true)
    }
    
}

// MARK:- 遵守PageContentViewDelegate协议
extension ReceiveViewController : PageContentViewDelegate {
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
        //        print("sourceIndex:\(sourceIndex)  targetIndex:\(targetIndex)")
        if targetIndex == 1 && sourceIndex == 1{
            navigationItem.rightBarButtonItem = searchItem
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
        self.view.endEditing(true)
    }
    
}

extension ReceiveViewController{
    
    func setBackGround(layerView:UIView)  {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.2, green: 0.41, blue: 0.84, alpha: 1).cgColor, UIColor(red: 0.29, green: 0.64, blue: 0.91, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.frame = layerView.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layerView.layer.addSublayer(gradient)
    }
}
