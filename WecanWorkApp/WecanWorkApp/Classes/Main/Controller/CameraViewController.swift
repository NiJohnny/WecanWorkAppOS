//
//  CameraViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/11.
//

import UIKit
import CameraManager
import RealmSwift
import RxAlamofire
class CameraViewController: UIViewController {
    var callback : ((String) -> Void)?
    var entity : Any? = nil
    var mawb : String?
    var groupid : String?
    var dom : String?
    var source : String?
    var khjcno : String?
    var remark : String?
    var addman : String?
    var marker : Marker?
    var custom : Custom?
    var receive : Receive?
    @IBOutlet weak var cameraButton: UIButton!
    //    var marker = Marker()
//    var custom = Custom()
    
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var flashModeImageView: UIImageView!
    let cameraManager = CameraManager()
    @IBAction func cameraButton(_ sender: Any) {
        //        let temp = Int(arc4random()%100)+1
        //        self.cameraManager.imageAlbumName = "a\(57)"
        
        let time = Int(Date().timeIntervalSince1970 * 1000)
        cameraManager.time = time
        
        cameraManager.capturePictureWithCompletion({ [self] result in
            switch result {
            case .failure:
                print("-----------------------------------------------    failure")
                
            case .success(let content):
                print("-----------------------------------------------    succes")
                self.previewImage.image = content.asImage
//                let marker = Marker()
//                marker.mawb = mawb
//                marker.photoname = String(time)+".jpg"
                
                if entity is Marker{
                    let marker = Marker()
                    marker.groupid = self.marker!.groupid
                    marker.dom = self.marker!.dom
                    marker.source = self.marker!.source
                    marker.remark = self.marker!.remark
                    marker.finishman = self.marker?.finishman
                    marker.mawb = self.marker?.mawb
                    marker.finishdate = self.marker?.finishdate
                    marker.photoname = String(time)+".jpg"
                    RealmTools.add(marker) {}
                }else if entity is Custom {
                    let custom = Custom()
                    custom.groupid = self.custom!.groupid
                    custom.dom = self.custom!.dom
                    custom.source = self.custom!.source
                    custom.remark = self.custom!.remark
                    custom.finishman = self.custom?.finishman
                    custom.mawb = self.custom?.mawb
                    custom.finishdate = self.custom?.finishdate
                    custom.photoname = String(time)+".jpg"
                    RealmTools.add(custom) {}
                }else if entity is Receive {
                    let receive = Receive()
                    receive.source = self.receive!.source
                    receive.mawb = self.receive?.mawb
                    receive.finishman = self.receive?.finishman
                    receive.finishdate = self.receive?.finishdate
                    receive.jobno = self.receive?.jobno
                    receive.khjcno =  self.receive?.khjcno
                    receive.jcno = self.receive?.jcno
                    receive.photoname = String(time)+".jpg"
                    RealmTools.add(receive) {}
                }
                
            }
        })
    }
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidDisappear(_ animated: Bool) {
        callback?(mawb!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(mawb)
        self.title = mawb
        cameraButton.eventInterval = 0.57
        cameraManager.cameraOutputQuality = .inputPriority
        if entity is Marker{
            self.marker = entity as! Marker
            print(self.marker)
            
            groupid = self.marker?.groupid
            dom = self.marker?.dom
            source = self.marker?.source
            remark = self.marker?.remark
            addman = self.marker!.finishman
            
          
        }else if entity is Custom {
            self.custom = entity as! Custom
            
            groupid = self.custom?.groupid
            dom = self.custom?.dom
            source = self.custom?.source
            remark = self.custom?.remark
            addman = self.custom!.finishman
        }else if entity is Receive {
            self.receive = entity as! Receive
            groupid = self.receive?.groupid
            dom = self.receive?.dom
            source = self.receive?.source
            remark = self.receive?.remark
            addman = self.receive!.finishman
        }
//        let a = CGView(frame: cameraView.bounds)
//         cameraView.addSubview(a)
//        self.view.addSubview(a)
        navigationController?.navigationBar.isHidden = false
//        cameraManager.addPreviewLayerToView(cameraView)
//        SwiftNotice.wait()
//        self.view!.makeToastActivity(.center)

        cameraManager.addLayerPreviewToView(cameraView, newCameraOutputMode: .stillImage) {
//            self.view.makeToast("无权限无法登录")
//            print("相机载入成功111111111")
////            SwiftNotice.clear()
////            SwiftNotice.showText("相机载入成功111111111")
//            self.view.hideToast()
//            self.view.hideAllToasts()
//            self.view.hideToastActivity()
        }
        previewImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(preView)))
        
//        flashModeImageView.image = UIImage(named: "btn_search")
        if cameraManager.hasFlash {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeFlashMode))
            flashModeImageView.addGestureRecognizer(tapGesture)
        }
    }
    
}


