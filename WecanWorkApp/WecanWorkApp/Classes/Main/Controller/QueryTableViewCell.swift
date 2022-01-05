//
//  QueryTableViewCell.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/2.
//

import UIKit
import RxSwift
protocol CouponTableViewCellDelegate {
    func couponBtnClick(couponID:Int,entity : QueryEntity,cell:QueryTableViewCell)
}
class QueryTableViewCell: UITableViewCell {
    var delegate:CouponTableViewCellDelegate!
    @IBAction func photo(_ sender: UIButton) {
        delegate.couponBtnClick(couponID: 1,entity: entity!,cell: self)
    }
    @IBAction func photoMange(_ sender: UIButton) {
        delegate.couponBtnClick(couponID: 2,entity: entity!,cell: self)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        delegate.couponBtnClick(couponID: 3,entity: entity!,cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setBtnBg(view:photo)
        setBtnBg(view:photoManage)
        setBtnBg(view:delete)
    }
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var mawb: UILabel!
    @IBOutlet weak var finishDate: UILabel!
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var photoManage: UIButton!
    @IBOutlet weak var delete: UIButton!
  
    var entity : QueryEntity?{
        didSet{
            mawb.text = entity?.mawb
            finishDate.text = "完成日期 : "+(entity?.nodedate ?? "")
        }
    }
    
    func setBtnBg(view: UIButton)  {
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1

        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.cornerRadius = 5

        view.layer.borderWidth = 1

        view.layer.borderColor = UIColor.systemBlue.cgColor
        
        view.layer.shadowColor = UIColor.black.cgColor;
        view.layer.shadowOffset = CGSize(width:0.0, height:0.0);
        view.layer.shadowOpacity = 0.5;
        
//        view.layer.shadowOpacity = 0.8 //阴影区域透明度
//        view.layer.shadowColor = UIColor.black.cgColor // 阴影区域颜色
//        view.layer.shadowOffset = CGSize(width: 1, height: 0.2) //阴影区域范围
    }
    
}
//"完成日期: "
