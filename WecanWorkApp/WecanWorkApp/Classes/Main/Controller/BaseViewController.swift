//
//  BaseViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/12.
//


import UIKit

class BaseViewController: UIViewController {
    var baseScrollView: UIScrollView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //注册键盘出现通知
        NotificationCenter.default.addObserver(self, selector: #selector(show(node:)), name:  UIResponder.keyboardWillShowNotification, object: nil)
            
        //注册键盘隐藏通知
        NotificationCenter.default.addObserver(self, selector: #selector(hide(node:)), name:  UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        //注销键盘出现通知
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
        //注销键盘隐藏通知
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
        
        hideKeyBoard()
        
    }
    @objc private func show(node : Notification){
        print("软键盘弹起")
        if baseScrollView != nil {
            print("弹起feinil")
            adjustingHeight(show: true, notification: node)
        }else{
            print("弹起nil")
            
            keyBoardShow()
        }
       
        
    }
        
    @objc private func hide(node : Notification){
        print("软键盘隐藏")
        
        if baseScrollView != nil {
            print("隐藏feinil")
            adjustingHeight(show: false, notification: node)
        }else{
            print("隐藏nil")
            keyBoardHide()
        }
       
        
    }
    
    func keyBoardShow()  {
        
    }
    
     func keyBoardHide()  {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
        hideKeyBoard()
    }
    
    func hideKeyBoard(){
        self.view.endEditing(true)
    }
    
    // 7.自定义自适应高度方法
    func adjustingHeight(show: Bool, notification: Notification) {
        // 7.1获取userInfo
        let userInfo = notification.userInfo!

        // 7.2获取键盘的Frame
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        // 7.3获取显示键盘和消失键盘的高度
        let changeInHeight = (keyboardFrame.height + 5) * (show ? 1 : -1)

        // 7.4设置向下偏移量
        baseScrollView?.contentInset.bottom += changeInHeight

        // 7.5设置向下添加偏移量
        baseScrollView?.scrollIndicatorInsets.bottom += changeInHeight
    }
    //获取父控制器
     func viewController() -> UIViewController? {
            var responder = self.next;
            
            repeat {
                if (responder?.isKind(of: UIViewController.classForCoder()))! {
                    
                    return responder as? UIViewController
                }
                responder = responder?.next
            }
                while((responder) != nil)
            return nil;
        }
    
    //在uiview中获取控制器用作push
//    func nextResponsder(currentView:UIView)->UIViewController{
//           var vc:UIResponder = currentView
//           while vc.isKind(of: UIViewController.self) != true {
//               vc = vc.next!
//           }
//           return vc as! UIViewController
//    }
}
