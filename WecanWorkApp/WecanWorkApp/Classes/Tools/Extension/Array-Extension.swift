//
//  Array-Extension.swift
//  WecanWorkApp
//
//  Created by erp on 2021/10/13.
//

import Foundation
import UIKit

extension Array {
    func removeDuplicateObject(filterKey: String) -> [Any]? {
        var resArray = [Any]()
        var recordDic = [String:String]()
        for item in self {
            let valuesMirr = Mirror(reflecting: item)
            for case let (key,value) in valuesMirr.children{
                if key == filterKey{
                    if recordDic[value as! String] == nil {
                        resArray.append(item)
                        recordDic[value as! String] = "1"
                    }
                    break
                }
                
            }
            
        }
        return resArray
    }
    
    
}
