//
//  SettingViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/9.
//

import UIKit
import swiftScan
class SettingViewController: UIViewController {
    @IBOutlet weak var upload: UIView!
    @IBOutlet weak var delete: UIView!
    @IBOutlet weak var area: UIView!
    @IBOutlet weak var shd: UIView!
    @IBOutlet weak var uploadPhoto: UILabel!
    @IBOutlet weak var deletePhoto: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var shdLabel: UILabel!
    @IBOutlet weak var downLoad: UILabel!
    @IBOutlet weak var versionNumber: UILabel!
    var vm : MainViewModel?
    
    var timeString : String?
    @IBOutlet weak var qrimage: UIImageView!
    func createQR() {
        let qrImg = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: "\(nowUser!.username!)_wecan_app_regist_area_\(nowUser!.area)", size: qrimage.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
        qrimage.image = qrImg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="我的设置"
        vm = MainViewModel(self.view)
        versionNumber.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        // 5.给Label添加手势
        //        upload.isUserInteractionEnabled = true
        upload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:))))
        delete.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:))))
        area.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:))))
        shd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:))))
        downLoad.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:))))
        downLoad.isUserInteractionEnabled = true
//        let searchItem = UIBarButtonItem(imageName: "设置", highImageName: "设置", size: CGSize(width: 40, height: 40),target: self,action: #selector(scan))
//        navigationItem.rightBarButtonItem = searchItem
        
        createQR()
    }
    
    //视图将要出现的时候执行
    override func viewWillAppear(_ animated: Bool) {
        uploadPhoto.text=nowUser?.uploadphoto
        deletePhoto.text=nowUser?.deletePhoto
        areaLabel.text = nowUser?.area
        shdLabel.text = nowUser?.shd
        createQR()
    }
    
    @objc fileprivate func titleLabelClick(_ tapGes : UITapGestureRecognizer) {
        let tag = tapGes.view?.tag
        var sender : [String]?
        if tag == 0 {
            sender = uploadData
            self.performSegue(withIdentifier: "checkVC", sender: sender)
            
        } else if tag == 1{
            sender = deleteData
            self.performSegue(withIdentifier: "checkVC", sender: sender)
            
        }else if tag == 2{
            self.performSegue(withIdentifier: "checkMoreVc", sender: "sendercheckMoreVc")
            
        }else if tag == 3{
            self.performSegue(withIdentifier: "checkMoreVc", sender: "sendercheckMoreVc")
            
        }else if tag == 4{
//            vm.getGys { (gysEntitys:[GysEntity]) in
//                print(gysEntitys.toJSONString())
//                if gysEntitys.count != 0{
//                    let av : RegisterAlertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:130))
//                    let gys : [String] = ["adasd","0980809","9s9s9s9s99s"]
//                    av.showAlertView(assets: gysEntitys)
//                }
//            }
            
//            let gys : [String] = ["adasd","0980809","9s9s9s9s99s"]
//            let av : RegisterAlertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:130))
//            av.showAlertView(assets: gys)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "checkVC":
            let zc = segue.destination as! CheckViewController
            zc.datas = sender as? [String]
            break
            
        case "checkMoreVc":
            let zc = segue.destination as! CheckMoreViewController
            zc.datas = sender as? String
            break
            
        default:
            break
        }
    }
}
extension SettingViewController:LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        NSLog("scanResult:\(scanResult)")
        NSLog("scanResult:\(scanResult.strScanned)")
//        vm.getGys { (gysEntitys:[GysEntity]) in
//            print(gysEntitys.toJSONString())
//             if gysEntitys.count != 0{
//                let av : RegisterAlertView = RegisterAlertView(frame: CGRect(x:0, y:0, width:280, height:130))
//                let gys : [String] = ["adasd","0980809","9s9s9s9s99s"]
//                av.showAlertView(assets: gys)
//            }
//        }
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
    
    @objc func scan(){
        recoCropRect()
    }
    
}
