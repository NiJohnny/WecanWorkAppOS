//
//  CommonCheckTableViewCell.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/15.
//

import UIKit

class CommonCheckTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print(isSelected)
        if isSelected {
            selectedIcon.image = UIImage(named: "选中")
        }else{
            selectedIcon.image = UIImage(named: "未选中")
        }    }
    
}
