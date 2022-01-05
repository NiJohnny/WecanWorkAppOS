//
//  RegisterViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/8/30.
//

import UIKit
import swiftScan
import RxAlamofire
import RxSwift
import Alamofire
import SCLAlertView
import IDCardCamera
import ObjectMapper
class RegisterViewController: BaseViewController ,CardDetectionViewControllerDelegate{
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        //                self.imageView.image = UIImage(cgImage: image)
        //
        //                swiftOCRInstance.recognize(UIImage(named: "login_bg")!) { (data) in
        //                    print("99999999999999999999")
        //                    print(data)
    }
    
    private func yzmBtEnable(state: Bool) {
        self.yzmBt.isEnabled = state
        self.yzmBt.backgroundColor = state ? oldColor : UIColor.gray
    }
    private var oldColor: UIColor!
    private var timer: Timer!
    private var count: Int = 60
    private var enable: Bool = true
    @IBOutlet weak var zd: UITextField!
    @IBOutlet weak var yzmBt: UIButton!
    @IBOutlet weak var sfzNum: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdAgain: UITextField!
    @IBAction func mk(_ sender: Any) {
        showAlertView(assets: moduleDefault, title: "选择模块",defaultUnableCell: getUnableSelect(module: getModule(wl: gysEntitys, gys: gys.text!)))
        
    }
    
    @IBOutlet weak var btnMk: UIButton!
    @IBOutlet weak var yzm: UITextField!
    @IBAction func takeYzm(_ sender: Any) {
        if yzm.text?.count != 11 {
            SwiftNotice.showText("请输入正确的手机号")
            self.view.makeToast("请输入正确的手机号", position: .center)

            return
        }
        self.enable = false
        yzmBtEnable(state: false)
        let parameters = ["mobile": phone.text!]
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        RxAlamofire.requestJSON(.get, USER_CAP,parameters:parameters)
            .map{$1}
            .mapObject(type: ResultEntity.self)
            .debug()
            .subscribe(onNext: { (resultEntity: ResultEntity) in
                print(resultEntity.toJSONString())
                if resultEntity.resultstatus == 0 {
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RegisterViewController.tickDown), userInfo: nil, repeats: true)
                }
            },onError: { error in
                self.enable = true
                self.yzmBtEnable(state: true)
//                SwiftNotice.clear()
                self.view.hideToastActivity()
            },onCompleted: {
//                SwiftNotice.clear()
                self.view.hideToastActivity()
            }).disposed(by: disposeBag)
        
    }
    var photos : [String] = []
    @IBAction func takeSfz(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sfzVC = storyboard.instantiateViewController(withIdentifier: "showSfz") as! SfzViewController
        sfzVC.callback = { [self](data : [String]) in
            photos = data
        }
        self.navigationController!.pushViewController(sfzVC, animated: true)
        
    }
    @IBOutlet weak var mScrollView: UIScrollView!
    
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var phone: PhoneField!
    @IBOutlet weak var gys: SearchTextField!
    
    @IBOutlet weak var uname: UITextField!
    @IBOutlet weak var hint: UILabel!
    var gysEntitys :[GysEntity] = []
    var czman : String!
    var id = "780"
    var area:String!
    var vm : MainViewModel?
    let disposeBag = DisposeBag()
    var isanim = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if gys.isUserInteractionEnabled == false || uname.isUserInteractionEnabled == false || phone.isUserInteractionEnabled == false{
//            if !isanim {
//                anim(hint)
//            }
//
//        }
        hideKeyBoard()
    }
    
    @IBAction func register(_ sender: UIButton) {
        self.view.endEditing(true)
        print(photos)
        //        if photos.contains("") {
        //            SwiftNotice.showText("请完成正反面拍照")
        //            return
        //        }
        if self.gysEntitys.count == 0{
//            SwiftNotice.showText("请扫描邀请码注册")
            self.view.makeToast("请扫描邀请码注册", position: .center)

            return
        }
        
        if self.gys.text == ""{
//            SwiftNotice.showText("请选择供应商")
            self.view.makeToast("请选择供应商", position: .center)

            return
        }
        
        if self.uname.text == ""{
//            SwiftNotice.showText("请填写用户名")
            self.view.makeToast("请填写用户名", position: .center)

            return
        }
        
        if self.pwd.text == ""||self.pwdAgain.text == ""{
//            SwiftNotice.showText("密码不能为空")
            self.view.makeToast("密码不能为空", position: .center)

            return
        }
        
        if self.pwd.text != self.pwdAgain.text{
//            SwiftNotice.showText("两次密码不一致")
            self.view.makeToast("两次密码不一致", position: .center)

            return
        }
        
        if self.phone.text?.count != 11{
//            SwiftNotice.showText("请填写正确的手机号")
            self.view.makeToast("请填写正确的手机号", position: .center)

            return
        }
        print(self.gys.text!)
        upload()
    }
    var callback : ((String) -> Void)?
    override func viewDidLoad() {
        //        phone.delegate = self
        super.viewDidLoad()
        vm = MainViewModel(self.view)
        gys.customDelegate = self
        gys.dataList = getGysData(wl: gysEntitys)
        print(gysEntitys.toJSONString())
        
        self.zd.text = area
        
        self.oldColor = yzmBt.backgroundColor
        yzmBtEnable(state: true)
        let searchItem = UIBarButtonItem(imageName: "public_scan_white", highImageName: "public_scan_white", size: CGSize(width: 40, height: 40),target: self,action: #selector(scan))
        navigationItem.rightBarButtonItem = searchItem
       
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,
                                                                   NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)
        ]
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
    }
    override func keyBoardShow() {
        mScrollView.contentInset.bottom = 300

    }
    
    override func keyBoardHide() {
        mScrollView.contentInset.bottom = 0
       
    }
}

