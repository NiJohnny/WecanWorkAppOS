////
////  BaseViewController.swift
////  WecanWorkApp
////
////  Created by erp on 2021/5/25.
////
//
//import UIKit
//class BaseViewController1: UIViewController {
//
//    override func viewDidLoad() {
//            super.viewDidLoad()
//             
//            //修改导航栏标题文字颜色
//            self.navigationController?.navigationBar.titleTextAttributes =
//                [.foregroundColor: UIColor.white]
//            //修改导航栏按钮颜色
//            self.navigationController?.navigationBar.tintColor = UIColor.white
//             
//            //设置视图的背景图片（自动拉伸）
////            self.view.layer.contents = UIImage(named:"bg1.jpg")!.cgImage
////        self.view.layer.contents = UIImage()
//
//        //修改导航栏背景色
//        self.navigationController?.navigationBar.barTintColor = .systemBlue
//        }
//         
//        //视图将要显示
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
////            如果想让导航栏（navigationBar）透明，只需将导航栏背景图片（backgroundImage）设置为一个空的 image 即可。不过这样设置后，导航栏下方还是会有一条灰色色的分隔线。
//            //设置导航栏背景透明
////            如果设置了导航栏的背景图片（backgroundImage），那么 barTintColor 就会自动失效，相应的 visualeffectView 也就不再存在，自然也就不会有模糊渲染效果
////            self.navigationController?.navigationBar.setBackgroundImage(UIImage(),
////                                                                        for: .default)
////            如果要去除这个黑边，同样将导航栏的 shadowImage 设置为一个空的 image 即可。
//            self.navigationController?.navigationBar.shadowImage = UIImage()
//            
//            
//
//        }
//         
//        //视图将要消失
//        override func viewWillDisappear(_ animated: Bool) {
//            super.viewWillDisappear(animated)
//
//            //重置导航栏背景
//            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//            self.navigationController?.navigationBar.shadowImage = nil
//        }
//
//}
