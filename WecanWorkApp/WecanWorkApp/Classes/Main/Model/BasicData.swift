//
//  AllWtdwEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/27.
//

import ObjectMapper
import RealmSwift
import Foundation
import SwiftDate
class AllWtdwEntity: Mappable{
    var wtkhname: String?
    var wtkhcode: String?
    var khjcno: String?
    var timestamp: Int?        // User对象
    var usr_status : Int?
    var iscommit : Int?
    var isfcommit : Int?
    var fusr_status : Int?
    var enddate: String?
    var area: String?
    var system: String?
    var wtdw: WtdwEntity?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        wtkhname    <- map["wtkhname"]
        wtkhcode    <- map["wtkhcode"]
        khjcno      <- map["khjcno"]
        timestamp  <- map["timestamp"]
        usr_status     <- map["usr_status"]
        //        iscommit    <- (map["iscommit"], DateTransform())
        iscommit    <- (map["iscommit"])
        isfcommit       <- map["isfcommit"]
        fusr_status  <- map["fusr_status"]
        enddate  <- map["enddate"]
        area  <- map["area"]
        system  <- map["system"]
        //        wtdw  <- map["wtdw"]
        
    }
    
    func  getWtdwEntity() -> WtdwEntity {
        var wtdwEntity = WtdwEntity()
        wtdwEntity.wtkhcode = wtkhcode
        wtdwEntity.wtkhname = wtkhname
        wtdwEntity.khjcno = khjcno
        wtdwEntity.timestamp = timestamp!
        wtdwEntity.area = area;
        if (usr_status == 1 && iscommit == 2 && isfcommit == 2 && fusr_status == 1
                &&  enddate==("1900-01-01T00:00:00") || (enddate!.replacingOccurrences(of: "T", with: " ")).toDate()!.date>DateTool.getCurrentDate("yyyy-MM-dd HH:mm:ss").toDate()!.date)
        {
            wtdwEntity.groupid = "12"
        } else {
            wtdwEntity.groupid = "1"
        }
        return wtdwEntity
    }
}

class WtdwEntity: Object {
    //    @objc dynamic var id: Int = 0
    @objc dynamic var wtkhcode: String?
    @objc dynamic var wtkhname: String?
    @objc dynamic var khjcno: String?
    @objc dynamic var groupid: String?
    @objc dynamic var area: String?
    @objc dynamic var timestamp: Int = 0
}



class TypecodeEntity: Object, Mappable {
    
    //    @Index
    //        public int groupid;
    //        public String typename;
    //        public String ready01;
    //        public String ready02;
    //        @Transient
    //        public String ready03;
    //        @Transient
    //        public String ready04;
    //        @Transient
    //        public int ready12;
    
    @objc dynamic var id = 0
    @objc dynamic var groupid = 0
    @objc dynamic var typename: String?
    @objc dynamic var ready01: String?
    @objc dynamic var ready02: String?
    var ready03: String?
    var ready04: String?
    var ready12: String?
    
    override static func primaryKey() -> String? {
            return "id"
        }
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        groupid <- map["groupid"]
        typename <- map["typename"]
        ready01 <- map["ready01"]
        ready02 <- map["ready02"]
        ready03 <- map["ready03"]
        ready04 <- map["ready04"]
        ready12 <- map["ready12"]
    }
}

class AutEntity: Object, Mappable {
    @objc dynamic var autcode : String?
    @objc dynamic var autname: String?
    @objc dynamic var auturl: String?
    @objc dynamic var type: Int=0
    @objc dynamic var module: String?
    @objc dynamic var aorder: Int=0
    @objc dynamic var morder: Int=0
    @objc dynamic var node: Int=0
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        autcode <- map["autcode"]
        autname <- map["autname"]
        auturl <- map["auturl"]
        type <- map["type"]
        module <- map["module"]
        aorder <- map["aorder"]
        morder <- map["morder"]
        node <- map["node"]
    }
}
//{"storeid":1,"isjg":"0","storename":"晨阳路KN库","remark":"","area":"上海"}
class WarehouseEntity: Object, Mappable {
    @objc dynamic var storeid : Int = 0
    @objc dynamic var isjg: Int = 0
    @objc dynamic var storename: String?
    @objc dynamic var area: String?
   
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        storeid <- map["storeid"]
        isjg <- map["isjg"]
        storename <- map["storename"]
        area <- map["area"]
    }
}
//{"id":184,"cname":"深圳货站01","sfg":"CAN","area":"上海"}
class TerminalEntity: Object, Mappable {
    @objc dynamic var id = 0
    @objc dynamic var area : String?
    @objc dynamic var cname: String?
    @objc dynamic var ready01: String?
   
