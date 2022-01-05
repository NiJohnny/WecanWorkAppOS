//
//  ReceiveTableViewCell.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/27.
//

import UIKit
protocol ReceiveTableViewCellDelegate {
    func couponBtnClick(couponID:Int!,entity : ReceiveQueryItemEntity?)
}
class ReceiveTableViewCell: UITableViewCell {
    var delegate:ReceiveTableViewCellDelegate!
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var photoMange: UIButton!
    @IBAction func photo(_ sender: UIButton) {
                delegate.couponBtnClick(couponID: 1,entity: entity)
    }
    @IBAction func photoMange(_ sender: UIButton) {
        delegate.couponBtnClick(couponID: 2,entity: entity)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setBtnBg()
    }
    @IBOutlet weak var imageStatus: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var jcno: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var jzt: UILabel!
    @IBOutlet weak var man: UILabel!
    var entity : ReceiveQueryItemEntity?{
        didSet{
            jcno.text = "进仓编号: \(entity?.khjcno ?? "")"
            date.text = entity?.jcdate
            man.text = entity?.addman
            jzt.text = String((entity?.piece)!)+"/"+String((entity?.weight)!)+"/" + String((entity?.volume)!)
            if entity?.hwstatus == 500 {
                status.text = "已出库"
            }else if entity?.hwstatus == 300{
                status.text = "已入库"
            }else if entity?.hwstatus == 400{
                status.text = "已配库"
            }else{
                status.text = "状态:\(String((entity?.hwstatus)!))"
            }
        }
    }
    
    func setBtnBg()  {
        photo.layer.cornerRadius = 5
        photo.layer.borderWidth = 1

        photo.layer.borderColor = UIColor.systemBlue.cgColor
        photoMange.layer.cornerRadius = 5

        photoMange.layer.borderWidth = 1

        photoMange.layer.borderColor = UIColor.systemBlue.cgColor
        
//        photoMange.layer.shadowOpacity = 0.8 //阴影区域透明度
//        photoMange.layer.shadowColor = UIColor.black.cgColor // 阴影区域颜色
//        photoMange.layer.shadowOffset = CGSize(width: 1, height: 1) //阴影区域范围
    }
}
