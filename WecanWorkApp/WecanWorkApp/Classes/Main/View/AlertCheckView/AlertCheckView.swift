//
//  AlertCheckView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/14.
//

import UIKit

class AlertCheckView: MXibView,UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCheckTableViewCell", for: indexPath)
        //            as! CommonCheckTableViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonCheckTableViewCell")
            as! CommonCheckTableViewCell
        cell.selectionStyle = .none
        let data = datas[indexPath.row]
        cell.title.text = data
        
        if !self.isShowCheck {
            cell.selectedIcon.isHidden = true
        }
        
        if defaultSelect.contains(data) {
            tableView.selectRow(at: IndexPath(row: indexPath.row, section: 0), animated: false, scrollPosition: .none)
        }
        
        if defaultUnableCell.contains(data) {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    //表格单元格选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(datas[indexPath.row])
    }
    
    @IBOutlet weak var alertTable: UITableView!
    @IBOutlet weak var ycview: UIView!
    @IBOutlet weak var yctf: UITextField!
    //collectionView的高度约束
    @IBOutlet weak var ycViewHeight: NSLayoutConstraint!
    var datas : [String]
    var defaultUnableCell : [String]
    var defaultSelect : String
    var isShowYc = false
    var isShowCheck = true
    
    init(frame: CGRect,datas:[String],isMultiple:Bool=false,defaultSelect:String="",isShowYc:Bool=false,isShowCheck:Bool = true,defaultUnableCell:[String]=[]) {
        self.datas=datas
        self.defaultSelect=defaultSelect
        self.isShowYc = isShowYc
        self.isShowCheck = isShowCheck
        self.defaultUnableCell = defaultUnableCell
        super.init(frame: frame)
        loadViewFromeNib()
        createDateView(isMultiple)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDateView(_ isMultiple:Bool){
        if !isShowYc {
            ycViewHeight.constant = 0
        }
        alertTable.allowsMultipleSelection=isMultiple
        alertTable.showsVerticalScrollIndicator = false
        //创建一个重用的单元格
        //        alertTable!.register(CommonCheckTableViewCell.self,
        //                             forCellReuseIdentifier: "commonCheckTableViewCell")
        //创建一个重用的单元格
        alertTable.register(UINib(nibName:"CommonCheckTableViewCell", bundle:nil),
                            forCellReuseIdentifier:"commonCheckTableViewCell")
        //        alertTable.reloadData()
        yctf.delegate = self
    }
    
    
    func getSelectData() -> String {
        var assets:[String] = []
        if let indexPaths = self.alertTable.indexPathsForSelectedRows{
            for indexPath in indexPaths{
                assets.append(datas[indexPath.row] )
            }
        }
        if yctf.text != "" && ycViewHeight.constant != 0{
            if assets.count != 0 {
                return assets.joined(separator: ",") + ",\(yctf.text ?? "")"
            }else{
                return yctf.text!
            }
            
        }
        return assets.joined(separator: ",")
    }
}
extension AlertCheckView :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}
