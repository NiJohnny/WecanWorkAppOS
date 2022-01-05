//
//  SfzViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/9/30.
//
///var/mobile/Containers/Data/Application/1118C542-A465-4FB3-AD09-63DA82F4A700/Documents
//file:///var/mobile/Media/DCIM/100APPLE/IMG_0926.JPG
import UIKit
import Photos
import IDCardCamera
import Kingfisher
import Photos
class SfzViewController: UIViewController,CardDetectionViewControllerDelegate {
    
    func authorize()->Bool{
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            scanIDCard()
            return true
            
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.authorize()
                })
            })
            
        default: ()
            DispatchQueue.main.async(execute: { () -> Void in
                let alertController = UIAlertController(title: "照片访问受限",
                                                        message: "点击“设置”，允许访问您的照片",
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
                
                let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                    (action) -> Void in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(url, options: [:],
                                                      completionHandler: {
                                                        (success) in
                                                      })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
        return false
    }
    
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        if idCard == 0 {
            imgFront.image = UIImage(cgImage: image)
            saveImage(uiImageView: imgFront)
        }else {
            imgBack.image = UIImage(cgImage: image)
            saveImage(uiImageView: imgBack)
        }
        //                swiftOCRInstance.recognize(UIImage(named: "login_bg")!) { (data) in
        //                    print("99999999999999999999")
        //                    print(data)
    }
    
    @IBAction func front(_ sender: UIButton) {
        idCard = 0
        _ = authorize()
    }
    @IBAction func back(_ sender: UIButton) {
        idCard = 1
        _ = authorize()
        
    }
    var callback : (([String]) -> Void)?
    var photos = [String](repeating: "", count: 2)
    @IBOutlet weak var imgFront: UIImageView!
    @IBOutlet weak var imgBack: UIImageView!
    var idCard = 0
    //存放照片资源的标志符
    var localId:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgFront.kf.setImage(with:URL(fileURLWithPath: photos[0].replacingOccurrences(of: "file://", with: "")))
        imgBack.kf.setImage(with:URL(fileURLWithPath: photos[1].replacingOccurrences(of: "file://", with: "")))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        callback?(photos)
    }
    func scanIDCard() {
        // Set the scan settings
        // In this example the aspect ratio is that of a typical credit card
        // The width and height units are not important
        let settings = CardDetectionSettings(width: 85.6, height: 53.98)
        // Create the view controller
        let controller = CardDetectionViewController()
        controller.settings.orientation = .landscape
        // Set the delegate that will receive the result
        controller.delegate = self
        
        // Present the card detection view controller
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func saveImage(uiImageView: UIImageView) {
        let image = uiImageView.image!
        
        PHPhotoLibrary.shared().performChanges({
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = result.placeholderForCreatedAsset
            //保存标志符
            self.localId = assetPlaceholder?.localIdentifier
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("保存成功!")
                //通过标志符获取对应的资源
                let assetResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: [self.localId], options: nil)
                let asset = assetResult[0]
                let options = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
                    -> Bool in
                    return true
                }
                //获取保存的图片路径
                asset.requestContentEditingInput(with: options, completionHandler: { [self]
                    (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
                    if idCard == 0{
                        photos[0] = contentEditingInput!.fullSizeImageURL!.absoluteString
                    }else{
                        photos[1] = contentEditingInput!.fullSizeImageURL!.absoluteString
                    }
                    print("地址：",contentEditingInput!.fullSizeImageURL!)
                    print("地址2：",contentEditingInput!.fullSizeImageURL!.absoluteString)
                })
            } else{
                print("保存失败：", error!.localizedDescription)
            }
            
        }
    }
    
}
