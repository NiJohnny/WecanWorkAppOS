//
//  MarkerOperateViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/26.
//
import SCLAlertView
import Foundation
import UIKit
import RxAlamofire
import RxSwift
import RxCocoa
import CameraManager
import Alamofire
import RxSwift
import swiftScan
import ObjectMapper

private let kBottomViewH : CGFloat = 58

class MarkerOperateViewController: BaseViewController,LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        mawb.text = scanResult.strScanned
    }
    
    @IBAction func scan(_ sender: UIButton) {
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
        vc.navigationController?.navigationBar.isHidden = true
        vc.scanStyle = style

        vc.isOpenInterestRect = true
        vc.scanResultDelegate = self

        //TODO:待设置框内识别
        viewController()?.navigationController?.pushViewController(vc, animated: false)
        
    }
    @IBOutlet weak var mawb: UITextField!
    @IBOutlet weak var finishman: UITextField!
    @IBOutlet weak var finishdate: UIButton!
    @IBOutlet weak var scan: UIButton!
    var markerViewModel : MarkerViewModel?
    var marker = Marker()
    var custom = Custom()
    @IBAction func finishdata(_ sender: Any) {
        hideKeyBoard()
        self.dataPicker.show()
    }
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
    
    fileprivate lazy var bottomOperateView : BottomOperateView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - kBottomViewH
        let titleFrame = CGRect(x: 0, y: contentH, width: kScreenW, height: kBottomViewH)
        let titles = ["总单拍照", "保存"]
        let bottomView = BottomOperateView(frame: titleFrame, titles: titles)
        bottomView.backgroundColor = UIColor.white
        bottomView.delegate = self
        return bottomView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        markerViewModel = MarkerViewModel(self.view)
        
        view.addSubview(bottomOperateView)
        view.addSubview(dataPicker)
        setPhotoBtn(canPhoto: false)
        finishman.text = nowUser?.username
        finishdate.setTitle(DateTool.getCurrentDate(), for: .normal)
        if nowUser?.workspace == MARKER {
            scan.setImage(UIImage(named: "扫描_制单"), for: .normal) //按钮图标
        }else if nowUser?.workspace == CUSTOM {
            scan.setImage(UIImage(named: "扫描_报关"), for: .normal) //按钮图标
        }
    }
    override func keyBoardShow() {
        dataPicker.hid()
    }
    
    func setPhotoBtn(canPhoto:Bool)  {
        bottomOperateView.setEnable(index: 1, isEnable: canPhoto)
    }
}

extension MarkerOperateViewController : BottomOperateViewDelegate {
    func bottomOperateView(_ titleView: BottomOperateView, selectedIndex index: Int) {
        switch index {
        case 0:
            if finishman.text == "" {
//                SwiftNotice.showText("完成人不能为空")
                self.view.makeToast("完成人不能为空", position: .center)

                return
            }
            if mawb.text == "" {
//                SwiftNotice.showText("总运单号不能为空")
                self.view.makeToast("总运单号不能为空", position: .center)

                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let optVerifVC = storyboard.instantiateViewController(withIdentifier: "showCamera") as! CameraViewController
            if nowUser?.workspace == MARKER {
                let entity = Marker()
                entity.mawb = mawb.text
                entity.finishman = finishman.text
                entity.finishdate = finishdate.currentTitle
                optVerifVC.entity = entity
                optVerifVC.mawb = mawb.text  //传值
                viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
            }else if nowUser?.workspace == CUSTOM {
                let entity = Custom()
                entity.mawb = mawb.text
                entity.finishman = finishman.text
                entity.finishdate = finishdate.currentTitle
                optVerifVC.entity = entity
                optVerifVC.mawb = mawb.text  //传值
                viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
            }
            
        case 1://保存type=1取消type=2
            if !checkPhoto() {
                return
            }
            let parameters: Parameters = ["logExtraData":nowUser!.getLogExtraData(),"mawb":mawb.text ?? "","czman":finishman.text ?? "","date":finishdate.currentTitle!,"type":1,"area":nowUser!.area]
            markerViewModel!.request(parameters) { (resultEntity: ResultEntity) in
                if resultEntity.resultstatus == 0{
//                SwiftNotice.showText("保存成功上传照片中")
                self.view.makeToast("保存成功上传照片中", position: .center)
                if nowUser?.workspace == CUSTOM{
                    let items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: NSPredicate(format: "status = \(UPLOAD_STATUS_UNUPLOADED) AND area = '\(nowUser!.area)'")) as! [Custom]
                    
                    if items.count == 0 {
//                        SwiftNotice.showText("没有未上传照片")
                        self.view.makeToast("没有未上传照片", position: .center)

                    }else{
                        var data : [String] = []
                        self.custom = items[0]
                        for item in items {
                            data.append(item.photoname!)
                        }
                        self.upload(data: data)
                        
                    }
                }else if nowUser?.workspace == MARKER{
                    let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: NSPredicate(format: "status = \(UPLOAD_STATUS_UNUPLOADED) AND area = '\(nowUser!.area)'")) as! [Marker]
                    if items.count == 0 {
//                        SwiftNotice.showText("没有未上传照片")
                        self.view.makeToast("没有未上传照片", position: .center)

                    }else{
                        var data : [String] = []
                        self.marker = items[0]
                        for item in items {
                            data.append(item.photoname!)
                        }
                        self.upload(data: data)
                    }
                    
                }
                }else{
//                    SwiftNotice.showText(resultEntity.resultmessage!)
                    self.view.makeToast(resultEntity.resultmessage!, position: .center)

                }
            }
        default:
            print("default")
        }
    }
    
}

