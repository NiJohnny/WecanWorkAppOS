//
//  ResetViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/21.
//

import UIKit
import RxAlamofire
import RxSwift
import Realm
import RealmSwift
import Alamofire
class ResetViewController: UIViewController {
    var timeiStap: String?
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var okBt: UIButton!
    @IBOutlet weak var yzmBt: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var yzm: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var nextPassWord: UITextField!
    @IBOutlet var textFiles: [UITextField]!
    private var oldColor: UIColor!
    private var timer: Timer!
    private var count: Int = 60
    private var enable: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.oldColor = yzmBt.backgroundColor
        yzmBtEnable(state: false)
        self.passWord.keyboardType = UIKeyboardType.asciiCapable
        self.nextPassWord.keyboardType = UIKeyboardType.asciiCapable
        for v in textFiles {
            v.delegate = self
        }
        
    }
    
    @IBAction func editChange(_ sender: UITextField) {
        print(sender.text)
        if sender.text != "" && !yzmBt.isEnabled && enable {
            yzmBtEnable(state: true)
        }
        if sender.text == "" && yzmBt.isEnabled {
            yzmBtEnable(state: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func yzmBtEnable(state: Bool) {
        self.yzmBt.isEnabled = state
        self.yzmBt.backgroundColor = state ? oldColor : UIColor.gray
    }
    @available(iOS 13.0, *)
    @IBAction func onClick(_ sender: UIView) {
        //        self.view.endEditing(true);
        switch(sender.tag) {
        case 1:
            self.enable = false
            yzmBtEnable(state: false)
            let parameters = ["logname": userName.text!]
//            SwiftNotice.wait()
            self.view!.makeToastActivity(.center)
            RxAlamofire.requestJSON(.get, USER_CAP,parameters:parameters)
                .map{$1}
                .mapObject(type: ResultEntity.self)
                .debug()
                .subscribe(onNext: { (resultEntity: ResultEntity) in
                    print(resultEntity.toJSONString())
                    if resultEntity.resultstatus == 0 {
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ResetViewController.tickDown), userInfo: nil, repeats: true)
                    }
                    
                    
                },onError: { error in
                    self.enable = true
                    self.yzmBtEnable(state: true)
//                    SwiftNotice.clear()
                    self.view.hideToastActivity()
                },onCompleted: {
//                    SwiftNotice.clear()
                    self.view.hideToastActivity()
                }).disposed(by: disposeBag)
            
        default:
            putData()
        }
    }
//    @available(iOS 13.0, *)
    fileprivate func putData() {
        if self.userName.text == "" {
//            Toast.show("请输入用户名")
            self.view.makeToast("请输入用户名")
            return
        }
        if self.yzm.text == "" {
//            Toast.show("请输入验证码")
            self.view.makeToast("请输入验证码")
            return
        }
        if self.passWord.text == "" {
//            Toast.show("请输入新密码")
            self.view.makeToast("请输入新密码")
            return
        }
        if !self.passWord.text!.isFormat("[A-Za-z]{1}[A-Za-z0-9]{7,14}") {
//            Toast.show("密码格式不符合请重新输入")
            self.view.makeToast("密码格式不符合请重新输入")
            return
        }
        if self.nextPassWord.text != self.passWord.text {
//            Toast.show("两次密码不相等")
            self.view.makeToast("两次密码不相等")
            return
        }
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        let parameters = ["logExtraData": "上海，App", "logname": userName.text!, "pwd": passWord.text!, "smscode": yzm.text!]
        RxAlamofire.requestJSON(.put, USER_RESETPW,parameters:parameters,encoding: JSONEncoding.default)
            .map{$1}
            .mapObject(type: ResultEntity.self)
            .debug()
            .subscribe(onNext: { (resultEntity: ResultEntity) in
                print(resultEntity.toJSONString())
                //                self.stopLoading()
                if self.timer != nil {
                    self.timer.invalidate()
                }
//                Toast.show(resultEntity.resultmessage!)
                self.view.makeToast(resultEntity.resultmessage!)
                if resultEntity.resultstatus == 0 {
                    self.navigationController?.popViewController(animated: true)
                }
            },onError: { (error) in
                //                self.stopLoading()
            },onCompleted: {
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                self.pleaseWait()
            }).disposed(by: disposeBag)
        
    }
    @objc func tickDown()
    {
        count -= 1
        yzmBt.titleLabel?.text = "\(count)s"
        yzmBt.setTitle("\(count)s", for: UIControl.State.normal)
        if count == 0 {
            count = 60
            timer.invalidate()
            enable = true
            yzmBt.titleLabel?.text = "获取验证码"
            yzmBt.setTitle("获取验证码", for: UIControl.State.normal)
            if userName.text != "" {
                yzmBtEnable(state: true)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

extension ResetViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag != 3 {
            self.textFiles[textField.tag + 1].becomeFirstResponder()
        } else {
            if #available(iOS 13.0, *) {
                putData()
            } else {
                // Fallback on earlier versions
            }
            textField.endEditing(true)
        }
        return true
    }
    
}


//class ResetViewController: UILoadingController {
//
//    @IBOutlet weak var okBt: UIButton!
//    @IBOutlet weak var yzmBt: UIButton!
//    @IBOutlet weak var userName: UITextField!
//    @IBOutlet weak var yzm: UITextField!
//    @IBOutlet weak var passWord: UITextField!
//    @IBOutlet weak var nextPassWord: UITextField!
//    @IBOutlet var textFiles: [UITextField]!
//    private var oldColor: UIColor!
//    private var timer: Timer!
//    private var count: Int = 60
//    private var enable: Bool = true
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.oldColor = yzmBt.backgroundColor
//        yzmBtEnable(state: false)
//        self.passWord.keyboardType = UIKeyboardType.asciiCapable
//        for v in textFiles {
//            v.delegate = self
//        }
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    @IBAction func editChange(_ sender: UITextField) {
//        if sender.text != "" && !yzmBt.isEnabled && enable {
//            yzmBtEnable(state: true)
//        }
//        if sender.text == "" && yzmBt.isEnabled {
//            yzmBtEnable(state: false)
//        }
//    }
//    private func yzmBtEnable(state: Bool) {
//        self.yzmBt.isEnabled = state
//        self.yzmBt.backgroundColor = state ? oldColor : UIColor.gray
//    }
//    @IBAction func onClick(_ sender: UIView) {
////        self.view.endEditing(true);
//        switch(sender.tag) {
//        case 1:
//            self.enable = false
//            yzmBtEnable(state: false)
//            let parameters = ["logname": userName.text!]
//            HttpTool.instance.get(MessageInfo.self, URL_YZM, parameters, success: { entity in
//                Toast.show(entity.resultmessage!)
//                if entity.resultstatus == 0 {
//                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ResetPswdController.tickDown), userInfo: nil, repeats: true)
//                }
//            }) { error in
//                self.enable = true
//                self.yzmBtEnable(state: true)
//            }
//        default:
//            putData()
//        }
//    }
//    fileprivate func putData() {
//        if self.userName.text == "" {
//            Toast.show("请输入用户名")
//            return
//        }
//        if self.yzm.text == "" {
//            Toast.show("请输入验证码")
//            return
//        }
//        if self.passWord.text == "" {
//            Toast.show("请输入新密码")
//            return
//        }
//        if !self.passWord.text!.isFormat("[A-Za-z]{1}[A-Za-z0-9]{7,14}") {
//            Toast.show("密码格式不符合请重新输入")
//            return
//        }
//        if self.nextPassWord.text != self.passWord.text {
//            Toast.show("两次密码不相等")
//            return
//        }
//
//        self.startLoading()
//        let parameters = ["logname": self.userName.text!, "upwd": self.passWord.text!, "ready10": self.yzm.text!]
//        HttpTool.instance.put(MessageInfo.self, URL_LOGIN, parameters, success: { entity in
//            self.stopLoading()
//            if self.timer != nil {
//                self.timer.invalidate()
//            }
//            Toast.show(entity.resultmessage!)
//            if entity.resultstatus == 0 {
//                self.navigationController?.popViewController(animated: true)
//            }
//
//        }, failure: { error in
//                self.stopLoading()
//            })
//    }
//    @objc func tickDown()
//    {
//        count -= 1
//        yzmBt.titleLabel?.text = "\(count)s"
//        yzmBt.setTitle("\(count)s", for: UIControl.State.normal)
//        if count == 0 {
//            count = 60
//            timer.invalidate()
//            enable = true
//            yzmBt.titleLabel?.text = "获取验证码"
//            yzmBt.setTitle("获取验证码", for: UIControl.State.normal)
//            if userName.text != "" {
//                yzmBtEnable(state: true)
//            }
//        }
//    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        self.view.endEditing(true)
//        super.touchesBegan(touches, with: event)
//    }
//
//}
//extension ResetPswdController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField.tag != 3 {
//            self.textFiles[textField.tag + 1].becomeFirstResponder()
//        } else {
//            putData()
//            textField.endEditing(true)
//        }
//        return true
//    }
//
//}
