//
//  Common.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/27.
//
//print(realm.configuration.fileURL ?? "")
//let autEntitysaaa = autEntitys.removeDuplicateObject(filterKey: "autname") as! [AutEntity]//数组去重

import UIKit
public var AREA: [String] = []
let uploadData = ["无限制","仅wifi"]
let moduleDefault = ["报关操作","外场操作","制单操作","收货操作"]
let deleteData = ["3天","4天","5天","6天","7天","8天","9天","10天","11天","12天","13天","14天","15天","16天","17天","18天","19天","20天","21天","22天","23天","24天","25天","26天","27天","28天","29天","30天","31天"]
public var nowUser : UserEntity?
let APP_NAME = "唯凯操作APP"

//let WORKSPACE_RECEIVE = 0
//let WORKSPACE_CUSTOM = 1
//let WORKSPACE_MARKER = 2




// 照片上传状态
let UPLOAD_STATUS_UNUPLOADED = 0
let UPLOAD_STATUS_UPLOADED = 1

let TERMINAL = 0
let TRUCK = 1;//车队
let WAREHOUSE = 2
let TRUCK_OTHER_PLACE = 3;//卡车
let CUSTOM = 4//报关
let MARKER = 5//制单
let RECEIVE = 6//收货
public let MAIN_HEIGHT = UIScreen.main.bounds.height
public let MAIN_WIDTH = UIScreen.main.bounds.width

let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height
//状态栏高度
let kStatusBarH = UIApplication.shared.statusBarFrame.height;
//导航栏高度
let kNavigationBarH : CGFloat = 44

let kNavigationAndStatusH = (kStatusBarH + kNavigationBarH)
//tabbar高度
let kTabBarH : CGFloat = (kStatusBarH == 44 ? 83 : 49)
//顶部的安全距离
let kTopSafeAreaH = (kStatusBarH - 20)
//底部的安全距离
let kBottomSafeAreaH : CGFloat = (kTabBarH - 49)




//获取Documents目录的2种方法
let kPhotoPath = NSHomeDirectory() + "/Documents"
//let KPhotoPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

let FORMAT_DATE = "YYYY-MM-dd HH:mm"
let URL_BASE = "http://erp.wecanintl.com/"
//let URL_BASE = "http://192.168.98.178/"
//let URL_BASE = "http://192.168.0.113/"



let URL_PUBLIC = URL_BASE + "PublicWebApi/api/"
let URL_TT = URL_BASE + "StoreTerminalWebApi/api/"
let USER_LOGIN = URL_PUBLIC + "UserLogin"
let USER_AUT = URL_PUBLIC + "UserAut"
let URL_WAREHOUSE = URL_PUBLIC + "PubWarehouse"
let URL_TERMINAL = URL_PUBLIC + "PubTjjd"
let USER_RESETPW = URL_PUBLIC + "UserPwd"//更改密码

let WTDW = URL_PUBLIC + "PubCustomG"
let PUBTYPECODE = URL_PUBLIC + "PubTypeCode"
//let MARKER_CANCEL = URL_TT + "MawbZd"
let USER_CAP = URL_PUBLIC + "PubMessageSms"//获取验证码
let RECEIVE_OPERATE = URL_TT + "StoreVolume"
let CUSTOM_OPERATE = URL_TT + "Bg"//报关保存type=1/取消type=2
let MARKER_OPERATE = URL_TT + "MawbZd"//制单保存type=1/取消type=2

let URL_IMAGE = URL_BASE + "ImageWebApi/api/"
let IMAGE = URL_IMAGE + "postimage"
let URL_IMAGE_DOCUMENT = URL_IMAGE + "StoreAppDoc"//报关制单照片上传
let URL_IMAGE_DOCUMENT_JCNO = URL_IMAGE + "StoreAppImg"//收货照片上传
let URL_GYS = URL_TT + "WzGysRegister"//获取供应商
let URL_MODIFY_GYS = URL_TT + "WzGysModify"//修改

public var REGISTER_NAME = ""
