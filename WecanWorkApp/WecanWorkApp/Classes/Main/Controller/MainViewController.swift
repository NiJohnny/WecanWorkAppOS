//
//  ViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/24.
//

import UIKit
import RxAlamofire
import RxSwift
import RealmSwift
import ObjectMapper
import SCLAlertView
//import Toast_Swift

struct Model {
    var title:String
    var images:[ModelChild]
}

struct ModelChild {
    var title:String
    var image:String
}
// MARK:- 遵守ModelClickDelegateDelegate协议
extension MainViewController : ModelClickDelegateDelegate {
    func modelClick(selectedModel model: String, selectedAut aut: String) {
        //更具定义的Segue Indentifier进行跳转 点击线右侧设置Indentifier
        if model == "报关操作" || model == "制单操作" || model == "收货操作"{
            if nowUser?.shd == ""{
//                SwiftNotice.showText("请在右上角设置收货地后再进行此操作")
                self.view.makeToast("请在右上角设置收货地后再进行此操作", position: .center)
                return
            }
        }
        if model == "报关操作"{
            nowUser?.workspace = CUSTOM
            print("modelClick")
            self.performSegue(withIdentifier: "制单操作", sender: "报关操作")
        }else if model == "制单操作"{
            nowUser?.workspace = MARKER
            self.performSegue(withIdentifier: model, sender: model)
        }else if aut == "grid_marker_sc"{
            nowUser?.workspace = MARKER
            let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: NSPredicate(format: "status = \(UPLOAD_STATUS_UNUPLOADED) AND area = '\(nowUser!.area)'")) as! [Marker]
            if items.count == 0 {
//                SwiftNotice.showText("没有未上传照片")
                self.view.makeToast("没有未上传照片", position: .center)

            }else{
                var data : [String] = []
                self.marker = items[0]
                for item in items {
                    data.append(item.photoname!)
                }
                self.upload(data: data)
                
            }
        }else if aut == "grid_customs_sc"{
            nowUser?.workspace = CUSTOM
            let items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: NSPredicate(format: "status = \(UPLOAD_STATUS_UNUPLOADED) AND area = '\(nowUser!.area)'")) as! [Custom]
            if items.count == 0 {
//                SwiftNotice.showText("没有未上传照片")
                self.view.makeToast("没有未上传照片", position: .center)
            }else{
                var data : [String] = []
                self.custom = items[0]
                for item in items {
                    data.append(item.photoname!)
                }
                self.upload(data: data)
                
            }
        }else if aut == "grid_receive_sc"{
            nowUser?.workspace = RECEIVE
            let items = RealmTools.objectsWithPredicate(object: Receive.self, predicate: NSPredicate(format: "status = \(UPLOAD_STATUS_UNUPLOADED) AND area = '\(nowUser!.area)'")) as! [Receive]
            if items.count == 0 {
//                SwiftNotice.showText("没有未上传照片")
                self.view.makeToast("没有未上传照片", position: .center)
            }else{
                var data : [String] = []
                self.receive = items[0]
                for item in items {
                    data.append(item.photoname!)
                }
                self.upload(data: data)
                
            }
        }else{
            self.performSegue(withIdentifier: model, sender: model)
        }
    }
}
// MARK:- 遵守UItableview协议
extension MainViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    //返回表格行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 140
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        if (section == 0) {
        //            return 0.5;
        //                }
        return 0.1;
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 12))
    //
    //        view.backgroundColor = UIColor.red
    //        return view
    //    }
    
    //     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 300
    //    }
    
    //创建各单元显示内容(创建参数indexPath指定的单元）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")
            as! MyTableViewCell
        cell.delegate = self
        //下面这两个语句一定要添加，否则第一屏显示的collection view尺寸，以及里面的单元格位置会不正确
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        //重新加载单元格数据
        cell.reloadData(title:models[indexPath.row].title,
                        images: models[indexPath.row].images)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTableVIew(){
        //设置tableView代理
        self.mainTable!.delegate = self
        self.mainTable!.dataSource = self
        
        //去除单元格分隔线
        self.mainTable!.separatorStyle = .none
        
        //创建一个重用的单元格
        self.mainTable!.register(UINib(nibName:"MyTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"myCell")
        
        //设置estimatedRowHeight属性默认值
        self.mainTable!.estimatedRowHeight = 44.0
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.mainTable!.rowHeight = UITableView.automaticDimension
    }
    
}



class MainViewController: UIViewController{
    var marker = Marker()
    var custom = Custom()
    var receive = Receive()
    var timeiStap : String?
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.mainTable.reloadData()
        
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "收货操作":
            nowUser?.workspace = RECEIVE
            let zc = segue.destination as! ReceiveViewController
            zc.timeString = sender as? String
        case "报关操作":
            //            nowUser?.workspace = CUSTOMS
            let zc = segue.destination as! MarkerViewController
            zc.timeString = sender as? String
        case "制单操作":
            //            nowUser?.workspace = MARKER
            let zc = segue.destination as! MarkerViewController
            zc.timeString = sender as? String
        case "设置":
            let zc = segue.destination as! SettingViewController
            zc.timeString = sender as? String
        case "个人信息":
            let zc = segue.destination as! MeViewController
//            zc.timeString = sender as? String
            
        default:
            break
        }
    }
    
    //    let nextVC = ReceiveViewController()
    //在本例中，只有一个分区
    let models = [
        Model(title: "收货",images: [ModelChild(title: "收货操作",image: "grid_receive_cz"),ModelChild(title: "照片上传",image: "grid_receive_sc")]),
        Model(title: "报关",images: [ModelChild(title: "报关操作",image: "grid_customs_cz"),ModelChild(title: "照片上传",image: "grid_customs_sc")]),
        Model(title: "制单",images: [ModelChild(title: "制单操作",image: "grid_marker_cz"),ModelChild(title: "照片上传",image: "grid_marker_sc")])
        
    ]
    
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var lastLoginTime: UILabel!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //版本检测
        HKCheckVersion.manager.CheckVersion(appId: "1599035151") {
        }
        print(nowUser?.UserAut)
        setUpUiVIew()
        setTableVIew()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        //修改导航栏标题文字颜色
        self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.white]
        //修改导航栏按钮颜色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //设置视图的背景图片（自动拉伸）
        self.view.layer.contents = UIImage(named:"main_top_bg.png")!.cgImage
        username.text=nowUser?.username
        lastLoginTime.text="上次登录时间 : "+DateTool.getCurrentDate()
        //    //修改导航栏背景色
        //    self.navigationController?.navigationBar.barTintColor = .blue
        
        
        
        let fileURL = NSHomeDirectory() + "/Documents" + "/" + ("\(nil ?? "")default.realm")
        print(fileURL)
        //        let items = realm.objects(WtdwEntity.self)
        
    }
    
    //视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let  item =  UIBarButtonItem (title:  "返回" , style: .plain, target:  self , action:  nil )
        self.navigationItem.backBarButtonItem = item
        //设置导航栏背景透明
        //        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),
        //                                                                    for: .default)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    //视图将要消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //重置导航栏背景
        //        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        //        self.navigationController?.navigationBar.shadowImage = nil
    }
}

