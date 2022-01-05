//
//  ResultEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/1.
//
import Foundation
import ObjectMapper

class ResultEntity : Mappable {
    var id: String?
    var resultstatus: Int?
    var resultmessage: String?
    var resultdic: Resultdic?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        resultstatus    <- map["resultstatus"]
        resultmessage      <- map["resultmessage"]
        resultdic  <- map["resultdic"]
    }
}


class Resultdic : Mappable {
    var loginname: String?
    var password: String?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        loginname    <- map["loginname"]
        password    <- map["password"]
    }
}

