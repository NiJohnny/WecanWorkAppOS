//
//  OperateViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/31.
//

import UIKit
import RxAlamofire
import RxSwift
import RxCocoa
import CameraManager
import Alamofire
import RxSwift
import ObjectMapper
import SCLAlertView

private let kBottomViewH : CGFloat = 58

class ReceiveOperateViewController: BaseViewController ,CilckDelegate{
    func btnClick(sender: UIButton) {
        hideKeyBoard()
        self.dataPicker.show()
        btn =  sender
        print(btn==nil)
    }
    @IBOutlet weak var wrapperView: UIView!
    var scrollView = AutoKeyboardScrollView()
    var views = [String: UIView]()
    var receive = Receive()
    var btn : UIButton? = nil
//    @IBOutlet weak var mawb: UITextField!
//    @IBOutlet weak var finishman: UITextField!
//    @IBOutlet weak var finishdate: UIButton!
//    @IBAction func finishdata(_ sender: Any) {
//        hideKeyBoard()
//        self.dataPicker.show()
//    }
    var wecanParam = WecanParam()
    let disposeBag = DisposeBag()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    fileprivate lazy var dataPicker : DatePickerView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - 250
        let pickerView = DatePickerView(frame:  CGRect(x:0, y: contentH, width: kScreenW, height: 250))
        pickerView.dataPickDelegate = self
        return pickerView
    }()
    
     lazy var receiveOperateView : ReceiveOperateView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - 250
        //        let operateView = ReceiveOperateView(frame:  CGRect(x:0, y: contentH, width: kScreenW, height: 250))
        let operateView = ReceiveOperateView(frame:  CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavigationAndStatusH - 40-kBottomViewH))
        //        pickerView.dataPickDelegate = self
        operateView.delegate = self
        return operateView
    }()
    
    fileprivate lazy var bottomOperateView : BottomOperateView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - kBottomViewH
        let titleFrame = CGRect(x: 0, y: contentH, width: kScreenW, height: kBottomViewH)
        let titles = ["清空新建", "拍照", "保存"]
        let bottomView = BottomOperateView(frame: titleFrame, titles: titles)
        bottomView.backgroundColor = UIColor.white
        bottomView.delegate = self
        return bottomView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(receiveOperateView)
//        setupViews()
//        setupConstraints()
        view.addSubview(bottomOperateView)
        view.addSubview(dataPicker)
        receiveOperateView.delegate(delegate: self)
        //        baseScrollView=receiveOperateView.myScrollView
        setSaveBtn(canSave: false)
        //        let phoneField = MawbField(frame: CGRect(x:20, y:80, width:200, height:30))
        //        view.addSubview(phoneField)
    }
    
    
    override func keyBoardShow() {
        dataPicker.hid()
        receiveOperateView.myScrollView.contentInset.bottom = 225

    }
    
    override func keyBoardHide() {
        receiveOperateView.myScrollView.contentInset.bottom = 0
    }
    
   
    
    func setSaveBtn(canSave:Bool)  {
        bottomOperateView.setEnable(index: 2, isEnable: canSave)
    }
    
    func setOperateView(entity: ReceiveEntity)  {
        print(entity.toJSONString())
        print("-----------"+entity.guid)
        if entity.guid != "" {
//            setPhotoBtn(canPhoto:true)
        }
        receiveOperateView.setView(entity: entity)
    }
    
    func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Remove from super to remove all self constraints
        wrapperView.removeFromSuperview()
        
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        // Be sure to add subviews on contentView
        scrollView.contentView.addSubview(wrapperView)
        
        scrollView.backgroundColor = wrapperView.backgroundColor
        scrollView.isUserInteractionEnabled = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
    }
    
    func setupConstraints() {
        views["scrollView"] = scrollView
        views["wrapperView"] = wrapperView
        
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views)
        constraints +=  NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[wrapperView]|", options: [], metrics: nil, views: views)
        constraints +=  NSLayoutConstraint.constraints(withVisualFormat: "V:|[wrapperView]|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(constraints)
    }
}



