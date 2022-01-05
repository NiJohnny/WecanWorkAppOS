//
//  MarkerQueryViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/27.
//

import UIKit
import Alamofire
import MJRefresh
import SCLAlertView
import RxAlamofire
import RxCocoa
import RealmSwift
import RxSwift
import ObjectMapper
protocol SearchViewDelegate : class {
    func showView(_ entity:QueryEntity?)
}



class MarkerQueryViewController: UIViewController ,CouponTableViewCellDelegate,UITableViewDelegate,UITableViewDataSource {
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "showCamera":
            let zc = segue.destination as! CameraViewController
            zc.mawb = sender as? String
            
        default:
            break
        }
    }
    
    var marker = Marker()
    var custom = Custom()
    
    let disposeBag = DisposeBag()
    fileprivate lazy var dataPicker : DatePickerView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - 250
        let pickerView = DatePickerView(frame:  CGRect(x:0, y: contentH, width: kScreenW, height: 250))
        pickerView.dataPickDelegate = self
        return pickerView
    }()
    
    lazy var searchView : SearchView = {[weak self] in
        let searchV = SearchView(frame:  CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavigationAndStatusH - 40))
        searchV.delegate = self
        return searchV
    }()
    
    func couponBtnClick(couponID: Int, entity: QueryEntity, cell: QueryTableViewCell) {
        if couponID == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let optVerifVC = storyboard.instantiateViewController(withIdentifier: "showCamera") as! CameraViewController
            if nowUser?.workspace == MARKER {
                let marker = Marker()
                marker.mawb = entity.mawb
                marker.finishman = entity.nodeman
                marker.finishdate = entity.nodedate
                optVerifVC.entity = marker
                optVerifVC.mawb = entity.mawb  //传值
                viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
            }else if nowUser?.workspace == CUSTOM{
                let custom = Custom()
                custom.mawb = entity.mawb
                custom.finishman = entity.nodeman
                custom.finishdate = entity.nodeman
                optVerifVC.entity = custom
                optVerifVC.mawb = entity.mawb  //传值
                viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
            }
        }else if couponID == 2{
            var imagesResults :[PhotoEntity]? = []
            if nowUser?.workspace == MARKER {
                let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: NSPredicate(format: "area = '\(nowUser!.area)' AND mawb = '\(entity.mawb ?? "")'")) as! [Marker]
                if items.count>0 {
                    self.marker = items[0]
                    for item in items {
                        imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
                    }
                }
            }else if nowUser?.workspace == CUSTOM{
                let items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: NSPredicate(format: "area = '\(nowUser!.area)' AND mawb = '\(entity.mawb ?? "")'")) as! [Custom]
                if items.count>0 {
                    self.custom = items[0]
                    for item in items {
                        imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
                    }
                }
                
            }
            if imagesResults?.count == 0 {
//                SwiftNotice.showText("无照片请先拍照")
                self.view.makeToast("无照片请先拍照", position: .center)

                return
            }
            
            //开始选择照片，最多允许选择4张
            _ = self.presentPreviewPicker(uivc:viewController()!,maxSelected:100,imagesResults: imagesResults!) { (assets) in
                //结果处理
                print("共选择了\(assets.count)张图片，分别如下：")
                for asset in assets {
                    print(asset)
                    self.upload(data: assets)
                }
            }
            
