//
//  UserdefaultsTools.swift
//  WecanWorkApp
//
//  Created by erp on 2021/5/27.
//

import Foundation
///用UserDefaults保存modifyDate
func setUserdefaults(str:Any,forKey:String){
    let userdefaults = UserDefaults.standard
    userdefaults.set(str, forKey: forKey)
}
///获取UserDefaults保存的modifyDate
func getUserdefaults(forKey:String,nilValue:String) -> String{
    let userdefaults = UserDefaults.standard
    return userdefaults.string(forKey: forKey)==nil ? nilValue: userdefaults.string(forKey: forKey)!
}
func getUserdefaults(forKey:String,nilValue:Int) -> Int{
    let userdefaults = UserDefaults.standard
    return userdefaults.integer(forKey: forKey) == 0 ? nilValue: userdefaults.integer(forKey: forKey)
}