extension MarkerOperateViewController : DataPickDelegate{
    func dataPick(dataStr: String!) {
        finishdate.setTitle(dataStr, for: .normal)
    }
    func checkPhoto() -> Bool {
        let predicate = NSPredicate(format: "mawb = '\(mawb.text!)' AND status = 0")
        var items : [Any?] = []
        if nowUser?.workspace == MARKER {
            items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: predicate) as! [Marker]
        }else if nowUser?.workspace == CUSTOM {
            items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: predicate) as! [Custom]
        }
            
        if items.count==0 {
//            SwiftNotice.showText("请拍照")
            self.view.makeToast("请拍照", position: .center)

            bottomOperateView.setEnable(index: 1, isEnable: false)
            return false
        }
        return true
//        else{
//            bottomOperateView.setEnable(index: 1, isEnable: false)
//            return true
//        }
    }
}
extension MarkerOperateViewController {
    func setPhotoButton(){
        let predicate = NSPredicate(format: "mawb = '\(mawb.text!)' AND status = 0")
        var items : [Any?] = []
        if nowUser?.workspace == MARKER {
            print("MARKER")
            items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: predicate) as! [Marker]
        }else if nowUser?.workspace == CUSTOM {
            print("custom")
            items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: predicate) as! [Custom]
        }
        print("-----------\(items.count)*************")
        if items.count != 0 {
            bottomOperateView.setEnable(index: 1, isEnable: true)
        }
    }
    
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
        //服务器路径
        var uploadURL : URL!
         uploadURL = URL(string: URL_IMAGE_DOCUMENT)!
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            if nowUser?.workspace == MARKER{
                uploadURL = URL(string: URL_IMAGE_DOCUMENT)!
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
                uploadURL = URL(string: URL_IMAGE_DOCUMENT)!
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
            }
            for item in data{
                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item)
                multipartFormData.append(file, withName: item)
            }
        },urlRequest: try! urlRequest(.post,uploadURL)).subscribe{ uploadRequest in
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
            })
            
            uploadRequest.responseString { response in
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                let photoResults:[PhotoResult] = Mapper<PhotoResult>().mapArray(JSONString: response.value!)!
                print(photoResults.toJSONString())
                var re : [String] = []
                for item in photoResults{
                    if item.resultstatus == 0 {
                        if nowUser?.workspace == MARKER {
                            RealmTools.updateObjectAttribute(object: Marker.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }else if nowUser?.workspace == CUSTOM{
                            RealmTools.updateObjectAttribute(object: Custom.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }
                    }else{
                        if nowUser?.workspace == MARKER {
                            re.append((RealmTools.object(Marker.self, primaryKey: item.filename!) as! Marker).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }else if nowUser?.workspace == CUSTOM{
                            re.append((RealmTools.object(Custom.self, primaryKey: item.filename!) as! Custom).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }
//                        re.append(item.filename!.replacingOccurrences(of: ".jpg", with: "") + item.resultmessage!)
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
