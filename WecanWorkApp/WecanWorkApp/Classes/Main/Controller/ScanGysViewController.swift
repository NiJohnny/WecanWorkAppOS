//
//  ScanGysViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/12/3.
//

import UIKit
import swiftScan
class ScanGysViewController: UIViewController {
    var vm : MainViewModel?
    @IBAction func scan(_ sender: Any) {
        recoCropRect()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MainViewModel(self.view)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.dismiss(animated: true, completion: nil)
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
        self.navigationController?.pushViewController(vc, animated: false)
        
    }

}
extension ScanGysViewController:LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        let arrayStrings: [String] = scanResult.strScanned!.split(separator: "_").compactMap { "\($0)" }
        let area = arrayStrings[arrayStrings.count-1]
        let czman = arrayStrings[0]
        vm!.getGys(area:area) { [self] (gysEntitys:[GysEntity]) in
            print(gysEntitys.toJSONString())
            if gysEntitys.count != 0{
//                SwiftNotice.showText("供应商数据获取成功")
                self.view.makeToast("供应商数据获取成功", position: .center)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let optVerifVC = storyboard.instantiateViewController(withIdentifier: "registerVc1") as! RegisterViewController1
//
                optVerifVC.gysEntitys = gysEntitys
                optVerifVC.area = area //传值
                optVerifVC.czman = czman //传值
                self.navigationController!.popViewController(animated: true)
                self.navigationController!.pushViewController(optVerifVC, animated: true)
            }else{
//                SwiftNotice.showText("无供应商数据")
                self.view.makeToast("无供应商数据", position: .center)

            }
        }
    }
    
    
    
}