//let meimeiDic:[String: Any] = meimei.toJSON()
//let parameters:[String : Any] = [
//    "foo": [1,2,3],
//    "bar": [
//        "baz": "qux"
//    ]
//]
//
//Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters,
//                  encoding: JSONEncoding.default)
//// HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}

extension ReceiveOperateViewController : BottomOperateViewDelegate {
    func bottomOperateView(_ titleView: BottomOperateView, selectedIndex index: Int) {
        switch index {
        case 0:
            receiveOperateView.clearView()
            setSaveBtn(canSave: true)
        case 1:
            if receiveOperateView.jcbh.text == "" {
//                SwiftNotice.showText("进仓编号不能为空")
                self.view.makeToast("进仓编号不能为空", position: .center)

                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let optVerifVC = storyboard.instantiateViewController(withIdentifier: "showCamera") as! CameraViewController
            optVerifVC.callback = {(jcno) in
                        let predicate = NSPredicate(format: "jcno = '\(jcno)'")
                        let items = RealmTools.objectsWithPredicate(object: Receive.self, predicate: predicate) as! [Receive]
                        print(items)
                        if items.count>0 {
                            print("true")
                            self.setSaveBtn(canSave: true)
                        }else{
                            self.setSaveBtn(canSave: false)
                        }
            }
            let entity = Receive()
            entity.khjcno = receiveOperateView.jcbh.text
            entity.jcno = receiveOperateView.jcbh.text
            entity.finishman = nowUser?.area
            optVerifVC.entity = entity
            optVerifVC.mawb = receiveOperateView.jcbh.text  //传值
            viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
       
        case 2:
            if receiveOperateView.isFinish(){
            let meimeiDic:[String: Any] = receiveOperateView.setEntity().toJSON()
//            SwiftNotice.wait()
                self.view!.makeToastActivity(.center)
            if receiveOperateView.entity.guid == ""{
                RxAlamofire.requestJSON(.post, RECEIVE_OPERATE,parameters:meimeiDic,encoding:JSONEncoding.default).subscribe(onNext: { [self]
                    dataResponse in
                    if let dictionary = dataResponse.1 as? [String: Any] {
//                        SwiftNotice.clear()
                        self.view.hideToastActivity()
                        if let resultmessage = dictionary["resultmessage"] as? String {
                            print("guid----\(resultmessage)")
                            SwiftNotice.showText(resultmessage)
                            self.view.makeToast(resultmessage, position: .center)

                        }
                        if let resultstatus = dictionary["resultstatus"] as? Int {
                            if resultstatus == 0 {
                                if let resultguid = dictionary["resultguid"] as? String {
                                    print("guid----\(resultguid)")
                                    receiveOperateView.entity.guid = resultguid
                                    receiveOperateView.entity.jcno = resultguid
                                    upload()
                                }
                            }
                        }
                        
                        
                    }
                },onError: { (error) in
//                    SwiftNotice.clear()
                    self.view.hideToastActivity()
                    //                    SwiftNotice.showText(error!)
                    print("请求失败！错误原因：", error)
                }, onCompleted: {
//                    SwiftNotice.clear()
                }).disposed(by: disposeBag)
            }else {
                RxAlamofire.requestJSON(.put, RECEIVE_OPERATE,parameters:meimeiDic,encoding:JSONEncoding.default)
                    .map{$1}
                    .mapObject(type: ResultEntity.self)
                    .debug()
                    .subscribe(onNext: { [self]  (resultEntity: ResultEntity) in
//                        SwiftNotice.clear()
                        self.view.hideToastActivity()
//                        SwiftNotice.showText(resultEntity.resultmessage!)
                        self.view.makeToast(resultEntity.resultmessage!, position: .center)

                        upload()
                    },onError: { (error) in
//                        SwiftNotice.clear()
                        self.view.hideToastActivity()
                        //                    SwiftNotice.showText(error!)
                        print("请求失败！错误原因：", error)
                    }, onCompleted: {
                    }).disposed(by: disposeBag)
            }
            }
        default:
            print("def")
        }
    }
}


extension ReceiveOperateViewController{
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
    
