//
//  XibView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/25.
//

import Foundation
import UIKit
class ILXibView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadView()
        
    }
    
    private func getXibName() -> String {
        let clzzName = NSStringFromClass(self.classForCoder)
//        let nameArray = clzzName.componentsSeparatedByString(".")
        let nameArray = clzzName.components(separatedBy: ".")

        var xibName = nameArray[0]
        if nameArray.count == 2 {
            xibName = nameArray[1]
        }
        return xibName
    }
    
    
    func loadView() {
        if self.contentView != nil {
            return
        }
        self.contentView = self.loadViewWithNibName(fileName: self.getXibName(), owner: self)
        self.contentView.frame = self.bounds
        self.contentView.backgroundColor = UIColor.clear
        self.addSubview(self.contentView)
    }
    
    private func loadViewWithNibName(fileName: String, owner: AnyObject) -> UIView {
        let nibs = Bundle.main.loadNibNamed(fileName, owner: owner, options: nil)
        return nibs?[0] as! UIView
    }
    
    
    
}