//extension RegisterViewController:UITextFieldDelegate{
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print(textField.text!.count)
//        if textField.text!.count>=10 {
//            yzmBtEnable(state: true)
//            return true
//        }else{
//            yzmBtEnable(state: false)
//            return false
//        }
//
//        }
//}


extension RegisterViewController:SearchTextFieldDelegate{
    func didSelect(_ textField: SearchTextField, _ item: ListItem) {
        print("8a0s8d0ajodjaslkdjlask")
        gys.text = item.name
    }
}

extension RegisterViewController:LBXScanViewControllerDelegate{
    
    func anim(_ currentLabel:UILabel)  {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.toValue = 0.5
        anim.duration = 1
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = true
        
        currentLabel.layer.add(anim, forKey: nil)
        isanim = true
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
    
    func getModule(wl:[GysEntity],gys:String) -> [String] {
        var moduleStr : [String] = []
        
        for item in wl {
            if gys == item.dname {
                let modules = item.module!
                
                for module in modules {
                    moduleStr.append(String(module.mname!.split(separator: "-")[2]))
                }
            }
        }
        return moduleStr
    }
    
    func getUnableSelect(module:[String]) -> [String] {
        var moduleStr : [String] = []
        for item in moduleDefault {
            if !module.contains(item) {
                moduleStr.append(item)
            }
        }
        return moduleStr
    }
    func getMid(gys:String,mk:String) -> String {
        var mid : [String] = []
        for item in gysEntitys {
            if gys == item.dname {
                let modules = item.module!
                for module in modules {
                    let mname = String(module.mname!.split(separator: "-")[2])
                    if mk.contains(mname) {
                        mid.append(String(module.mid!))
                    }
                }
            }
        }
        return mid.joined(separator: ",")
    }

    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        let arrayStrings: [String] = scanResult.strScanned!.split(separator: "_").compactMap { "\($0)" }
        let area = arrayStrings[arrayStrings.count-1]
        let czman = arrayStrings[0]
        vm!.getGys(area:area) { [self] (gysEntitys:[GysEntity]) in
            print(gysEntitys.toJSONString())
            if gysEntitys.count != 0{
//                SwiftNotice.showText("供应商数据获取成功")
                self.view.makeToast("供应商数据获取成功", position: .center)

                self.gysEntitys = gysEntitys
                gys.customDelegate = self
                gys.dataList = getGysData(wl: gysEntitys)
                self.zd.text = area
                self.czman = czman
                self.area = area
                zd.isEnabled = true
                gys.isEnabled = true
                btnMk.isEnabled = true
                uname.isEnabled = true
                sfzNum.isEnabled = true
                pwd.isEnabled = true
                pwdAgain.isEnabled = true
                phone.isEnabled = true
                yzm.isEnabled = true
                zd.alpha = 1
                gys.alpha = 1
                btnMk.alpha = 1
                uname.alpha = 1
                sfzNum.alpha = 1
                pwd.alpha = 1
                pwdAgain.alpha = 1
                phone.alpha = 1
                yzm.alpha = 1
                hint.layer.removeAllAnimations()
                //                self.gys.becomeFirstResponder()
            }else{
//                SwiftNotice.showText("无供应商数据")
                self.view.makeToast("无供应商数据", position: .center)

            }
        }
    }
    
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
        //        vc.view.backgroundColor = UIColor.red
        //        vc.navigationController?.navigationBar.isHidden = true
        //        vc.view.layer.contents = UIImage(named:"login_bg.png")!.cgImage
        //        vc.navigationController?.navigationBar.barTintColor =
        //            UIColor(red: 55/255, green: 186/255, blue: 89/255, alpha: 1)
        //TODO:待设置框内识别
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func scan(){
        recoCropRect()
    }
    
    
    