extension CameraViewController {
    
//    func upload(data:[String])  {
//        print(nowUser?.workspace)
//        /*
//         多文件上传
//         */
//
//        //字符串
//        let strData = "hangge.com".data(using: String.Encoding.utf8)
//        //数字
//        let intData = String(10).data(using: String.Encoding.utf8)
//        //文件1
//        //        let path  = Bundle.main.url(forResource: "0", withExtension: "png")!
//        //        let file1Data = try! Data(contentsOf: path)
//        //文件2
//        //        let file2URL = Bundle.main.url(forResource: "1", withExtension: "png")
//
//        //服务器路径
//        let uploadURL = URL(string: URL_IMAGE_DOCUMENT)!
//
//        let filePath = URL(fileURLWithPath: kPhotoPath).appendingPathComponent("tempImg1623396983.jpg")
//        let file2URL = URL(fileURLWithPath: kPhotoPath).appendingPathComponent("tempImg1623397034.jpg")
//
//
//        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
//            if nowUser?.workspace == MARKER{
//                print("marker")
//                multipartFormData.append((self.marker?.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
//                multipartFormData.append((self.marker?.dom.data(using: String.Encoding.utf8))!, withName: "dom")
//                multipartFormData.append((self.marker?.source.data(using: String.Encoding.utf8))!, withName: "source")
//                multipartFormData.append((self.marker?.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
//                multipartFormData.append((self.marker?.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
//                multipartFormData.append((self.marker?.remark.data(using: String.Encoding.utf8))!, withName: "remark")
//                multipartFormData.append((self.marker?.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
//                multipartFormData.append((self.marker?.area!.data(using: String.Encoding.utf8))!, withName: "area")
////                multipartFormData.append(dom!.data(using: String.Encoding.utf8)!, withName: "dom")
////                multipartFormData.append(source!.data(using: String.Encoding.utf8)!, withName: "source")
////                multipartFormData.append(mawb!.data(using: String.Encoding.utf8)!, withName: "khjcno")
////                multipartFormData.append(mawb!.data(using: String.Encoding.utf8)!, withName: "mawb")
////                multipartFormData.append(remark!.data(using: String.Encoding.utf8)!, withName: "remark")
////                multipartFormData.append(addman!.data(using: String.Encoding.utf8)!, withName: "addman")
//            }else if nowUser?.workspace == CUSTOMS{
//                print("custom")
//                multipartFormData.append((self.custom?.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
//                multipartFormData.append((self.custom?.dom.data(using: String.Encoding.utf8))!, withName: "dom")
//                multipartFormData.append((self.custom?.source.data(using: String.Encoding.utf8))!, withName: "source")
//                multipartFormData.append((self.custom?.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
//                multipartFormData.append((self.custom?.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
//                multipartFormData.append((self.custom?.remark.data(using: String.Encoding.utf8))!, withName: "remark")
//                multipartFormData.append((self.custom?.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
//                multipartFormData.append((self.custom?.area!.data(using: String.Encoding.utf8))!, withName: "area")
//            }else if nowUser?.workspace == RECEIVE{
//                print("reveive")
//                multipartFormData.append((self.receive?.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
//                multipartFormData.append((self.receive?.dom.data(using: String.Encoding.utf8))!, withName: "dom")
//                multipartFormData.append((self.receive?.source.data(using: String.Encoding.utf8))!, withName: "source")
//                multipartFormData.append((self.receive?.khjcno!.data(using: String.Encoding.utf8))!, withName: "khjcno")
//                multipartFormData.append((self.receive?.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
//                multipartFormData.append((self.receive?.jcno!.data(using: String.Encoding.utf8))!, withName: "StoreAppImg")
//            }
//
//            for item in data{
//                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item)
//                multipartFormData.append(file, withName: item)
//            }
//
//            //           multipartFormData.append(filePath, withName: "file1",
//            //                                            fileName: "php.png", mimeType: "image/jpg")
//            //           multipartFormData.append(file2URL, withName: "file2")
//        },urlRequest: try! urlRequest(.post,uploadURL)).subscribe{ uploadRequest in
//            uploadRequest.uploadProgress(closure: { (progress) in
//                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
//            })
//
//            uploadRequest.responseJSON { response in
//                debugPrint(response)
//            }
//        } onError: { (error) in
//            print(error)
//        } onCompleted: {
//            print("finish")
//        } onDisposed: {
//            print("onDisposed")
//
//        }
//    }
    
    @objc func changeFlashMode(_ sender: UIButton) {
        switch cameraManager.changeFlashMode() {
        case .off:
            flashModeImageView.image = UIImage(named: "flash_off")
        case .on:
            flashModeImageView.image = UIImage(named: "flash_on")
        case .auto:
            flashModeImageView.image = UIImage(named: "flash_auto")
        }
    }
    
    @objc func preView(_ sender: UIButton) {
        //        var items :[Any]? = nil
        var imagesResults :[PhotoEntity]? = []
        if entity is Marker{
            let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: NSPredicate(format: "mawb = '\(mawb!)' AND status = 0")) as! [Marker]
            if items.count>0 {
            for item in items {
                imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
            }
            }
        }else if entity is Custom {
            let items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: NSPredicate(format: "mawb = '\(mawb!)' AND status = 0")) as! [Custom]
            if items.count>0 {
                for item in items {
                    imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
                }
            }
            
        }else if entity is Receive {
            let items = RealmTools.objectsWithPredicate(object: Receive.self, predicate: NSPredicate(format: "khjcno = '\(mawb!)' AND status = 0")) as! [Receive]
            if items.count>0 {
            for item in items {
                imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
            }
            }
        }
        
        if imagesResults?.count == 0 {
//          SwiftNotice.showText("请先拍照")
            self.view.makeToast("请先拍照", position: .center)
            return
        }
        
        
        //开始选择照片，最多允许选择4张
        _ = self.presentPreviewPicker(uivc:self,isShowUpload:false,maxSelected:100,imagesResults: imagesResults!) { (assets) in
            //结果处理
            print("共选择了\(assets.count)张图片，分别如下：")
            for asset in assets {
                print(asset)
//                self.upload(data: assets)
            }
        }
//        //开始选择照片，最多允许选择4张
//        _ = self.presentPreviewPicker(maxSelected:100,imagesResults: imagesResults!) { (assets) in
//            //结果处理
//            print("共选择了\(assets.count)张图片，分别如下：")
//            for asset in assets {
//                print(asset)
//            }
//        }
        let fileManager = FileManager.default
        var paths = fileManager.subpaths(atPath: kPhotoPath)
        for item in paths!
        {
            print("-----77777")
            print(item)
        }
        
    }
}


