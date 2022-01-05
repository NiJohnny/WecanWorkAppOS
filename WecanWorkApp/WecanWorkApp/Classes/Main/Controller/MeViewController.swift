//
//  MeViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/9/27.
//

import UIKit

class MeViewController: UIViewController {
    let setController = SetController()
    let meInfoController = MeInfoController()
    
    // MARK:- 懒加载属性
    fileprivate lazy var pageTitleView : PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH, width: kScreenW, height: kTitleViewH)
        let titles = ["操作", "个人信息"]
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
        
        childVcs.append(setController)
        childVcs.append(meInfoController)
        let contentView = PageContentView(frame: contentFrame, childVcs: childVcs, parentViewController: self)
        contentView.delegate = self
        return contentView
    }()
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置UI界面
        setupUI()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            switch segue.identifier {
            case "checkVC":
                let zc = segue.destination as! CheckViewController
                zc.datas = sender as? [String]
                break
        
            case "checkMoreVc":
                let zc = segue.destination as! CheckMoreViewController
                zc.datas = sender as? String
                break
        
            default:
                break
            }
    }
    //视图将要出现的时候执行
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
        setController.setView()
    }
}


// MARK:- 设置UI界面
extension MeViewController {
    fileprivate func setupUI() {
//        setBackGround(layerView: self.view)
        // 0.不需要调整UIScrollView的内边距
        automaticallyAdjustsScrollViewInsets = false
//        // 1.设置导航栏
//        setupNavigationBar()
        
        // 2.添加TitleView
        view.addSubview(pageTitleView)
        pageTitleView.backgroundColor=UIColor.clear
        // 3.添加ContentView
        view.addSubview(pageContentView)
    }
}

// MARK:- 遵守PageTitleViewDelegate协议
extension MeViewController : PageTitleViewDelegate {
    func pageTitleView(_ titleView: PageTitleView, selectedIndex index: Int) {
        pageContentView.setCurrentIndex(index)
        print("inde----\(index)")
        if index == 0{
            navigationItem.rightBarButtonItem = nil
        }
        else {
//            navigationItem.rightBarButtonItem = searchItem
        }
        self.view.endEditing(true)
    }
    
}

// MARK:- 遵守PageContentViewDelegate协议
extension MeViewController : PageContentViewDelegate {
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
        //        print("sourceIndex:\(sourceIndex)  targetIndex:\(targetIndex)")
        if targetIndex == 1 && sourceIndex == 1{
//            navigationItem.rightBarButtonItem = searchItem
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
        self.view.endEditing(true)
    }
    
}
