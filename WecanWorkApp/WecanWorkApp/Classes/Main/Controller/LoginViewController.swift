//
//  LoginViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/18.
//

import UIKit
import SCLAlertView
import Alamofire
import RxAlamofire
import RxSwift
import ObjectMapper
import Realm
import RealmSwift
import ProgressHUD
import swiftScan
import SwiftOCR
import IDCardCamera
class LoginViewController: BaseViewController,UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    let swiftOCRInstance = SwiftOCR()
    let disposeBag = DisposeBag()
    var refrashWtdw = 0
    var oldTimestamp = 0
    @IBAction func resetPassWord(_ sender: Any) {
        self.performSegue(withIdentifier: "resetVc", sender: "yyyyyeah")
        
    }
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "scanGys", sender: "yyyyyeah")
//        let B = ScanGysViewController()
//        self.present(B, animated: true, completion: nil)
    }
    
    @IBAction func qrbtn(_ sender: UIButton) {
        recoCropRect()
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
        
        //TODO:待设置框内识别
        self.navigationController?.pushViewController(vc, animated: false)
    }
    @IBOutlet weak var uName: SearchTextField!
    @IBOutlet weak var uPassWord: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    var mainViewModel : MainViewModel?

//    @available(iOS 13.0, *)
    @IBAction func login(_ sender: UIButton) {
        if uPassWord.text == "" {
//            SwiftNotice.showText("密码不能为空")
            self.view.makeToast("密码不能为空", position: .center)
            return
        }
        if uName.text == "" {
//            SwiftNotice.showText("用户名不能为空")
            self.view.makeToast("用户名不能为空", position: .center)
            return
        }
        mainViewModel!.login(uName.text ?? "", uPassWord.text ?? "") { [self] (loginData:LoginData) in
            if loginData.resultstatus == 0 {
                let user = RealmTools.object(UserEntity.self, primaryKey: loginData.logname!)
                nowUser = UserEntity()
                if user != nil{
                    //                    RealmTools.updateWithTranstion { (true) in
                    //                        (user as! UserEntity).shd = ""
                    //                    }
                    nowUser?.equals(user: user as! UserEntity)
                }
                nowUser?.ticket = loginData.ticket
                nowUser?.gid = loginData.gid
                nowUser?.username = loginData.logname
                nowUser?.fwsgys = loginData.fwsgys
                nowUser?.gysid = loginData.gysid!
                nowUser?.gyscardno = loginData.gyscardno
                nowUser?.gysphone = loginData.gysphone
                nowUser?.gysarea = loginData.gysarea
                nowUser?.password = uPassWord.text
                
                let items = RealmTools.objects(AutEntity.self)
                RealmTools.deleteList(items!) {
                    print("deleteList")
                }
                
                mainViewModel!.getUserAut((nowUser?.username)!) { (autEntitys :[AutEntity]) in
                    if (autEntitys.count==0){
//                        Toast.show("无权限无法登录")
                        self.view.makeToast("无权限无法登录")
                        return
                    }
                    nowUser?.UserAut=getAut(autEntitys: autEntitys)?.joined(separator: ",")
                    RealmTools.addList(autEntitys) {
                    }
                    AREA = getSelectStringArray(autEntitys: aa(datas: autEntitys)!)!
                    if AREA.count == 1{
                        nowUser?.area=AREA[0]
                        let user = RealmTools.object(UserEntity.self, primaryKey: (nowUser?.username)!)
                        if user == nil{
                            RealmTools.add(nowUser!) {
                            }
                        }
                        self.performSegue(withIdentifier: "mainVc", sender: loginData.fwsgys)
                    }else{
                        showAlertView(assets:AREA,fwsgys:loginData.fwsgys!)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftOCRInstance.recognize(UIImage(named: "login_bg")!) { (data) in
            print(data)
        }
        mainViewModel = MainViewModel(self.view)
        uPassWord.delegate = self
        uName.customDelegate = self
        uName.dataList = getUnameStringArray(userEntitys: getUser()!)!
        getWarehouseEntities()
        getTerminalEntitities()
        getAllWtdwEntities()
        getTypecodeEntities()
        //设置视图的背景图片（自动拉伸）
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
        //        self.navigationController?.navigationBar.isTranslucent = true
        //        self.view.layer.contents = UIImage(named:"login_bg.png")!.cgImage
        UIView.animate(withDuration: 0.5,
                       delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {() -> Void in
                        self.loginView.frame = CGRect(x: 0, y: 0, width: kScreenW, height:450 )
                        //                                    self.loginView.backgroundColor=UIColor.blue
                       }){(finished) -> Void in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        REGISTER_NAME = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if REGISTER_NAME != "" {
            uName.text = REGISTER_NAME
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.layer.contents = UIImage(named:"login_bg.png")!.cgImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "mainVc":
            let zc = segue.destination as! MainViewController
            zc.timeiStap = sender as? String
            break
            
        case "resetVc":
            let zc = segue.destination as! ResetViewController
            zc.timeiStap = sender as? String
            break
            
        case "registerVc":
            let zc = segue.destination as! RegisterViewController
            zc.callback = {(uName) in
                self.uName.text = uName
                
            }
            break
        default:
            break
        }
    }
}

extension LoginViewController{
    func max(data1 : Int,data2 : Int) -> Int {
        if data1>data2 {
            return data1
        }
        else {
            return data2
        }
    }
    
    func aa(datas: [AutEntity]) -> [AutEntity]? {
        let predicate = NSPredicate(format: "type = 5 AND autname != '主体'")
        let items = RealmTools.objectsWithPredicate(object: AutEntity.self, predicate: predicate) as! [AutEntity]
        return items
    }
    
    func getUser() -> [UserEntity]? {
        let items = RealmTools.objects(UserEntity.self) as! [UserEntity]
        return items
    }
    
    func getUnameStringArray(userEntitys: [UserEntity]) -> [ListItem]? {
        var items : [ListItem] = []
        for userEntity in userEntitys{
            let item = ListItem(id: UUID().uuidString, name: userEntity.username!)
            items.append(item)
        }
        return items
    }
    
    func getSelectStringArray(autEntitys: [AutEntity]) -> [String]? {
        var assets:[String] = []
        for autEntity in autEntitys{
            if !assets.contains(autEntity.autname!) {
                assets.append(autEntity.autname!)
            }
            
        }
        return assets
    }
    func getAut(autEntitys: [AutEntity]) -> [String]? {
        var assets:[String] = []
        for autEntity in autEntitys{
            assets.append(autEntity.auturl!)
        }
        return assets
    }
    
    
    func showAlertView(assets:[String],fwsgys:String) {
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            //            kWindowHeight: 800,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:170), datas: assets, isMultiple: false, defaultSelect: assets[0])
        alert.customSubview = alertCheckView
        
        //添加确定按钮
        //        alert.addButton("确定",backgroundColor: UIColor(r:245, g: 245, b: 245),textColor: UIColor(r: 51, g: 105,b: 213)) {
        alert.addButton("确定") {
            nowUser?.area=alertCheckView.getSelectData()
            let user = RealmTools.object(UserEntity.self, primaryKey: (nowUser?.username)!)
            if user == nil{
                RealmTools.add(nowUser!) {
                    
                }
            }
            self.performSegue(withIdentifier: "mainVc", sender: fwsgys)
            
        }
        alert.showInfo("请选择收货地", subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
        
    }
    
    
    func getAllWtdwEntities() {
        let versionWtdw = getUserdefaults(forKey: "wtdw", nilValue: 0)
        oldTimestamp = getUserdefaults(forKey: "timestamp", nilValue: 0)
        if (versionWtdw < refrashWtdw){
            oldTimestamp = 0
        }
        RxAlamofire.requestJSON(.get, URL(string:WTDW)!,parameters:["type":"inputKhjcno","comxz":1,"area":"","system":"","timestamp":oldTimestamp])
            .map{$1}
            .mapArray(type: AllWtdwEntity.self)
            .subscribe(onNext: { [self] (allWtdwEntitys: [AllWtdwEntity]) in
                if allWtdwEntitys.count>0{
                    var timestamp = oldTimestamp
                    let items = RealmTools.objects(WtdwEntity.self)
                    if (oldTimestamp == 0 && items!.count > 0){
                        RealmTools.deleteList(items!) {
                            print("deleteList")
                        }
                    }
                    
                    
                    DispatchQueue.global().async{
                        var wtdwEntitys : [WtdwEntity]? = []
                        for item in allWtdwEntitys {
                            timestamp = max(data1: timestamp, data2: item.timestamp!)
                            wtdwEntitys?.append(item.getWtdwEntity())
                        }
                    DispatchQueue.main.async{

                    print(Thread.current)
                        RealmTools.addList(wtdwEntitys!) {
                        }
                    }

                    }
                    
                   
                    setUserdefaults(str: timestamp, forKey: "timestamp")
                    setUserdefaults(str: refrashWtdw, forKey: "wtdw")
                }
            }).disposed(by: disposeBag)
    }
    
    func getTypecodeEntities() {
        RxAlamofire.requestJSON(.get, PUBTYPECODE,parameters:["groupid":"31,32,53,90,95,96,37"])
            .map{$1}
            .mapArray(type: TypecodeEntity.self)
            .subscribe(onNext: { (typecodeEntitys: [TypecodeEntity]) in
                if typecodeEntitys.count != 0{
                    RealmTools.addList(typecodeEntitys, update: Realm.UpdatePolicy.all) {}
                }
            }).disposed(by: disposeBag)
        
    }
    
    func getTerminalEntitities() {
        RxAlamofire.requestJSON(.get, URL_TERMINAL + "?area=")
            .map{$1}
            .mapArray(type: TerminalEntity.self)
            .subscribe(onNext: { (terminalEntitys: [TerminalEntity]) in
                print(terminalEntitys.toJSONString())
                let items = RealmTools.objects(TerminalEntity.self)
                if terminalEntitys.count > 0 {
                    RealmTools.deleteList(items!) {}
                    RealmTools.addList(terminalEntitys) {}
                }else if items?.count == 0{
                    //            Toast.show("无交接地数据")
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    func getWarehouseEntities() {
        RxAlamofire.requestJSON(.get, URL_WAREHOUSE+"?warehouse=warehouse")
            .map{$1}
            .mapArray(type: WarehouseEntity.self)
            .subscribe(onNext: { (warehouseEntitys: [WarehouseEntity]) in
                print(warehouseEntitys.toJSONString())
                let items = RealmTools.objects(WarehouseEntity.self)
                if items?.count == 0 && warehouseEntitys.count == 0{
                    //                    Toast.show("无仓库数据")
//                    SwiftNotice.showText("无仓库数据")
                    self.view.makeToast("无仓库数据", position: .center)
                    return
                }
                //                for (index, warehouseEntity) in warehouseEntitys.enumerated() {
                //                    let predicate = NSPredicate(format: "storeid = \(warehouseEntity.storeid) AND area = \(warehouseEntity.area)")
                //                    let itemss = RealmTools.objectsWithPredicate(object: WarehouseEntity.self, predicate: predicate) as! [WarehouseEntity]
                //                    let aaa = itemss[0]
                //                    if itemss.count>0 && aaa != nil {
                //                        aaa.storename = warehouseEntity.storename
                //                        aaa.isjg = warehouseEntity.isjg
                //                    }
                //                    }
                RealmTools.deleteList(items!) {}
                RealmTools.addList(warehouseEntitys) {
                    print("adddddlist")
                }
            }).disposed(by: disposeBag)
        
    }
    
    
}
extension LoginViewController: SearchTextFieldDelegate{
    func didSelect(_ textField: SearchTextField, _ item: ListItem) {
        print("Selected Location:", item.name)
        let users = getUser()!
        for user in users{
            if item.name == user.username {
                uPassWord.text = user.password
                break
            }
        }
    }
}

extension LoginViewController:LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        let arrayStrings: [String] = scanResult.strScanned!.split(separator: "_").compactMap { "\($0)" }
        let area = arrayStrings[arrayStrings.count-1]
        let czman = arrayStrings[0]
        mainViewModel!.getGys(area:area) { (gysEntitys:[GysEntity]) in
            if gysEntitys.count != 0{
                let av : RegisterAlertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:150))
                av.controller = self
                av.showAlertView(assets: gysEntitys,area: area,czman: czman)
            }else{
//                SwiftNotice.showText("无交接地数据")
                self.view.makeToast("无交接地数据", position: .center)

            }
        }
    }
}
