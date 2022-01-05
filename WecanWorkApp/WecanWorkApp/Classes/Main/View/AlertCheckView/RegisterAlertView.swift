//
//  RegisterAlertView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/8/17.
//

import UIKit
import SCLAlertView
import RxAlamofire
import RxSwift
import Alamofire
import swiftScan
import Toast_Swift
class RegisterAlertView:MXibView {
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var gys: SearchTextField!
    var controller:LoginViewController!
    @IBAction func scan(_ sender: UIButton) {
        recoCropRect()
    }
    var vm : MainViewModel?
    let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromeNib()
        createDateView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDateView(){
        let gys : [String] = ["adasd","0980809","9s9s9s9s99s"]
        self.gys.customDelegate = self
//        self.gys.dataList = getGys(wl: gys)
        phoneNum.delegate = self
        name.delegate = self
//        gys.delegate = self
        vm = MainViewModel(self)
    }
}
//MARK:- Search Textfield delegates
extension RegisterAlertView: SearchTextFieldDelegate ,UITextFieldDelegate {
    
    // MARK: - ---框内区域识别
    func recoCropRect() {
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On
        style.photoframeLineW = 6
        style.photoframeAngleW = 24
        style.photoframeAngleH = 24
        style.isNeedShowRetangle = true
        
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid
        
        //矩形框离左边缘及右边缘的距离
        style.xScanRetangleOffset = 80
        
        //使用的支付宝里面网格图片
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        
        let vc = LBXScanViewController()
        vc.scanStyle = style
        
        vc.isOpenInterestRect = true
        vc.scanResultDelegate = self
        
        //TODO:待设置框内识别
        controller.navigationController?.pushViewController(vc, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.endEditing(true)
        return true
    }
    
    func didSelect(_ textField: SearchTextField, _ item: ListItem) {
        gys.text = item.name
    }

    
    func getGysData(wl:[GysEntity]) -> [ListItem] {
        var locations : [ListItem] = []
        for item in wl {
            let v = ListItem(id: UUID().uuidString, name: item.dname!)
            locations.append(v)
        }
        return locations
    }
    
    func getGysId(wl:[GysEntity],gys:String) -> Int {
        for item in wl {
            if gys == item.dname {
                return item.id!
            }
        }
        return -1
    }
    
    func showAlertView(assets:[String]) {
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            //            kWindowHeight: 800,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:170))
        alert.customSubview = self
        
        //添加确定按钮
        //        alert.addButton("确定",backgroundColor: UIColor(r:245, g: 245, b: 245),textColor: UIColor(r: 51, g: 105,b: 213)) {
        alert.addButton("确定") {
            print(alertView.gys.text!)
        }
        alert.showInfo("请扫描二维码", subTitle: "请向所在区域供应商索取二维码", closeButtonTitle: "取消",animationStyle: .bottomToTop)
        
    }
    
    func showAlertView(assets:[GysEntity],area:String,czman:String) {
        var alertViewResponder : SCLAlertViewResponder? = nil
        self.gys.dataList = getGysData(wl: assets)

        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            //            kWindowHeight: 800,
            
            showCircularIcon: false,
            shouldAutoDismiss: false,
            disableTapGesture: true
            
        )
        let alert = SCLAlertView(appearance: appearance)
        
        let alertView = RegisterAlertView(frame: CGRect(x:0, y:50, width:280, height:50))
        alert.customSubview = self
        
        //添加确定按钮
        //        alert.addButton("确定",backgroundColor: UIColor(r:245, g: 245, b: 245),textColor: UIColor(r: 51, g: 105,b: 213)) {
        alert.addButton("确定") {
            if self.gys.text == ""{
//                SwiftNotice.showText("请选择供应商")
                self.makeToast("请选择供应商", position: .center)

                return
            }
            if self.name.text == ""{
//                SwiftNotice.showText("请填写用户名")
                self.makeToast("请填写用户名", position: .center)
                return
            }
            if self.phoneNum.text?.count != 11{
//                SwiftNotice.showText("请填写正确的手机号")
                self.makeToast("请填写正确的手机号", position: .center)
                return
            }
            print(self.gys.text!)
//            SwiftNotice.wait()
            self.makeToastActivity(.center)

            let meimeiDic:[String: Any] = ["name":self.name.text!,"phone":self.phoneNum.text!,"area":area,"czman":czman,"logExtraData":"APP,"+area,"id":self.getGysId(wl: assets, gys: self.gys.text!)]
            print(meimeiDic)
            RxAlamofire.requestJSON(.post, URL_GYS,parameters:meimeiDic,encoding:JSONEncoding.default).subscribe(onNext: {
                dataResponse in
                if let dictionary = dataResponse.1 as? [String: Any] {
                    if let resultmessage = dictionary["resultmessage"] as? String {
                        print("guid----\(resultmessage)")
//                        SwiftNotice.clear()
                        self.hideToastActivity()
//                        SwiftNotice.showText(resultmessage)
                        self.makeToast(resultmessage, position: .center)

                    }
                    if let resultstatus = dictionary["resultstatus"] as? Int {
                        if resultstatus == 0 {
                            if let resultdic = dictionary["resultdic"] as? [String: Any] {
                                let loginname = resultdic["loginname"] as! String
                                let password = resultdic["password"] as! String
                                SCLAlertView().showInfo("温馨提示", subTitle: "登录名:"+loginname+"  "+"密码:"+password,closeButtonTitle: "确定")
                                alertViewResponder!.close()
                            }
                        }
                    }

                   
                }
            },onError: { (error) in
//                SwiftNotice.clear()
                self.hideToastActivity()
//                SwiftNotice.showText(error)
                print("请求失败！错误原因：", error)
            }, onCompleted: {
            }).disposed(by: self.disposeBag)
        }
        alertViewResponder = alert.showInfo("请扫描二维码", subTitle: "请向所在区域供应商索取二维码", closeButtonTitle: "取消",animationStyle: .bottomToTop)
        
        
    }
}
extension RegisterAlertView:LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
        NSLog("scanResult:\(scanResult.strScanned)")
        let arrayStrings: [String] = scanResult.strScanned!.split(separator: "_").compactMap { "\($0)" }
        let area = arrayStrings[arrayStrings.count-1]
        let czman = arrayStrings[0]
        vm!.getGys(area:area) { (gysEntitys:[GysEntity]) in
            if gysEntitys.count != 0{
                let av : RegisterAlertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:150))
                av.showAlertView(assets: gysEntitys,area: area,czman: czman)
            }else{
//                SwiftNotice.showText("无交接地数据")
                self.makeToast("无交接地数据", position: .center)

            }
        }
    }
}
