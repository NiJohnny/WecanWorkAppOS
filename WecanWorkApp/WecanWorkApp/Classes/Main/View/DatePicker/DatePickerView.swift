//
//  DatePickerView.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/25.
//

import UIKit
//这是因为UIDatePicker 增加了pickerStyle，需要设置preferredDatePickerStyle = UIDatePickerStyleWheels才会和以前一样，并且现在对frame的宽高设置已经不生效了，会采用系统默认的宽高。
//解决办法：
//设置frame放到datePickerMode后面设置变成正常了

protocol DataPickDelegate {
    func dataPick(dataStr : String!)
}

class DatePickerView: MXibView {
    var dataPickDelegate : DataPickDelegate?
    @IBOutlet weak var pickView: UIView!
    @IBOutlet weak var titileView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var finish: UIButton!
    var datePicker : UIDatePicker = UIDatePicker()
    var timePicker : UIDatePicker = UIDatePicker()
    @IBAction func cancel(_ sender: Any) {
        changView()
    }
    @IBAction func finish(_ sender: Any) {
        //更新提醒时间文本框
        let formatterData = DateFormatter()
        //日期样式
        formatterData.dateFormat = "yyyy-MM-dd"
        
        //更新提醒时间文本框
        let formatterTime = DateFormatter()
        //日期样式
        formatterTime.dateFormat = "HH:mm"
        
        
        let data = formatterData.string(from: datePicker.date) + " " + formatterTime.string(from: timePicker.date)


        dataPickDelegate?.dataPick(dataStr: data)
        changView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromeNib()
        createDateView()
        self.frame.origin.y = kScreenH
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func hid(){
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y = kScreenH
        }, completion: { b in
        })
    }
    func show(){
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - 250
        }, completion: { b in
            
        })
    }
    
    func changView(){
        if self.frame.origin.y == kScreenH {
            show()
        }else{
            hid()
        }
    }
    
    private func createDateView(){
        //将日期选择器区域设置为中文，则选择器日期显示为中文
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        //设置frame放到datePickerMode后面设置变成正常了
        datePicker.frame = CGRect(x:0, y:titileView.frame.height, width:kScreenW/100*61, height:self.frame.height-titileView.frame.height)
        //注意：action里面的方法名后面需要加个冒号“：”
        datePicker.addTarget(self, action: #selector(dateChanged),
                             for: .valueChanged)
        self.addSubview(datePicker)
        
        //将日期选择器区域设置为中文，则选择器日期显示为中文
        //设置dataPicker风格ios14后风格改变
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        
        timePicker.locale = Locale(identifier: "zh_CN")
        timePicker.datePickerMode = .time
        timePicker.frame = CGRect(x:kScreenW/100*61, y:titileView.frame.height, width:kScreenW/100*39, height:self.frame.height-titileView.frame.height)
        //注意：action里面的方法名后面需要加个冒号“：”
        timePicker.addTarget(self, action: #selector(timeChanged),
                             for: .valueChanged)
        self.addSubview(timePicker)
    }
    //日期选择器响应方法
    @objc func dateChanged(datePicker : UIDatePicker){
        //更新提醒时间文本框
        let formatter = DateFormatter()
        //日期样式
        formatter.dateFormat = "yyyy-MM-dd"
        print(formatter.string(from: datePicker.date))

    }
    
    //日期选择器响应方法
    @objc func timeChanged(datePicker : UIDatePicker){
        //更新提醒时间文本框
        let formatter = DateFormatter()
        //日期样式
        formatter.dateFormat = "HH:mm"
        print(formatter.string(from: datePicker.date))
    }
}
