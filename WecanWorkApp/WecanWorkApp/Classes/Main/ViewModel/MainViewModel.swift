//
//  MainViewModel.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/20.
//

import Foundation
import RxAlamofire
import RxSwift
//import ProgressHUD
import Alamofire
class MainViewModel{
    let disposeBag = DisposeBag()
    var view : UIView?
    
    init(_ view: UIView?) {
        self.view = view
    }
    func login(_ uname:String,_ pwd:String, _ onNext : @escaping (_ data :LoginData) -> ()) {
        let parameters : Parameters =  ["usrname": uname,"pwd": pwd]
//        ProgressHUD.show("登录中请稍等",interaction: false)
        self.view!.makeToastActivity(.center)
        RxAlamofire.requestJSON(.get,USER_LOGIN,parameters: parameters)
            .map{$1}
            .mapObject(type: LoginData.self)
            .subscribe(onNext: { (loginData: LoginData) in
                print(loginData.toJSONString())
                onNext(loginData)
            },onError: { (error) in
//                ProgressHUD.dismiss()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
                self.view!.hideToastActivity()
            }).disposed(by: disposeBag)
        
        //                        requestString(.get, USER ,parameters: parameters)
        //                            .subscribe(onNext: {
        //                                response, data in
        //                                //数据处理
        //                                print("返回的数据是：", data)
        //                            }).disposed(by: disposeBag)
    }
    
    func getUserAut(_ uname: String, _ onNext : @escaping (_ queryEntitys :[AutEntity]) -> ()) {
//        ProgressHUD.show("获取权限中",interaction: false)
        self.view!.makeToastActivity(.center)
        let parameters : Parameters =  ["logname": uname,"appname": APP_NAME,"area": "上海","scope": 1]
        RxAlamofire.requestJSON(.get, USER_AUT,parameters:parameters)
            .map{$1}
            .mapArray(type: AutEntity.self)
            .subscribe(onNext: {(autEntitys: [AutEntity]) in
                //                print(autEntitys.toJSONString())
                onNext(autEntitys)
            },onError: { (error) in
//                ProgressHUD.dismiss()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
                self.view!.hideToastActivity()
            }).disposed(by: disposeBag)
    }
    
    func getGys(area: String, _ onNext : @escaping (_ gysEntitys :[GysEntity]) ->()) {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        let parameters : Parameters =  ["area": area]
        RxAlamofire.requestJSON(.get, URL_GYS,parameters:parameters)
            .map{$1}
            .mapArray(type: GysEntity.self)
            .debug()
            .subscribe(onNext: { (entitys: [GysEntity]) in
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
                onNext(entitys)
            },onError: { (error) in
                //                ProgressHUD.dismiss()
                self.view!.hideToastActivity()
//                SwiftNotice.clear()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
                self.view!.hideToastActivity()
                //                ProgressHUD.dismiss()
                //                SwiftNotice.clear()
            }).disposed(by: disposeBag)
    }
}
