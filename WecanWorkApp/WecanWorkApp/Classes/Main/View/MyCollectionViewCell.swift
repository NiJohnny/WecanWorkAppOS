//
//  MyCollectionViewCell.swift
//  hangge_1591
//
//  Created by hangge on 2018/1/3.
//  Copyright © 2018年 hangge. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
    //用于显示封面缩略图
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

