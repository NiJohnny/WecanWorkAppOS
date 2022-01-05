//
//  AnyTool.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/23.
//

import Foundation


class AnyTool {
    
    class func getShd(terminalList:[TerminalEntity],warehouseList:[WarehouseEntity]) -> [String]?{
        var shdList : [String] = []
        for terminalEntity in terminalList {
            shdList.append(terminalEntity.cname!)
        }
        for warehouseEntity in warehouseList {
            shdList.append(warehouseEntity.storename!)
        }
        return shdList
    }
    
    class func getUploadUrl() -> String{
        if nowUser?.workspace == RECEIVE{
            return URL_IMAGE_DOCUMENT_JCNO
        }else if nowUser?.workspace == CUSTOM || nowUser?.workspace == MARKER{
            return URL_IMAGE_DOCUMENT
        }
        return ""
    }
    
    class func getString(str : String?) -> String{
        if let stringCount = str?.count, stringCount > 0 {
            return str!
        }
        else{
            return ""
        }
    }
    
   
    
}
