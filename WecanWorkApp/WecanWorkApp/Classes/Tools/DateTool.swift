//
//  DateTool.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/27.
//

import Foundation

class DateTool {
///获取当前时间
    class func getCurrentDate(_ format: String = "yyyy-MM-dd HH:mm") -> String {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: nowDate)
        return dateString
    }
    ///获取当前时间
    class func getAgoDate(_ date: Date, _ day: Int, _ format: String? = "yyyy-MM-dd HH:mm") -> String {
        let agoDate: TimeInterval = TimeInterval(day * 24 * 3600)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let dateString = formatter.string(from: date.addingTimeInterval(agoDate))
        return dateString
    }
///时间格式转化
    class func getDate(_ format: String? = FORMAT_DATE, time: String?) -> String {
//        if ??time || time!.starts(with: "1") {
//            return ""
//        }
        if time==nil || time!.starts(with: "1") {
            return ""
        }
        return DateToString(format: format!, date: StringToDate(time: time!))
    }
///将"yyyyMMddHHmmss"格式字符转date
    class func StringToDate(time: String) -> Date {
        var t = time.getNumber()
        while t.count < 14 {
            t = t + "0"
        }
        return StringToDate(time: t, format: "yyyyMMddHHmmss")
    }

    class func StringToDate(time: String, format: String) -> Date {
        let dataformater = DateFormatter()
        dataformater.dateFormat = format
        var value = time.getNumber()
        if value.count < format.count {
            for _ in value.count ..< format.count {
                value = value + "0"
            }
        }
        value = String(value.prefix(14))
        return dataformater.date(from: value)!
    }

///将date转化为指定格式自符
    class func DateToString(format: String, date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: date)
    }
}
