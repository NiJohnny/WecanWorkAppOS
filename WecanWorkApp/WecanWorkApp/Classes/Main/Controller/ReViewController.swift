//
//  ReViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/11/2.
//

import UIKit

class ReViewController: BaseViewController {
    @IBOutlet weak var mScrollView: UIScrollView!
    
    @IBOutlet var bgView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.bgClick(_:))))
    }
    

    override func keyBoardShow() {
        mScrollView.contentInset.bottom = 300

    }
    
    override func keyBoardHide() {
        mScrollView.contentInset.bottom = 0
       
    }
    
    @objc fileprivate func bgClick(_ tapGes : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