extension MainViewController{
    
    private func setUpUiVIew(){
        let label = UILabel()
        label.text = "唯凯业务操作系统"
        if timeiStap != ""{
            label.text = timeiStap
        }
        label.font = label.font.withSize(26)
        label.textColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        let size = CGSize(width: 40, height: 40)
        let searchItem = UIBarButtonItem(imageName: "设置", highImageName: "设置", size: size,target: self,action: #selector(setting))
        navigationItem.rightBarButtonItem = searchItem
        //        let item = UIBarButtonItem(title: "唯凯操作", style: .plain, target: self, action: nil)
        //        self.navigationItem.backBarButtonItem = item;
    }
    //跳转设置页面
    @objc func setting(){
//        self.performSegue(withIdentifier: "设置", sender: "model")
        self.performSegue(withIdentifier: "个人信息", sender: "model")
    }
}
extension MainViewController{
    func showAlertView(assets:[String],title:String) {
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            kWindowHeight: 600,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:180), datas: assets,isShowCheck: false)
        alert.customSubview = alertCheckView
        //添加确定按钮
        alert.addButton("确定") {}
        alert.showInfo(title, subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
    }
    
    //照片上传
    func upload(data:[String])  {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            if nowUser?.workspace == MARKER{
                print("marker")
                multipartFormData.append((self.marker.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
                multipartFormData.append((self.marker.dom.data(using: String.Encoding.utf8))!, withName: "dom")
                multipartFormData.append((self.marker.source.data(using: String.Encoding.utf8))!, withName: "source")
                if self.marker.mawb == nil {
//                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "mawb")
                }else{
//                    multipartFormData.append((self.marker.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append((self.marker.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
                }
                multipartFormData.append((self.marker.remark.data(using: String.Encoding.utf8))!, withName: "remark")
                if self.marker.finishman == nil {
                    multipartFormData.append((nowUser!.username!.data(using: String.Encoding.utf8))!, withName: "addman")
                }else{
                    
                    multipartFormData.append((self.marker.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
                }
                multipartFormData.append((nowUser!.area.data(using: String.Encoding.utf8))!, withName: "area")
            }else if nowUser?.workspace == CUSTOM{
                print("custom")
                multipartFormData.append((self.custom.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
                multipartFormData.append((self.custom.dom.data(using: String.Encoding.utf8))!, withName: "dom")
                multipartFormData.append((self.custom.source.data(using: String.Encoding.utf8))!, withName: "source")
                if self.custom.mawb == nil {
//                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "mawb")
                }else{
//                    multipartFormData.append((self.custom.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append((self.custom.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
                }
                
                multipartFormData.append((self.custom.remark.data(using: String.Encoding.utf8))!, withName: "remark")
                if self.custom.finishman == nil {
                    multipartFormData.append((nowUser!.username!.data(using: String.Encoding.utf8))!, withName: "addman")
                }else{
                    multipartFormData.append((self.custom.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
                }
                
                multipartFormData.append((nowUser!.area.data(using: String.Encoding.utf8))!, withName: "area")
            }else if nowUser?.workspace == RECEIVE{
                print("recive")
                multipartFormData.append((self.receive.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
                multipartFormData.append((self.receive.dom.data(using: String.Encoding.utf8))!, withName: "dom")
                multipartFormData.append((self.receive.source.data(using: String.Encoding.utf8))!, withName: "source")
                print("groupid",self.receive.groupid)
                print("dom",self.receive.dom)
                print("source",self.receive.source)
                
                if self.receive.khjcno == nil {
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "khjcno")
                }
                else
                {
                    multipartFormData.append((self.receive.khjcno!.data(using: String.Encoding.utf8))!, withName: "khjcno")
                    //                    multipartFormData.append(("SHHF30193SXZ".data(using: String.Encoding.utf8))!, withName: "khjcno")
                    print("khjcno:",self.receive.khjcno!)
                }
                if self.receive.finishman == nil {
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "addman")
                }else{
                    multipartFormData.append((self.receive.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
                    //                    multipartFormData.append(("admin".data(using: String.Encoding.utf8))!, withName: "addman")
                    print("addman:",self.receive.finishman!)
                }
                
                if self.receive.jcno == nil {
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "jcno")
                }else{
                    multipartFormData.append((self.receive.jcno!.data(using: String.Encoding.utf8))!, withName: "jcno")
                    //                    multipartFormData.append(("23997414231216128".data(using: String.Encoding.utf8))!, withName: "jcno")
                    print("jcno:",self.receive.jcno!)
                    
                }
            }
            for item in data{
                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item)
                multipartFormData.append(file, withName: item)
            }
        },urlRequest: try! urlRequest(.post,AnyTool.getUploadUrl())).subscribe(){ uploadRequest in
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
            })
//            uploadRequest.responseJSON { response in
//                debugPrint(response)
//            }
            uploadRequest.responseString { response in
                debugPrint(response)
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                print("values",response.value!)
                print("result",response.result)
                let photoResults:[PhotoResult] = Mapper<PhotoResult>().mapArray(JSONString: response.value!)!
                print(photoResults.toJSONString()!)
                var re : [String] = []
                for item in photoResults{
                    if item.resultstatus == 0 {
                        if nowUser?.workspace == MARKER {
                            RealmTools.updateObjectAttribute(object: Marker.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }else if nowUser?.workspace == CUSTOM{
                            RealmTools.updateObjectAttribute(object: Custom.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }else if nowUser?.workspace == RECEIVE{
                            RealmTools.updateObjectAttribute(object: Receive.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }
                    }else{
                        if nowUser?.workspace == MARKER {
                            re.append((RealmTools.object(Marker.self, primaryKey: item.filename!) as! Marker).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }else if nowUser?.workspace == CUSTOM{
                            re.append((RealmTools.object(Custom.self, primaryKey: item.filename!) as! Custom).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }else if nowUser?.workspace == RECEIVE{
                            re.append((RealmTools.object(Receive.self, primaryKey: item.filename!) as! Receive).khjcno! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }
                    }
                }
                if re.count != 0{
                    self.showAlertView(assets: re, title: "上传结果")
                }else{
//                    SwiftNotice.showText("上传成功")
                    self.view.makeToast("上传成功", position: .center)
                }
            }
        } onError: { (error) in
            print("error",error)
            print(error)
//            SwiftNotice.clear()
            self.view.hideToastActivity()
        } onCompleted: {
            print("onCompleted")
        } onDisposed: {
            print("onDisposed")
            
        }
    }
}
