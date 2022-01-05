//
//  ReceiveViewModel.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/2.
//

import Foundation
import RxAlamofire
import RxSwift
import ProgressHUD
import Alamofire
class ReceiveViewModel{
    var view : UIView?
    let disposeBag = DisposeBag()
    init(_ view: UIView?) {
        self.view = view
    }
    func request(_ parameters: Parameters? = nil, _ onNext : @escaping (_ queryEntitys :[QueryEntity]) -> ()) {
        var strUrl : String = ""
        if nowUser?.workspace == MARKER{
            strUrl = MARKER_OPERATE
        }else if nowUser?.workspace == CUSTOM{
            strUrl = CUSTOM_OPERATE
        }
       
//        ProgressHUD.show("请稍等",interaction: false)
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
//        SwiftNotice.wait(<#T##imageNames: Array<UIImage>##Array<UIImage>#>, timeInterval: <#T##Int#>)
        RxAlamofire.requestJSON(.get, strUrl,parameters:parameters)
            .map{$1}
            .mapArray(type: QueryEntity.self)
            .subscribe(onNext: { (queryEntitys: [QueryEntity]) in
                onNext(queryEntitys)
            },onError: { (error) in
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
            }).disposed(by: disposeBag)
    }
    
    //收货列表查询
    func requestReceive(_ parameters: Parameters? = nil, _ onNext : @escaping (_ queryEntitys :[ReceiveQueryItemEntity]) -> ()) {
//        ProgressHUD.show("请稍等",interaction: false)
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        RxAlamofire.requestJSON(.get, RECEIVE_OPERATE,parameters:parameters)
            .map{$1}
            .mapArray(type: ReceiveQueryItemEntity.self)
            .subscribe(onNext: { (queryEntitys: [ReceiveQueryItemEntity]) in
                onNext(queryEntitys)
            },onError: { (error) in
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
            }).disposed(by: disposeBag)
    }
    
    func requestStoreByGuid(_ parameters: Parameters? = nil, _ onNext : @escaping (_ queryEntity :ReceiveEntity) -> ()) {
//        ProgressHUD.show("请稍等",interaction: false)
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        RxAlamofire.requestJSON(.get, RECEIVE_OPERATE,parameters:parameters)
            .map{$1}
            .mapObject(type: ReceiveEntity.self)
            .subscribe(onNext: { (queryEntity: ReceiveEntity) in
                onNext(queryEntity)
            },onError: { (error) in
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
            }).disposed(by: disposeBag)
    }
    
}



