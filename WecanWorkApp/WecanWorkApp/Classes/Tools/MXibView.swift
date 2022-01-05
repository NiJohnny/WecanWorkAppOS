//
//  MXibView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/25.
//

import UIKit

class MXibView: UIView {
    func loadViewFromeNib(){
        let bondel = Bundle(for : type(of: self))
        let nib  = UINib(nibName:getXibName(),bundle: bondel)
        let vie = nib.instantiate(withOwner: self,options: nil).first as! UIView
        vie.frame = self.bounds
        self.addSubview(vie)
        
    }
     func getXibName() -> String {
        let clzzName = NSStringFromClass(self.classForCoder)
        let nameArray = clzzName.components(separatedBy: ".")
        var xibName = nameArray[0]
        if nameArray.count == 2 {
            xibName = nameArray[1]
        }
        return xibName
    }
}
