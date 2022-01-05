//
//  String-Extension.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/27.
//

import Foundation
import UIKit
extension String {
    public func toDouble() -> Double {
        return  self == "" ? 0:Double(self)!
    }
    public func toFloat() -> CGFloat {
        return CGFloat(toDouble())
    }
    public func toInt() -> Int {
        return self == "" ? 0:Int(self)!
    }
    public func uppercased() -> String {
        return NSString(string:self).uppercased
    }
    ///是否匹配正则表达式
    ///
    /// - Parameter format: 正则表达式格式
    public func isFormat(_ format: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", format).evaluate(with:self)
    }
    ///获取字符中的数字
    public func getNumber() -> String {
        var number = ""
        for i in self {
            if i >= "0" && i <= "9" || i == "." {
                number.append(i)
            }
        }
        return number == "" ? "0" : number
    }
    /// 转成指定格式字符
    ///
    /// - Parameter format: 保留小数位数
    public func toString(_ format: Int) -> String {
        return String(format: "%.\(format)f", self.toFloat())
    }
    
}

