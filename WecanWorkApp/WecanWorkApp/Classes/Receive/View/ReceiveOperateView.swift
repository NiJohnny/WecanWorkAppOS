//
//  ReceiveOperateView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/15.
//1370

import UIKit
import SCLAlertView
protocol CilckDelegate {
    func btnClick(sender: UIButton)
}
class ReceiveOperateView: MXibView {
    @IBOutlet var bgView: UIView!
    var shdList:[String] = []
    var hwlxList:[String] = []
    var bzlxList:[String] = []
    var dzlxList:[String] = []
    var ycqkList = ["封条松动","箭头标识","危险品标识"]
    var viewList:[UIView] = []
    var viewListNext:[UITextField] = []
    let entity:  ReceiveEntity = ReceiveEntity()//
    @IBOutlet weak var shd: UIButton!
    @IBOutlet weak var jcdate: UIButton!
    @IBOutlet weak var hwlx: UIButton!
    @IBOutlet weak var bzlx: UIButton!
    @IBOutlet weak var dzlx: UIButton!
    @IBOutlet weak var isphoto: UIButton!
    @IBOutlet weak var ycqk: UIButton!
    @IBOutlet weak var fhlx: UIButton!
    @IBOutlet weak var sfws: UIButton!
    @IBOutlet weak var sfdj: UIButton!
    @IBAction func ycqc(_ sender: UIButton) {
        
        showAlertView(assets: ycqkList, btn: sender,title: "异常情况",isMultiple: true,isShowYC :true)
    }
    @IBAction func sfws(_ sender: UIButton) {
        sender.setTitle(sender.currentTitle == "否" ? "是":"否", for: .normal)
    }
    @IBAction func sfdj(_ sender: UIButton) {
        sender.setTitle(sender.currentTitle == "否" ? "是":"否", for: .normal)
    }
    
    @IBAction func fxlx(_ sender: UIButton) {
        sender.setTitle(sender.currentTitle == "客户分货" ? "我司分货":"客户分货", for: .normal)
        
    }
    @IBAction func isphoto(_ sender: UIButton) {
        sender.setTitle(sender.currentTitle == "否" ? "是":"否", for: .normal)
    }
    @IBAction func dzlx(_ sender: UIButton) {
        showAlertView(assets: dzlxList, btn: sender,title: "请选择单证类型",isMultiple: true)
    }
    @IBAction func bzlx(_ sender: UIButton) {
        showAlertView(assets: bzlxList, btn: sender,title: "请选择包装类型",isMultiple: true)
    }
    @IBAction func hwlx(_ sender: UIButton) {
        showAlertView(assets: hwlxList, btn: sender,title: "请选择货物类型")
    }
    
    @IBAction func shd(_ sender: UIButton) {
        showAlertView(assets: shdList, btn: sender, title: "请选择收货地")
    }
    @IBAction func jcdate(_ sender: UIButton) {
        delegate?.btnClick(sender: sender)
    }
    @IBOutlet weak var sfdjViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sfwsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var ponumber: UITextField!
    @IBOutlet weak var sanumber: UITextField!
    @IBOutlet weak var carNum: UITextField!
    @IBOutlet weak var remark: UITextField!
    @IBOutlet weak var dzRemark: UITextField!
    @IBOutlet weak var zjs: UITextField!
    @IBOutlet weak var hwWeight: UITextField!
    @IBOutlet weak var hwVolume: UITextField!
    @IBOutlet weak var mt: UITextField!
    @IBOutlet weak var pm: UITextField!
    @IBOutlet weak var shdw: UITextField!
    @IBOutlet weak var jcbh: UITextField!
    @IBOutlet weak var driverphone: UITextField!
    @IBOutlet weak var wtdw: SearchTextField!
    //    @IBOutlet weak var wtdw: SearchTextField!
    var delegate:CilckDelegate?
    enum OccasionType: CaseIterable {
        case Birthday
        case Wedding
        case Reception
        case Sangeet
        case MehendiSangeet
        case GetTogether
        case BabyShower
        case BabyNaming
        case Engagement
        case Anniversary
        case Other
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromeNib()
        initialSetup()
        viewList.append(shd)
        viewList.append(jcdate)
        viewList.append(jcbh)
        viewList.append(hwlx)
        viewList.append(bzlx)
        viewList.append(hwWeight)
        viewList.append(hwVolume)
        
        
        
        
        viewListNext.append(jcbh)
        viewListNext.append(wtdw)
        viewListNext.append(zjs)
        viewListNext.append(hwWeight)
        viewListNext.append(hwVolume)
        viewListNext.append(mt)
        viewListNext.append(pm)
        viewListNext.append(shdw)
        viewListNext.append(carNum)
        viewListNext.append(driverphone)
        viewListNext.append(remark)
        viewListNext.append(ponumber)
        viewListNext.append(sanumber)
        viewListNext.append(dzRemark)
    }
    
