//
//  GysEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/8/19.
//

import Foundation
import ObjectMapper
class GysEntity: Mappable{
    var id: Int?
    var dcode: String?
    var dname: String?
    var area: String?
    var module: [Module]?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        dcode    <- map["dcode"]
        dname      <- map["dname"]
        area  <- map["area"]
        module  <- map["module"]
    }
    
}

class Module: Mappable{
    var mid: Int?
    var mcode: String?
    var mname: String?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        mid    <- map["mid"]
        mcode    <- map["mcode"]
        mname      <- map["mname"]
    }
    
}

