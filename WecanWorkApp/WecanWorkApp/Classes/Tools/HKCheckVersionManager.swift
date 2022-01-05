//
//  HKCheckVersionManager.swift
//  ExaminedApprovedos
//
//  Created by erp on 2019/3/27.
//  Copyright © 2019 erp. All rights reserved.
//

import UIKit
class HKCheckVersion {
    static let manager = HKCheckVersionManager()
    private init() {
    }
}
class HKCheckVersionManager {
    private var appId: String = ""
    private var localVersion_Float: Float = 0
    /// app版本更新检测
    ///
    /// - Parameter appId: apple ID - 开发者帐号对应app处获取
    func CheckVersion(appId: String, _ toStopUpdate: @escaping (() -> Void) = { }) {
        print("1")
        self.appId = appId
        //获取appstore上的最新版本号
        let appUrl = URL.init(string: "http://itunes.apple.com/cn/lookup?id=" + appId)
        let appMsg = try? String.init(contentsOf: appUrl!, encoding: .utf8)
        if appMsg == nil {
            toStopUpdate()
            return
        }
//        mlog(appMsg)
        let appMsgDict: NSDictionary = getDictFromString(jString: appMsg!)
        let appResultsArray: NSArray = (appMsgDict["results"] as? NSArray)!
        let appResultsDict: NSDictionary = appResultsArray.lastObject as! NSDictionary
        let appStoreVersion: String = appResultsDict["version"] as! String
        let appStoreVersion_Float: Float = Float(appStoreVersion)!

        //获取当前手机安装使用的版本号
        let localVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        localVersion_Float = Float(localVersion)!

//        //用户是否设置不再提示
//        let userDefaults = UserDefaults.standard
//        let res = userDefaults.bool(forKey: "NO_ALERt_AGAIN_\(localVersion_Float)")
        //appstore上的版本号大于本地版本号 - 说明有更新
//        if appStoreVersion_Float > localVersion_Float && !res {
        if appStoreVersion_Float > localVersion_Float {
            let alertC = UIAlertController.init(title: "版本更新了", message: "是否前往更新", preferredStyle: .alert)
            let yesAction = UIAlertAction.init(title: "去更新", style: .default, handler: { (handler) in
                self.updateApp()
            })
            let noAction = UIAlertAction.init(title: "下次再说", style: .cancel, handler: { (handler) in
                toStopUpdate()
            })
//            let cancelAction = UIAlertAction.init(title: "不再提示", style: .default, handler: { (handler) in
//                self.noAlertAgain()
//                toStopUpdate()
//            })
            alertC.addAction(yesAction)
            alertC.addAction(noAction)
//            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        } else {
            toStopUpdate()
        }

    }
    //去更新
    private func updateApp() {
        let updateUrl: URL = URL.init(string: "http://itunes.apple.com/app/id" + appId)!
        UIApplication.shared.open(updateUrl, options: [:], completionHandler: nil)
    }

    //不再提示
//    private func noAlertAgain() {
//        let userDefaults = UserDefaults.standard
//        userDefaults.set(true, forKey: "NO_ALERt_AGAIN_\(localVersion_Float)")
//        userDefaults.synchronize()
//    }

    //JSONString转字典
    private func getDictFromString(jString: String) -> NSDictionary {
        let jsonData: Data = jString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }

}

//johnny添加的代码
extension HKCheckVersionManager{
    func CheckVersion(appId: String) -> Bool {
        print("2")
        let appUrl = URL.init(string: "http://itunes.apple.com/cn/lookup?id=" + appId)
        let appMsg = try? String.init(contentsOf: appUrl!, encoding: .utf8)
        if appMsg == nil {
            
            return false
        }
        //        mlog(appMsg)
        let appMsgDict: NSDictionary = getDictFromString(jString: appMsg!)
        let appResultsArray: NSArray = (appMsgDict["results"] as? NSArray)!
        let appResultsDict: NSDictionary = appResultsArray.lastObject as! NSDictionary
        let appStoreVersion: String = appResultsDict["version"] as! String
        let appStoreVersion_Float: Float = Float(appStoreVersion)!
        
        //获取当前手机安装使用的版本号
        let localVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        localVersion_Float = Float(localVersion)!
        
        //        //用户是否设置不再提示
        //        let userDefaults = UserDefaults.standard
        //        let res = userDefaults.bool(forKey: "NO_ALERt_AGAIN_\(localVersion_Float)")
        //appstore上的版本号大于本地版本号 - 说明有更新
        //        if appStoreVersion_Float > localVersion_Float && !res {
        if appStoreVersion_Float > localVersion_Float {
            
            return true
        }
        return false
    }
    
}
