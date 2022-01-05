//
//  MyCheckCollectionViewCell.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/17.
//

import UIKit

class MyCheckCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        noSelectBg()
    }

    //设置是否选中
     override var isSelected: Bool {
        
        didSet{
            if isSelected {
                selectBg()
            }else{
                noSelectBg()
                
            }
        }
    }
    
    func selectBg()  {
        label.layer.cornerRadius = 14
        
        label.layer.borderWidth = 0.5

        label.layer.borderColor = UIColor.systemBlue.cgColor
        
        label.textColor = UIColor.systemBlue
    }
    
    func noSelectBg()  {
        label.layer.cornerRadius = 14

        label.layer.borderWidth = 0.5

        label.layer.borderColor = UIColor.gray.cgColor
        label.textColor = UIColor.black
        label.adjustsFontSizeToFitWidth = true
    }
    
}
