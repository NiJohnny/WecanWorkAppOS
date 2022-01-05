//
//  MarkerViewModel.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/29.
//

import Foundation
import RxAlamofire
import Alamofire
import RxSwift
import ProgressHUD

class  MarkerViewModel{
    let disposeBag = DisposeBag()
    var view : UIView?
    init(_ view: UIView?) {
        self.view = view
    }
    
     func request(_ parameters: Parameters? = nil, _ onNext : @escaping (_ resultEntity :ResultEntity) ->()) {
        var url : String? = nil
        if nowUser?.workspace == MARKER {
            url = MARKER_OPERATE
        }else if nowUser?.workspace == CUSTOM{
            url = CUSTOM_OPERATE
        }
//        ProgressHUD.show("请稍等",interaction: false)
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)

        RxAlamofire.requestJSON(.put, url!,parameters:parameters,encoding:JSONEncoding.default)
            .map{$1}
            .mapObject(type: ResultEntity.self)
            .debug()
            .subscribe(onNext: { (resultEntity: ResultEntity) in
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
               onNext(resultEntity)
            },onError: { (error) in
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
                self.view!.hideToastActivity()
                print("请求失败！错误原因：", error)
            }, onCompleted: {
//                ProgressHUD.dismiss()
//                SwiftNotice.clear()
            }).disposed(by: disposeBag)
    }
    
}

