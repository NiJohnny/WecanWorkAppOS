//
//  CheckTableViewCell.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/10.
//

import UIKit

class CheckTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!
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
        }
        // Configure the view for the selected state
    }

    
}
