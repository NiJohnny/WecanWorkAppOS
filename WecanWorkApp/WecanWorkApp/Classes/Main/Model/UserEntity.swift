//
//  UserEntity.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/16.
//
import RealmSwift
import Foundation
public class UserEntity: Object {
    //    @objc dynamic var id = 0
    @objc dynamic var username : String?
    @objc dynamic var password: String?
    @objc dynamic var area: String = ""
    @objc dynamic var terminal: String?
    @objc dynamic var uploadphoto : String = "无限制"
    @objc dynamic var deletePhoto : String = "3天"
    @objc dynamic var authority: String?
    @objc dynamic var gid: Int = 0
    @objc dynamic var currentDay : String?
    @objc dynamic var tallyStartDate : String?
    @objc dynamic var tallyEndDate : String?
    @objc dynamic var labelStartDate : String?
    @objc dynamic var labelEndDate : String?
    @objc dynamic var outPutStartDate : String?
    @objc dynamic var outPutEndDate : String?
    @objc dynamic var UserAut : String?
    @objc dynamic var shd : String = ""
    @objc dynamic var fwsgys : String?
    @objc dynamic var gysid : Int = 0
    @objc dynamic var gyscardno : String?
    @objc dynamic var gysphone : String?
    @objc dynamic var gysarea : String?
    
    var ticket : String?
    var workspace = RECEIVE
    
//    required init(){
//        area = ""
//        uploadphoto = "无限制"
//        deletePhoto = "3天"
//        print("new User")
//    }
    func equals(user:UserEntity) {
        self.username = user.username
        self.password = user.password
        self.area = user.area
        self.terminal = user.terminal
        self.uploadphoto = user.uploadphoto
        self.deletePhoto = user.deletePhoto
        self.authority = user.authority
        self.gid = user.gid
        self.currentDay = user.currentDay
        self.tallyStartDate = user.tallyStartDate
        self.tallyEndDate = user.tallyEndDate
        self.labelStartDate = user.labelStartDate
        self.labelEndDate = user.labelEndDate
        self.outPutStartDate = user.outPutStartDate
        self.outPutEndDate = user.outPutEndDate
        self.UserAut = user.UserAut
        self.shd = user.shd
        self.fwsgys = user.fwsgys
        self.gysid = user.gysid
        self.gyscardno = user.gyscardno
        self.gysphone = user.gysphone
        self.gysarea = user.gysarea

        
    }
    func getLogExtraData()->String {
            return "APP," + area;
        }
    public override static func primaryKey() -> String? {
        return "username"
    }
    
    public override static func indexedProperties() -> [String] {
        return ["username"]
    }
    
}
