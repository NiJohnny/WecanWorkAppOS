//
//  SearchView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/23.
//

import UIKit
import swiftScan
protocol SearchDelegate {
    func searchData(tag : Int)
}

class SearchView: UIView ,LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        mawb.text = scanResult.strScanned
    }
    
    var parentController: UIViewController?
    var delegate : SearchDelegate?
    @IBOutlet weak var search: UIView!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var mawb: UITextField!
    @IBOutlet weak var startDate: UIButton!
    @IBOutlet weak var endDate: UIButton!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var scan: UIButton!
    @IBAction func scan(_ sender: Any) {
        recoCropRect()
    }
    @IBAction func reset(_ sender: Any) {
        startDate.setTitle(DateTool.getAgoDate(Date(), -1,"yyyy-MM-dd")+" 00:00", for: .normal)
        endDate.setTitle(DateTool.getCurrentDate("yyyy-MM-dd")+" 23:59", for: .normal)
        mawb.text = ""
    }
    @IBAction func hbrq(_ sender: UIButton) {
        delegate?.searchData(tag: sender.tag)
        if sender.tag == 2{
            changSearchView()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromeNib()
        startDate.setTitle(DateTool.getAgoDate(Date(), -1,"yyyy-MM-dd")+" 00:00", for: .normal)
        endDate.setTitle(DateTool.getCurrentDate("yyyy-MM-dd")+" 23:59", for: .normal)

        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
        if nowUser?.workspace == MARKER {
            scan.setImage(UIImage(named: "扫描_制单"), for: .normal) //按钮图标
            reset.setTitleColor(UIColor(r: 37, g: 199, b: 178), for: .normal)
            confirm.backgroundColor = UIColor(r: 37, g: 199, b: 178)
            
        }else if nowUser?.workspace == CUSTOM {
            scan.setImage(UIImage(named: "扫描_报关"), for: .normal) //按钮图标
            reset.setTitleColor(UIColor(r: 175, g: 96, b: 255), for: .normal)
            confirm.backgroundColor = UIColor(r: 175, g: 96, b: 255)
        }
//        label.textColor = UIColor(r: kNormalColor.0, g: kNormalColor.1, b: kNormalColor.2)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadViewFromeNib(){
        let bondel = Bundle(for : type(of: self))
        let nib  = UINib(nibName:getXibName(),bundle: bondel)
        let vie = nib.instantiate(withOwner: self,options: nil).first as! UIView
        vie.frame = self.bounds
        self.addSubview(vie)
        
    }
    
    private func getXibName() -> String {
        let clzzName = NSStringFromClass(self.classForCoder)
        let nameArray = clzzName.components(separatedBy: ".")
        var xibName = nameArray[0]
        if nameArray.count == 2 {
            xibName = nameArray[1]
        }
        return xibName
    }
    
    func hid(){
        //隐藏
        UIView.animate(withDuration: 0.5, animations: {
            self.search.frame.origin.y = -self.search.frame.height
            self.bgView.alpha = 0
        }, completion: { b in
            self.isHidden = true
        })
    }
    
    func show(){
        //显示
        self.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.search.frame.origin.y = 0
            self.bgView.alpha = 1
        }, completion: { b in
            
        })
        
    }
    
    func changSearchView(){
        self.endEditing(true)
        if self.isHidden == true {
            show()
        }else{
            hid()
        }
        
    }
    
    @objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
        changSearchView()
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
        parentController?.navigationController?.pushViewController(vc, animated: false)
    }
}