    func upload()  {
        let data = RealmTools.objectsWithPredicate(object: Receive.self, predicate: NSPredicate(format: "status = 0 AND area = '\(nowUser!.area)' AND khjcno = '\(receiveOperateView.jcbh.text!)'")) as! [Receive]
        if data.count>0 {
            self.receive = data[0]
        }else{
//            SwiftNotice.showText("没有照片请先拍照")
            self.view.makeToast("没有照片请先拍照", position: .center)
            return
        }
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        /*
         多文件上传
         */
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            multipartFormData.append((self.receive.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
            multipartFormData.append((self.receive.dom.data(using: String.Encoding.utf8))!, withName: "dom")
            multipartFormData.append((self.receive.source.data(using: String.Encoding.utf8))!, withName: "source")
            multipartFormData.append((self.receive.khjcno!.data(using: String.Encoding.utf8))!, withName: "khjcno")
            multipartFormData.append((self.receive.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
            multipartFormData.append((receiveOperateView.entity.guid.data(using: String.Encoding.utf8))!, withName: "jcno")
            for item in data{
                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item.photoname!)
                multipartFormData.append(file, withName: item.photoname!)
            }
        },urlRequest: try! urlRequest(.post,URL_IMAGE_DOCUMENT_JCNO)).subscribe{ uploadRequest in
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
            })
            uploadRequest.responseString { response in
                
                debugPrint(response)
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                print(response.value!)
                let photoResults:[PhotoResult] = Mapper<PhotoResult>().mapArray(JSONString: response.value!)!
                print(photoResults.toJSONString())
                var re : [String] = []
                for item in photoResults{
                    if item.resultstatus == 0 {
                        RealmTools.updateObjectAttribute(object: Receive.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                    }else{
                        re.append((RealmTools.object(Receive.self, primaryKey: item.filename!) as! Receive).khjcno! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
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
            print(error)
//            SwiftNotice.clear()
            self.view.hideToastActivity()
        } onCompleted: {
            print("finish")
            
        } onDisposed: {
            print("onDisposed")
        }
    }
    
}

extension ReceiveOperateViewController : DataPickDelegate{
    func dataPick(dataStr: String!) {
//        finishdate.setTitle(dataStr, for: .normal)
        if btn != nil {
            btn?.setTitle(dataStr, for: .normal)
        }
        btn = nil
    }
}

extension ReceiveOperateViewController:UITextFieldDelegate {
    
    
    
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //
    //        animateViewMoving(up: true, moveValue: 300)
    //
    //    }
    //
    //    func textFieldDidEndEditing(textField: UITextField) {
    //
    //        animateViewMoving(up: false, moveValue: 300)
    //
    //    }
    //
    //
    //
    //    func animateViewMoving (up:Bool, moveValue :CGFloat){
    //
    //        dispatch_after(UInt64(0.3), dispatch_get_main_queue()) {
    //
    //            let movement:CGFloat = ( up ? -moveValue : moveValue)
    //
    //            UIView.beginAnimations( "animateView", context: nil)
    //
    //            UIView.setAnimationBeginsFromCurrentState(true)
    //
    //            self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
    //
    //            UIView.commitAnimations()
    //
    //        }
    //
    //    }
    //
    //
    //
    //// 点击输入框收起键盘
    //
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if receiveOperateView.nextView(){
            self.view.endEditing(true)
        }
        return true
    }
    
    //    func textFieldShouldReturn(textField: UITextField) -> Bool {
    //
    //        //收起键盘
    //
    //hideKeyBoard()
    //        print("hide")
    //        //打印出文本框中的值
    //
    //
    //        return true
    //
    //    }
    
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //                textField.resignFirstResponder()
    //
    //                //键盘收回，view放下
    //
    //                UIView.animate(withDuration: 0.4, animations: {
    //
    //                    self.view.frame.origin.y = 0
    //
    //                })
    //
    //                return true
    //    }
    //
    //    func textFieldDidBeginEditing(textView:UITextField) {
    //
    //        //view弹起跟随键盘，高可根据自己定义
    //
    //        UIView.animate(withDuration: 0.4, animations: {
    //
    //            self.view.frame.origin.y = -150
    //
    //        })
    //
    //    }
    
}
