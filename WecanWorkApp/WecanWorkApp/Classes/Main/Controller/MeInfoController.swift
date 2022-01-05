//
//  MeInfoController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/9/28.
//


import UIKit
import RxAlamofire
import RxSwift
import Alamofire
import RealmSwift
import SCLAlertView

//bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
//@objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
//    self.view.endEditing(true)
//}


class MeInfoController: UIViewController {
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var zd: UITextField!
    @IBOutlet weak var gys: UITextField!
    @IBOutlet weak var mk: UIButton!
    @IBOutlet weak var yzmBt: UIButton!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var sfzNum: UIButton!
    @IBOutlet weak var phone: PhoneField!
    @IBOutlet weak var phonecode: UITextField!
    var mainViewModel: MainViewModel?
    let disposeBag = DisposeBag()
    private var timer: Timer!
    private var count: Int = 60
    var modules : [String] = []
    private var oldColor: UIColor!
    @IBAction func modify(_ sender: Any) {
        if phonecode.text == "" {
//            SwiftNotice.showText("请输入验证码")
            self.view.makeToast("请输入验证码", position: .center)

            return
        }
        if phone.text?.count != 11 {
//            SwiftNotice.showText("请输入正确的手机号码")
            self.view.makeToast("请输入正确的手机号码", position: .center)

            return
        }
        modify()
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
    private func yzmBtEnable(state: Bool) {
        self.yzmBt.isEnabled = state
        self.yzmBt.backgroundColor = state ? oldColor : UIColor.gray
    }
    private var enable: Bool = true

//    let vm = MainViewModel()
    var gysEntitys :[GysEntity] = []
    @IBAction func mk(_ sender: Any) {
        showAlertView(assets: moduleDefault, title: "选择模块",defaultUnableCell: getUnableSelect(moduleStr: getModule(wl: gysEntitys, gys: gys.text!).joined(separator: ",")))
    }
   
    @IBAction func yzm(_ sender: Any) {

        if phone.text?.count != 11 {
//            SwiftNotice.showText("请输入正确的手机号")
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
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MeInfoController.tickDown), userInfo: nil, repeats: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldColor = yzmBt.backgroundColor
        yzmBtEnable(state: true)
        mainViewModel = MainViewModel(self.view)
        mainViewModel!.getGys(area:(nowUser?.gysarea!)!) { [self] (gysEntitys:[GysEntity]) in
            print(gysEntitys.toJSONString())
            
            if gysEntitys.count != 0{
                self.gysEntitys = gysEntitys
                
            }else{
//                SwiftNotice.showText("无供应商数据")
                self.view.makeToast("无供应商数据", position: .center)

            }
        }
        
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
        gys.text = nowUser?.fwsgys
        zd.text = nowUser?.gysarea
        name.text = nowUser?.username
        sfzNum.setTitle(nowUser?.gyscardno, for: .normal)
        phone.text = nowUser?.gysphone
        mk.setTitle("", for: .normal)
        
        
        
        let items = RealmTools.objects(AutEntity.self) as! [AutEntity]
        for item in items {
            if !modules.contains(item.module!) {
                modules.append(item.module!)
            }
        }
        mk.setTitle(modules.joined(separator: ","), for: .normal)
    }

    @objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func getGysData(wl:[GysEntity]) -> [ListItem] {
        var locations : [ListItem] = []
        for item in wl {
            let v = ListItem(id: UUID().uuidString, name: item.dname!)
            locations.append(v)
        }
        return locations
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
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:180), datas: assets,isMultiple:true, defaultSelect: mk.currentTitle!,defaultUnableCell:defaultUnableCell)
        alert.customSubview = alertCheckView
        
        //添加确定按钮
        alert.addButton("确定") { [self] in
            let selectData = alertCheckView.getSelectData()
            
            if selectData == ""{
                mk.setTitle("", for: .normal)
            }else{
                mk.setTitle(selectData, for: .normal)
            }
            
        }
        alert.showInfo(title, subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
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
    
    func getUnableSelect(moduleStr:String) -> [String] {
        var moduleStr1 : [String] = []
        for item in moduleDefault {
            if !moduleStr.contains(item) {
                moduleStr1.append(item)
                print("------------")
                print(item)
                print("------------")
            }
        }
        return moduleStr1
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
    func modify() {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        let logExtraData = "APP," + (nowUser?.gysarea)!
        let mid = getMid(gys: gys.text!, mk: mk.currentTitle!)
        print(mid)
        let parameters :[String: Any] = ["gysid": nowUser?.gysid, "mid": mid, "area": nowUser?.gysarea, "phone": phone.text!, "phonecode": phonecode.text!, "logname":nowUser?.username, "czman":nowUser?.username, "logExtraData":logExtraData, "cardno":sfzNum.currentTitle]
        RxAlamofire.requestJSON(.put, URL_MODIFY_GYS,parameters:parameters,encoding: JSONEncoding.default)
            .map{$1}
            .mapObject(type: ResultEntity.self)
            .debug()
            .subscribe(onNext: { [self] (resultEntity: ResultEntity) in
//                SwiftNotice.clear()
                self.view.hideToastActivity()
//                SwiftNotice.showText(resultEntity.resultmessage!)
                self.view.makeToast(resultEntity.resultmessage!, position: .center)

                print(resultEntity.toJSONString())
                if resultEntity.resultstatus == 0 {
                    print("0")
                    RealmTools.updateWithTranstion { (true) in
                        print("100")
                        nowUser?.gysphone = phone.text
                    }
                   
                    print("1")
                    let items = RealmTools.objects(AutEntity.self)
                    print("2")
                    RealmTools.deleteList(items!) {
                        print("deleteList")
                    }
                    
                    print("3")
                    mainViewModel!.getUserAut(name.text!) { (autEntitys :[AutEntity]) in
                        RealmTools.updateWithTranstion { (true) in
                            print("200")
                            nowUser?.UserAut=getAut(autEntitys: autEntitys)?.joined(separator: ",")
                        }
                        print("4")
                        RealmTools.addList(autEntitys) {
                            print("addList")
                        }
                    }
                    
                }
            },onError: { (error) in
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                print("请求失败！错误原因：", error)
            },onCompleted: {
//                SwiftNotice.clear()
            }).disposed(by: disposeBag)
    }
    func getAut(autEntitys: [AutEntity]) -> [String]? {
        var assets:[String] = []
        for autEntity in autEntitys{
            assets.append(autEntity.auturl!)
        }
        return assets
    }
    
}
//Optional("[{\"module\":[],\"id\":190,\"dcode\":\"D00147\",\"dname\":\"非我司广州\",\"area\":\"广州\"},{\"area\":\"广州\",\"dcode\":\"D00148\",\"id\":191,\"module\":[{\"mcode\":\"wccz\",\"mname\":\"上海-唯凯操作APP-外场操作\",\"mid\":777},{\"mname\":\"上海-唯凯操作APP-制单操作\",\"mid\":779,\"mcode\":\"zdcz\"},{\"mcode\":\"shcz\",\"mname\":\"上海-州\",\"dcode\":\"D00148\",\"id\":191,\"module\":[{\"mcode\":\"wccz\",\"mname\":\"上海-唯凯操作APP-外场操作\",\"mid\":777},{\"mname\":\"上海-唯凯操作APP-制单操作\",\"mid\":779,\"mcode\":\"zdcz\"},{\"mcode\":\"shcz\",\"mname\":\"上海-\345\224唯凯操作APP-收货操作\",\"mid\":780}],\"dname\":\"广州供应商\"}]")
