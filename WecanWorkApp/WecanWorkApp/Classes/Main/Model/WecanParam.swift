//
//  WecanParam.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/1.
//

import UIKit
class KeyValue {
    var wecanParam: WecanParam!
    var value: String = ""
    var isUnBase = false
    init(_ value: WecanParam) {
        self.wecanParam = value
    }
    init(_ value: String, _ isUnBase: Bool) {
        self.value = value
        self.isUnBase = isUnBase
    }
    init(_ value: String) {
        self.value = value
    }
}
///方便组成参数
class WecanParam {

    var arraylist: [String: KeyValue] = [:]
    private var parentParam: WecanParam!

    init() {
    }
    init(_ key: String, _ value: String) {
        put(key, value)
    }
    init(_ key: String, _ value: WecanParam) {
        put(key, value)
    }
    @discardableResult
    func put(_ key: String, _ value: Int) -> WecanParam {
        arraylist[key] = KeyValue("\(value)", true)
        return self
    }
    @discardableResult
    func put(_ key: String, _ value: CGFloat) -> WecanParam {
        arraylist[key] = KeyValue("\(value)", true)
        return self
    }
    @discardableResult
    func put(_ key: String, _ value: WecanParam) -> WecanParam {
        value.parentParam = self
        arraylist[key] = KeyValue(value)
        return self
    }
    @discardableResult
    func put(_ key: String, _ value: String, _ isUnBase: Bool = false) -> WecanParam {
        if value == "" {
            return self
        }
        arraylist[key] = KeyValue(value, isUnBase)
        return self
    }
    @discardableResult
    func putIfNot(_ key: String, _ value: String, _ isUnBase: Bool = false) -> WecanParam {
        if value == "" || arraylist[key] != nil {
            return self
        }
        arraylist[key] = KeyValue(value, isUnBase)
        return self
    }
    @discardableResult
    func put(_ key: String, _ value: Bool) -> WecanParam {
        arraylist[key] = KeyValue("\(value)", true)
        return self
    }
    @discardableResult
    func getChild(_ key: String) -> WecanParam {
        if arraylist[key] == nil {
            let wecanParam = WecanParam()
            wecanParam.parentParam = self
            arraylist[key] = KeyValue(wecanParam)
        }
        return arraylist[key]!.wecanParam
    }
    @discardableResult
    func reNameChild(_ key: String, _ newKey: String) -> WecanParam {
        if arraylist.keys.contains(key) {
            let value = arraylist[key]
            arraylist.removeValue(forKey: key)
            arraylist[newKey] = value
        }
        return self
    }

    func getParent(_ key: String) -> WecanParam {
        if parentParam == nil {
            parentParam = WecanParam.init(key, self)
        }
        return parentParam

    }
    @discardableResult
    func add(_ wecanParam: WecanParam?) -> WecanParam {
        if wecanParam == nil {
            return self
        }
        arraylist.merge(wecanParam!.arraylist) { aa, ab in
            return aa
        }
        return self
    }

    func toJsonString() -> String {
        var value: String = ""
        if arraylist.count > 0 {
            for (key, keyValue) in arraylist {
                if keyValue.wecanParam != nil {
                    keyValue.value = keyValue.wecanParam.toJsonString()
                }
                if value == "" {
                    if keyValue.isUnBase {
                        value = "{\"" + key + "\":" + keyValue.value
                    } else {
                        value = "{\"" + key + "\":\"" + keyValue.value + "\""
                    }
                } else {
                    if keyValue.isUnBase {
                        value = value + ",\"" + key + "\":" + keyValue.value
                    } else {
                        value = value + ",\"" + key + "\":\"" + keyValue.value + "\""
                    }
                }
            }
            value = (value + "}").replacingOccurrences(of: "\"{", with: "{").replacingOccurrences(of: "}\"", with: "}")
        }
        return value
    }
    func toDic() -> [String: Any] {
        var value: [String: Any] = [:]
        if arraylist.count > 0 {
            for (key, keyValue) in arraylist {
                if keyValue.wecanParam != nil {
                    value[key] = keyValue.wecanParam.toDic()
                } else {
                    value[key] = keyValue.value
                }
            }
        }
        return value
    }
}