    override static func primaryKey() -> String? {
            return "id"
        }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        area <- map["area"]
        cname <- map["cname"]
        ready01 <- map["ready01"]
    }
}


class Marker: Object {
    @objc dynamic var id = 0
    @objc dynamic var mawb : String?
    @objc dynamic var finishman: String?
    @objc dynamic var finishdate: String?
    @objc dynamic var status = UPLOAD_STATUS_UNUPLOADED
    @objc dynamic var dom = "kcdoc"
    @objc dynamic var source = "总运单"
    @objc dynamic var setTimestamp = Int(Date().timeIntervalSince1970)
    @objc dynamic var photoname: String?
    @objc dynamic var groupid = "122"
    @objc dynamic var remark = "app"
    @objc dynamic var area = nowUser?.area
    @objc dynamic var jobno : String?
    override static func primaryKey() -> String? {
            return "photoname"
        }
}
class Custom: Object {
    @objc dynamic var id = 0
    @objc dynamic var mawb : String?
    @objc dynamic var finishman: String?
    @objc dynamic var finishdate: String?
    @objc dynamic var status = UPLOAD_STATUS_UNUPLOADED
    @objc dynamic var dom = "kcdoc"
    @objc dynamic var source = "报关资料"
    @objc dynamic var setTimestamp = Int(Date().timeIntervalSince1970)
    @objc dynamic var photoname: String?
    @objc dynamic var groupid = "122"
    @objc dynamic var remark = "app"
    @objc dynamic var area = nowUser?.area
    @objc dynamic var jobno : String?
    override static func primaryKey() -> String? {
            return "photoname"
        }
}
class Receive: Object {
    @objc dynamic var id = 0
    @objc dynamic var mawb : String?
    @objc dynamic var finishman: String?
    @objc dynamic var finishdate: String?
    @objc dynamic var status = UPLOAD_STATUS_UNUPLOADED
    @objc dynamic var dom = "kcck"
    @objc dynamic var source = "入库"
    @objc dynamic var setTimestamp = Int(Date().timeIntervalSince1970)
    @objc dynamic var photoname: String?
    @objc dynamic var groupid = "121"
    @objc dynamic var remark = "app"
    @objc dynamic var area = nowUser?.area
    @objc dynamic var jobno : String?
    @objc dynamic var khjcno : String?
    @objc dynamic var jcno : String?
    override static func primaryKey() -> String? {
            return "photoname"
        }
}


class PhotoResult: Mappable{
    var resultstatus: Int?
    var resultmessage: String?
    var resultid: Int?
    var filename: String?        // User对象
    var msg : String?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        resultstatus    <- map["resultstatus"]
        resultmessage    <- map["resultmessage"]
        resultid      <- map["resultid"]
        filename  <- map["filename"]
        msg     <- map["msg"]
    }
    
}


class PhotoEntity{
    var photoName : String?
    var status : Int?
    
    
    init(photoName : String, status:Int) {
        self.photoName = photoName
        self.status = status
    }
}

//ObjectMapper 同 Realm 是可以一起使用的。我们可以使用 ObjectMapper 生成 Realm 模型，下面是一个简单的类结构代码：
//class Model: Object, Mappable {
//    dynamic var name = ""
//
//    required convenience init?(map: Map) {
//        self.init()
//    }
//
//    func mapping(map: Map) {
//        name <- map["name"]
//    }
//}
