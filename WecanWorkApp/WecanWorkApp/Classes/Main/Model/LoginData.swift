//
//  LoginData.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/20.
//

import Foundation
import ObjectMapper

//{"resultstatus":0,"resultmessage":"登入成功","resultid":0,"ticket":"6A0F01385A45B68D83C9D4327D87B048A595760CC5E17610D0A63795120B674279E19AFAAA944B236FEAE127D7CF75B39B8C5F1F168994393434289B8928C3CD","name":"admin","area":"上海","depart":"","longmobile":"","englishname":"administrator","gid":-1,"type":-1,"logname":"admin","upwd":"7ea2c25e82bec665b1e3886c99ace1b9","threecode":"PVG","realarea":"上海","system":"ALL","email":"ITBroadcast@wecanintl.com","needudatepwdday":90,"needupdatepwd":false,"lastupdatepwd":null,"isapprover":false}
class LoginData: Mappable {
    //位置
    var resultstatus: Int?
    var ticket: String?
    var gid: Int = 0
    var resultmessage: String?
    var logname: String?
    var fwsgys: String?
    var gysid : Int?
    var gyscardno : String = ""
    var gysphone : String = ""
    var gysarea : String = ""
    required init?(map: Map){
    }
    
    //映射
    func mapping(map: Map) {
        resultstatus <- map["resultstatus"]
        ticket <- map["ticket"]
        gid <- map["gid"]
        resultmessage <- map["resultmessage"]
        logname <- map["logname"]
        fwsgys <- map["fwsgys"]
        gysid <- map["gysid"]
        gyscardno <- map["gyscardno"]
        gysphone <- map["gysphone"]
        gysarea <- map["gysarea"]
        
    }
}