//            //开始选择照片，最多允许选择4张
//            _ = self.presentPreviewPicker(maxSelected:100,imagesResults:imagesResults!) { [self] (assets) in
//                //结果处理
//                print("共选择了\(assets.count)张图片，分别如下：")
//                for asset in assets {
//                    print(asset)
//                    self.upload(data: assets)
//                }
//            }
        }else{
            let parameters: Parameters = ["logExtraData":nowUser!.getLogExtraData(),"mawb":entity.mawb ?? "" ,"czman":entity.nodeman ?? "","date":entity.nodedate ?? "","jobno":entity.jobno ?? "","type":2,"area":nowUser!.area]
            markerViewModel!.request(parameters) { [self] (resultEntity: ResultEntity) in
//                SwiftNotice.showText(resultEntity.resultmessage ?? "")
                if resultEntity.resultstatus == 0{
                    let index:IndexPath = queryTable.indexPath(for: cell)!
                    datas.remove(at: index.row)
                    queryTable.deleteRows(at: [index], with: .top)
                }
            }
        }
    }
    @IBOutlet weak var queryTable: UITableView!
    var tag = -1
    var index = 1
    var receiveViewModel : ReceiveViewModel?
    var markerViewModel : MarkerViewModel?
    var datas = [QueryEntity]()
    var searchView1 : SearchView?
    var deleteData = ["3天","4天","5天","6天","7天","8天","9天","10天","11天","12天","13天","14天","15天","16天","17天","18天","19天","20天","21天","22天","23天","24天","25天","26天","27天","28天","29天","30天","31天"]
    weak var delegate:SearchViewDelegate?
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部加载
    let footer = MJRefreshBackNormalFooter()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchView)
        self.view.addSubview(dataPicker)
        //去除单元格分隔线
        self.queryTable.separatorStyle = .none
        self.queryTable.delegate =  self
        self.queryTable.dataSource = self
        queryTable.register(UINib(nibName: "QueryTableViewCell", bundle: nil), forCellReuseIdentifier: "QueryTableViewCell")
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.queryTable.mj_header = header
        //上加载相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        self.queryTable!.mj_footer = footer
        
        receiveViewModel = ReceiveViewModel(self.view)
        markerViewModel = MarkerViewModel(self.view)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueryTableViewCell")
            as! QueryTableViewCell
        cell.entity = datas[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.showView(datas[indexPath.row])
    }
    
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        datas.remove(at: indexPath.row)
    //        tableView.deleteRows(at: [indexPath], with: .automatic)
    //    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
        print("下拉刷新.")
        index = 1
        self.queryTable.mj_footer!.resetNoMoreData()
        getData()
    }
    //底部上拉加载
    @objc func footerLoad(){
        print("上拉加载.")
        index+=1
        print(index)
        getData()
        //结束刷新
    }
    
    func getData() {
        
        let wecanParam = WecanParam()
        print(searchView.mawb.text)
        if searchView.mawb.text != ""{
            wecanParam.getChild("mawb").put("like", searchView.mawb.text ?? "");
        }
        wecanParam.getChild("area").put("in", nowUser!.area);
        wecanParam.getChild("hbrq").put("begin", (searchView.startDate.titleLabel?.text)!).put("end",  (searchView.endDate.titleLabel?.text)!);
        wecanParam.getChild("type").put("like", "2");
//        var s = wecanParam.getParent("where").toJsonString()
//        print(wecanParam.getParent("where").toJsonString())
        let parameters : Parameters =  ["logExtraData":"APP,"+nowUser!.area,"pageSize":20,"index":index,"json":wecanParam.getParent("where").toJsonString()]
        receiveViewModel!.request(parameters) { [self] (queryEntitys : [QueryEntity]) in
            print(queryEntitys.toJSONString())
            //结束刷新
            if index == 1{
                self.datas = queryEntitys
                
            }else{
                self.datas.append(contentsOf: queryEntitys)
            }
            self.queryTable.reloadData()
            
            if queryEntitys.count<20{
                self.queryTable.mj_footer!.endRefreshingWithNoMoreData()
            }else{
            
            self.queryTable.mj_footer!.endRefreshing()
            }
            self.queryTable.mj_header!.endRefreshing()
        }
    }
}

extension MarkerQueryViewController : DataPickDelegate,SearchDelegate{
    func searchData(tag: Int) {
        switch tag {
        case 0,1:
            self.tag=tag
            dataPicker.changView()
            break
        case 2:
            index = 1
            dataPicker.hid()
            getData()
            break
        default:
            break
        }
    }
    
