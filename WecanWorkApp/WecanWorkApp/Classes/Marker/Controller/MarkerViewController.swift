//
//  MarkerViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/26.
//

import Foundation
//
//  ReceiveViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/25.
//

import UIKit

class MarkerViewController: UIViewController{
    var timeString :String?
    var searchItem : UIBarButtonItem? = nil
    let queryController = MarkerQueryViewController()
    let operateController = MarkerOperateViewController()

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
        childVcs.append(operateController)
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
    //视图显示完成后执行
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        operateController.setPhotoButton()
        
    }
}

extension MarkerViewController: SearchViewDelegate {
    func showView(_ entity: QueryEntity?) {
        let ov : MarkerOperateViewController = pageContentView.getCurrentController(0) as! MarkerOperateViewController
        ov.mawb.text=entity?.mawb
        ov.finishman.text=entity?.nodeman
        ov.finishdate.setTitle(entity?.hbrq, for: .normal)
        pageContentView.setCurrentIndex(0)
        pageTitleView.setTitleWithProgress(1, sourceIndex: 1, targetIndex: 0)
        navigationItem.rightBarButtonItem = nil
        let predicate = NSPredicate(format: "mawb = '\((entity?.mawb)!)'")
        let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: predicate) as! [Marker]
        print(items)
        if items.count>0 {
            ov.setPhotoBtn(canPhoto: true)
        }else{
            ov.setPhotoBtn(canPhoto: false)
        }
        
    }
    
    
}

// MARK:- 设置UI界面
extension MarkerViewController {
    fileprivate func setupUI() {
        
        if nowUser?.workspace == MARKER {
            setMarkbg(layerView: self.view)
        }else{
            setCustombg(layerView: self.view)
        }
        
        // 0.不需要调整UIScrollView的内边距
        automaticallyAdjustsScrollViewInsets = false
        // 1.设置导航栏
        setupNavigationBar()
        
        // 2.添加TitleView
        view.addSubview(pageTitleView)
        pageTitleView.backgroundColor=UIColor.clear
        // 3.添加ContentView
        view.addSubview(pageContentView)
        print(nowUser?.workspace)
        
        if nowUser?.workspace == MARKER{
            self.view.backgroundColor = .green
        }else if nowUser?.workspace == CUSTOM{
            self.view.backgroundColor = .purple
        }
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
extension MarkerViewController : PageTitleViewDelegate {
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index: Int) {
        pageContentView.setCurrentIndex(index)
        print("inde----\(index)")
        if index == 0{
            print("aa")
            navigationItem.rightBarButtonItem = nil
        }
        else {
            navigationItem.rightBarButtonItem = searchItem
            print("bb")
        }
        self.view.endEditing(true)
    }
}

// MARK:- 遵守PageContentViewDelegate协议
extension MarkerViewController : PageContentViewDelegate {
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
        //        print("sourceIndex:\(sourceIndex)  targetIndex:\(targetIndex)")
        if targetIndex == 1 && sourceIndex == 1{
            navigationItem.rightBarButtonItem = searchItem
            print("cc")
        }
        else {
            navigationItem.rightBarButtonItem = nil
            print("dd")
        }
        self.view.endEditing(true)
    }
}

extension MarkerViewController{
    
    func setCustombg(layerView:UIView)  {

        layerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.69, green: 0.38, blue: 1, alpha: 1).cgColor, UIColor(red: 0.8, green: 0.56, blue: 1, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.frame = layerView.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layerView.layer.addSublayer(gradient)
    }
    
    func setMarkbg(layerView:UIView)  {
        // layerFillCode
        layerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.15, green: 0.78, blue: 0.7, alpha: 1).cgColor, UIColor(red: 0.28, green: 0.88, blue: 0.8, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        gradient.frame = layerView.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layerView.layer.addSublayer(gradient)
        
    }
}
