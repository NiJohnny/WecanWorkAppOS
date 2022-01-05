//
//  QueryEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/2.
//

import Foundation
import ObjectMapper



class QueryEntity: Mappable{
    var area: String?
    var boguid: Int?
    var jobno: String?
    var guid: Int?
    var mawb: String?
    var hbh: String?
    var hbrq: String?
    var qfsj: String?
    var dzstatus: Int?
//    var bgstatus: Object?
    var sfg: String?
    var mdg: String?
    var servicecode: String?
    var nodecode: String?
    var nodeman: String?
    var nodedate: String?
    var nodename: String?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        area    <- map["area"]
        boguid    <- map["boguid"]
        jobno      <- map["jobno"]
        guid  <- map["guid"]
        mawb     <- map["mawb"]
        hbh    <- (map["hbh"])
        hbrq       <- map["hbrq"]
        qfsj  <- map["qfsj"]
        dzstatus  <- map["dzstatus"]
        sfg  <- map["sfg"]
        mdg  <- map["mdg"]
        servicecode  <- map["servicecode"]
        nodecode  <- map["nodecode"]
        nodeman  <- map["nodeman"]
        nodedate  <- map["nodedate"]
        nodename  <- map["nodename"]
    }

}