    func dataPick(dataStr: String!) {
        switch self.tag {
        case 0:
            searchView.startDate.setTitle(dataStr, for: .normal)
            break
        case 1:
            searchView.endDate.setTitle(dataStr, for: .normal)
        default:
            break
        }
    }
    //获取父控制器
    func viewController() -> UIViewController? {
        var responder = self.next;
        repeat {
            if (responder?.isKind(of: UIViewController.classForCoder()))! {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        while((responder) != nil)
        return nil;
    }
}

extension MarkerQueryViewController{
    func showAlertView(assets:[String],title:String) {
        //自定义提示框样式
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 320,
            kWindowHeight: 600,
            showCircularIcon: false,
            disableTapGesture: true
        )
        let alert = SCLAlertView(appearance: appearance)
        let alertCheckView = AlertCheckView(frame: CGRect(x:0, y:0, width:280, height:180), datas: assets,isShowCheck: false)
        alert.customSubview = alertCheckView
        //添加确定按钮
        alert.addButton("确定") {}
        alert.showInfo(title, subTitle: "", closeButtonTitle: "取消",animationStyle: .bottomToTop)
    }
    
    //照片上传
    func upload(data:[String])  {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        //服务器路径
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            if nowUser?.workspace == MARKER{
                print("marker")
                multipartFormData.append((self.marker.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
                multipartFormData.append((self.marker.dom.data(using: String.Encoding.utf8))!, withName: "dom")
                multipartFormData.append((self.marker.source.data(using: String.Encoding.utf8))!, withName: "source")
                if self.marker.mawb == nil {
//                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "mawb")
                }else{
//                    multipartFormData.append((self.marker.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append((self.marker.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
                }
                multipartFormData.append((self.marker.remark.data(using: String.Encoding.utf8))!, withName: "remark")
                if self.marker.finishman == nil {
                    multipartFormData.append((nowUser!.username!.data(using: String.Encoding.utf8))!, withName: "addman")
                }else{
                    
                    multipartFormData.append((self.marker.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
                }
                multipartFormData.append((nowUser!.area.data(using: String.Encoding.utf8))!, withName: "area")
            }else if nowUser?.workspace == CUSTOM{
                print("custom")
                multipartFormData.append((self.custom.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
                multipartFormData.append((self.custom.dom.data(using: String.Encoding.utf8))!, withName: "dom")
                multipartFormData.append((self.custom.source.data(using: String.Encoding.utf8))!, withName: "source")
                if self.custom.mawb == nil {
//                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append(("".data(using: String.Encoding.utf8))!, withName: "mawb")
                }else{
//                    multipartFormData.append((self.custom.mawb!.data(using: String.Encoding.utf8))!, withName: "khjcno")
                    multipartFormData.append((self.custom.mawb!.data(using: String.Encoding.utf8))!, withName: "mawb")
                }
                
                multipartFormData.append((self.custom.remark.data(using: String.Encoding.utf8))!, withName: "remark")
                if self.custom.finishman == nil {
                    multipartFormData.append((nowUser!.username!.data(using: String.Encoding.utf8))!, withName: "addman")
                }else{
                    multipartFormData.append((self.custom.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
                }
                
                multipartFormData.append((nowUser!.area.data(using: String.Encoding.utf8))!, withName: "area")
            }
            for item in data{
                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item)
                multipartFormData.append(file, withName: item)
            }
        },urlRequest: try! urlRequest(.post,URL_IMAGE_DOCUMENT)).subscribe{ uploadRequest in
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
            })
            
            uploadRequest.responseString { response in
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                let photoResults:[PhotoResult] = Mapper<PhotoResult>().mapArray(JSONString: response.value!)!
                print(photoResults.toJSONString())
                var re : [String] = []
                for item in photoResults{
                    if item.resultstatus == 0 {
                        if nowUser?.workspace == MARKER {
                            RealmTools.updateObjectAttribute(object: Marker.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }else if nowUser?.workspace == CUSTOM{
                            RealmTools.updateObjectAttribute(object: Custom.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                        }
                    }else{
                        if nowUser?.workspace == MARKER {
                            re.append((RealmTools.object(Marker.self, primaryKey: item.filename!) as! Marker).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }else if nowUser?.workspace == CUSTOM{
                            re.append((RealmTools.object(Custom.self, primaryKey: item.filename!) as! Custom).mawb! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
                        }
                    }
                }
                if re.count != 0{
                    self.showAlertView(assets: re, title: "上传结果")
                }else{
//                    SwiftNotice.showText("上传成功")
                    self.view.makeToast("上传成功", position: .center)
                }
            }
        } onError: { (error) in
            print(error)
//            SwiftNotice.clear()
            self.view.hideToastActivity()
        } onCompleted: {
            print("finish")
        } onDisposed: {
            print("onDisposed")
        }
    }
}