    @objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
        self.view.endEditing(true)
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
            if phone.text != "" {
                yzmBtEnable(state: true)
            }
        }
    }
    
    func upload()  {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            multipartFormData.append((getMid(gys: gys.text!, mk: btnMk.currentTitle!).data(using: String.Encoding.utf8))!, withName: "mid")
            multipartFormData.append((sfzNum.text!.data(using: String.Encoding.utf8))!, withName: "cardno")
            multipartFormData.append((uname.text!.data(using: String.Encoding.utf8))!, withName: "name")
            multipartFormData.append((phone.text!.data(using: String.Encoding.utf8))!, withName: "phone")
            multipartFormData.append((zd.text!.data(using: String.Encoding.utf8))!, withName: "area")
            multipartFormData.append((czman.data(using: String.Encoding.utf8))!, withName: "czman")
            multipartFormData.append((("APP," + area).data(using: String.Encoding.utf8))!, withName: "logExtraData")
            multipartFormData.append((String(self.getGysId(wl: gysEntitys, gys: self.gys.text!)).data(using: String.Encoding.utf8))!, withName: "id")
            multipartFormData.append((yzm.text!.data(using: String.Encoding.utf8))!, withName: "phonecode")
            multipartFormData.append((pwd.text!.data(using: String.Encoding.utf8))!, withName: "password")
            
            //                        for item in photos{
            //                            let file = URL(fileURLWithPath: item.replacingOccurrences(of: "file://", with: ""))
            //                            multipartFormData.append(file, withName: item)
            //                        }
            let front = URL(fileURLWithPath: photos[0].replacingOccurrences(of: "file://", with: ""))
            multipartFormData.append(front, withName: "front.JPG")
            let back = URL(fileURLWithPath: photos[1].replacingOccurrences(of: "file://", with: ""))
            multipartFormData.append(back, withName: "back.JPG")
        },urlRequest: try! urlRequest(.post,URL_GYS)).subscribe{ uploadRequest in
            
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
                print("当前进度：\(progress.fractionCompleted)")
                print("  已上传载：\(progress.completedUnitCount/1024)KB")
                print("  总大小：\(progress.totalUnitCount/1024)KB")
            })
            uploadRequest.responseString { response in
                let resultEntity:ResultEntity = Mapper<ResultEntity>().map(JSONString: response.value!)!
                print(resultEntity.toJSONString()!)
                if resultEntity.resultstatus == 0{
                    let loginname = resultEntity.resultdic?.loginname
//                    let password = resultEntity.resultdic?.password
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false //不显示关闭按钮
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.addButton("确定") {
                            self.callback?(loginname!)
//                                self.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
//                        alert.showInfo("温馨提示", subTitle: "登录名:"+loginname!+"  "+"密码:"+password!)
                    alert.showInfo("温馨提示", subTitle: "登录名:"+loginname!)
                }
            }
        } onError: { (error) in
            print(error)
//            SwiftNotice.clear()
            self.view.hideToastActivity()
        } onCompleted: {
            print("finish")
            self.view.hideToastActivity()
//            SwiftNotice.clear()
        } onDisposed: {
            print("onDisposed")
        }
    }
    
    
    
    func showAlertView(assets:[String],title:String,defaultUnableCell:[String]) {
        self.view.endEditing(true)
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            kWindowHeight: 600,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:180), datas: assets,isMultiple:true, defaultSelect: btnMk.currentTitle!,defaultUnableCell:defaultUnableCell)
        alert.customSubview = alertCheckView
        
        //添加确定按钮
        alert.addButton("确定") { [self] in
            let selectData = alertCheckView.getSelectData()
            
            if selectData != ""{
                btnMk.setTitle(selectData, for: .normal)
            }
            
        }
        alert.showInfo(title, subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
    }
    
}
