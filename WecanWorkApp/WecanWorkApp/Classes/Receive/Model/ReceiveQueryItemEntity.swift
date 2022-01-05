//
//  ReceiveQueryItemEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/27.
//

import Foundation
import ObjectMapper

class ReceiveQueryItemEntity: Mappable{
    var khjcno :String = ""
    var jcdate :String = ""
    var piece :Int?
    var weight :Double?
    var volume :Double?
    var hwstatus :Int?
    var addman :String = ""
    var guid :String = ""
    var jcno :String = ""
    
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        khjcno    <- map["khjcno"]
        jcdate    <- map["jcdate"]
        piece      <- map["piece"]
        weight     <- map["weight"]
        volume    <- (map["volume"])
        hwstatus       <- map["hwstatus"]
        addman  <- map["addman"]
        guid  <- map["guid"]
        jcno  <- map["jcno"]
        
    }
}
class ReceiveEntity: Mappable{
    var goodsRemark :String = ""
    var wtkhname :String = ""
    var jcno :String = ""
    var guid :String = ""
    var area :String = nowUser!.area
    var goodstp :String = ""
    var jcdate :String = ""
    var khjcno :String = ""
    var piece :Int?
    var weight :Double?
    var volume :Double?
    var goodstype :String = ""
    var goodsMark :String = ""
    var sfdj :String = ""
    var sfws :String = ""
    var bzlx :String = ""
    var ycqk :String = ""
    var sfpz :String = ""
    var fhlx :String = ""
    //    var gfzl :String = ""
    var pm :String = ""
    var shdw :String = ""
    var cph :String = ""
    var driverphone :String = ""
    var dzlx :String = ""
    var dzremark :String = ""
    var ponumber :String = ""
    var sanumber :String = ""
    var czman :String = ""
    var logExtraData :String = ""
    
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        goodsRemark    <- map["goodsRemark"]
        wtkhname    <- map["wtkhname"]
        jcno      <- map["jcno"]
        guid  <- map["guid"]
        area     <- map["area"]
        goodstp    <- (map["goodstp"])
        jcdate       <- map["jcdate"]
        khjcno  <- map["khjcno"]
        piece  <- map["piece"]
        weight  <- map["weight"]
        volume  <- map["volume"]
        goodstype  <- map["goodstype"]
        goodsMark  <- map["goodsMark"]
        sfdj  <- map["sfdj"]
        sfws  <- map["sfws"]
        bzlx  <- map["bzlx"]
        ycqk  <- map["ycqk"]
        sfpz  <- map["sfpz"]
        fhlx  <- map["fhlx"]
        pm  <- map["pm"]
        shdw  <- map["shdw"]
        cph  <- map["cph"]
        driverphone  <- map["driverphone"]
        dzlx  <- map["dzlx"]
        dzremark  <- map["dzremark"]
        ponumber  <- map["ponumber"]
        sanumber  <- map["sanumber"]
        czman  <- map["czman"]
        logExtraData  <- map["logExtraData"]
    }
    func clear()  {
        goodsRemark  = ""
        wtkhname  = ""
        jcno  = ""
        guid  = ""
        area  = nowUser?.area ?? ""
        goodstp  = ""
        jcdate  = ""
        khjcno  = ""
        piece = 0
        weight = 0
        volume = 0
        goodstype  = ""
        goodsMark = ""
        sfdj = ""
        sfws  = ""
        bzlx = ""
        ycqk = ""
        sfpz = ""
        fhlx = ""
        //    var gfzl :String = ""
        pm = ""
        shdw = ""
        cph = ""
        driverphone = ""
        dzlx = ""
        dzremark = ""
        ponumber = ""
        sanumber = ""
        czman = ""
        logExtraData = ""
    }
}