    // MARK:- Private Methods
    private func initialSetup() {
        //        textFieldLocation.heightForRow = 80
        shd.setTitle(nowUser?.shd, for: .normal)
        let terminalList = RealmTools.objectsWithPredicate(object: TerminalEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [TerminalEntity]
        let warehouseList = RealmTools.objectsWithPredicate(object: WarehouseEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [WarehouseEntity]
        shdList = AnyTool.getShd(terminalList: terminalList, warehouseList: warehouseList)!
        jcdate.setTitle(DateTool.getCurrentDate(), for: .normal)
        hwlxList=getTypeName(groupid: 32)
        bzlxList=getTypeName(groupid: 31)
        dzlxList=getTypeName(groupid: 90)
        let wtdwPredicate = NSPredicate(format: "groupid contains '\((1))' AND area contains '\((nowUser?.area)!)'")
        let wtdwList = RealmTools.objectsWithPredicate(object: WtdwEntity.self, predicate: wtdwPredicate) as! [WtdwEntity]
        self.wtdw.customDelegate = self
        self.wtdw.dataList = getWtdw(wl: wtdwList)
        jcdate.setTitle(DateTool.getCurrentDate(), for: .normal)
        shd.setTitle(nowUser?.shd, for: .normal)
        sfwsViewHeight.constant = 0
        sfdjViewHeight.constant = 0
        sfws.isHidden = true
        sfdj.isHidden = true
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
        myScrollView.translatesAutoresizingMaskIntoConstraints = false
        myScrollView.isUserInteractionEnabled = true
        myScrollView.isScrollEnabled = true
    }
    @objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
        self.endEditing(true)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func delegate(delegate:UITextFieldDelegate){
        ponumber.delegate=delegate
        sanumber.delegate=delegate
        carNum.delegate=delegate
        remark.delegate=delegate
        dzRemark.delegate=delegate
        zjs.delegate=delegate
        hwWeight.delegate=delegate
        hwVolume.delegate=delegate
        mt.delegate=delegate
        pm.delegate=delegate
        shdw.delegate=delegate
        jcbh.delegate=delegate
        driverphone.delegate=delegate
        //        textFieldLocation.delegate=delegate
        
    }
}

//MARK:- Search Textfield delegates
extension ReceiveOperateView: SearchTextFieldDelegate {
    
    func didSelect(_ textField: SearchTextField, _ item: ListItem) {
        if textField == wtdw {
            print("Selected Location:", item.name)
            //            let aa = item.name.split(separator: "\n")[0]
            wtdw.text = String(item.name.split(separator: "\n")[0])
        }
    }
    
    func showAlertView(assets:[String],btn:UIButton,title:String,isMultiple: Bool = false,isShowYC : Bool = false) {
        self.endEditing(true)
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            kWindowHeight: 600,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:180), datas: assets, isMultiple: isMultiple, defaultSelect: btn.currentTitle!,isShowYc: isShowYC)
        alert.customSubview = alertCheckView
        
        //添加确定按钮
        alert.addButton("确定") { [self] in
            let selectData = alertCheckView.getSelectData()
            
            if btn == hwlx {
                if selectData == "挂衣" {
                    sfwsViewHeight.constant = 48
                    sfdjViewHeight.constant = 48
                    sfws.isHidden = false
                    sfdj.isHidden = false
                }else{
                    sfwsViewHeight.constant = 0
                    sfdjViewHeight.constant = 0
                    sfws.isHidden = true
                    sfdj.isHidden = true
                }
                
            }
            if selectData == ""{
                btn.setTitle("无", for: .normal)
            }else{
                btn.setTitle(selectData, for: .normal)
            }
            
        }
        alert.showInfo(title, subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
    }
    
    func getTypeName(groupid:Int) -> [String] {
        let ty = RealmTools.objectsWithPredicate(object: TypecodeEntity.self, predicate: NSPredicate(format: "groupid = \(groupid)")) as! [TypecodeEntity]
        var typenameList:[String] = []
        for item in ty {
            typenameList.append(item.typename!)
        }
        return typenameList
    }
    
    func getWtdw(wl:[WtdwEntity]) -> [ListItem] {
        var locations : [ListItem] = []
        for item in wl {
            let v = ListItem(id: UUID().uuidString, name: item.wtkhname!+"\n"+item.wtkhcode!)
            locations.append(v)
        }
        return locations
    }
    
    func clearView()   {
        shd.setTitle(nowUser?.shd, for: .normal)
        jcdate.setTitle(DateTool.getCurrentDate(), for: .normal)
        hwlx.setTitle("普货", for: .normal)
        bzlx.setTitle("无", for: .normal)
        dzlx.setTitle("无", for: .normal)
        isphoto.setTitle("否", for: .normal)
        ponumber.text = ""
        sanumber.text = ""
        carNum.text = ""
        remark.text = ""
        dzRemark.text = ""
        zjs.text = ""
        hwWeight.text = ""
        hwVolume.text = ""
        mt.text = ""
        pm.text = ""
        shdw.text = ""
        jcbh.text = ""
        wtdw.text = ""
        entity.clear()
    }
    
    func isFinish() -> Bool {
        for view in viewList {
            if view is UIButton {
                if (view as! UIButton).titleLabel?.text == "" || (view as! UIButton).titleLabel?.text == "无"{
//                    SwiftNotice.showText("请完成必填项")
                    self.makeToast("请完成必填项", position: .center)

                    return false
                }
            }
            if view is UITextField {
                if (view as! UITextField).text == "" {
//                    SwiftNotice.showText("请完成必填项")
                    self.makeToast("请完成必填项", position: .center)
                    view.becomeFirstResponder()
                    return false
                }
            }
        }
        return true
    }
    
    func setEntity() ->  ReceiveEntity{
        entity.area = nowUser!.area
        entity.goodstp = shd.currentTitle!
        entity.jcdate = jcdate.currentTitle!
        entity.khjcno = jcbh.text!
        entity.piece = Int(zjs.text!)
        entity.weight = Double(hwWeight.text!)
        entity.volume = Double(hwVolume.text!)
        entity.goodstype = hwlx.currentTitle!
        entity.goodsMark = mt.text!
        //        entity.sfdj = tvSfdj.getText().toString();
        //        entity.sfws = tvSfws.getText().toString();
        entity.bzlx = bzlx.currentTitle!
        entity.ycqk = ycqk.currentTitle!
        entity.sfpz = isphoto.currentTitle!
        entity.fhlx = fhlx.currentTitle!
        entity.pm = pm.text!
        entity.shdw = shdw.text!
        entity.cph = carNum.text!
        entity.driverphone = driverphone.text!
        entity.dzlx = dzlx.currentTitle!
        entity.dzremark = dzRemark.text!
        entity.ponumber = ponumber.text!
        entity.sanumber = sanumber.text!
        entity.wtkhname = wtdw.text!
        entity.goodsRemark = remark.text!
        return entity
    }
    
    
    
    func setEntityParam(mEntity:ReceiveEntity) {
        entity.guid = mEntity.guid
        entity.area = mEntity.area
        entity.goodstp = mEntity.goodstp
        entity.jcdate = mEntity.jcdate
        entity.khjcno = mEntity.khjcno
        entity.piece = mEntity.piece
        entity.weight = mEntity.weight
        entity.volume = mEntity.volume
        entity.goodstype = mEntity.goodstype
        entity.goodsMark = mEntity.goodsMark
        //        entity.sfdj = tvSfdj.getText().toString();
        //        entity.sfws = tvSfws.getText().toString();
        entity.bzlx = mEntity.bzlx
        entity.ycqk = mEntity.ycqk
        entity.sfpz = mEntity.sfpz
        entity.fhlx = mEntity.fhlx
        entity.pm = mEntity.pm
        entity.shdw = mEntity.shdw
        entity.cph = mEntity.cph
        entity.driverphone = mEntity.driverphone
        entity.dzlx = mEntity.dzlx
        entity.dzremark = mEntity.dzremark
        entity.ponumber = mEntity.ponumber
        entity.sanumber = mEntity.sanumber
        entity.wtkhname = mEntity.wtkhname
        entity.goodsRemark = mEntity.goodsRemark
        entity.jcno = mEntity.jcno
    }
    
    
    func setView(entity:ReceiveEntity) {
        hwlx.setTitle(entity.goodstype, for: .normal)
        bzlx.setTitle(entity.bzlx, for: .normal)
        zjs.text = String(entity.piece!)
        mt.text = entity.goodsMark
        shd.setTitle(entity.goodstp, for: .normal)
        jcdate.setTitle(entity.jcdate, for: .normal)
        jcbh.text = entity.khjcno
        hwWeight.text = String(entity.weight!)
        sanumber.text = entity.sanumber
        ponumber.text = entity.ponumber
        dzRemark.text = entity.dzremark
        dzlx.setTitle(entity.dzlx, for: .normal)
        driverphone.text = entity.driverphone
        carNum.text = entity.cph
        shdw.text = entity.shdw
        pm.text = entity.pm
        fhlx.setTitle(entity.fhlx, for: .normal)
        isphoto.setTitle(entity.sfpz, for: .normal)
        ycqk.setTitle(entity.ycqk, for: .normal)
        sfws.setTitle(entity.sfws, for: .normal)
        sfdj.setTitle(entity.sfdj, for: .normal)
        wtdw.text = entity.wtkhname
        remark.text = entity.goodsRemark
        hwVolume.text = String(entity.volume!)
        setEntityParam(mEntity: entity)
    }
    
    
    func nextView() -> Bool {
        for view in viewListNext {
            if view.text == "" {
                view.becomeFirstResponder()
                return false
            }
        }
        return true
    }
}

