//
//  QCViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/23.
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
import SCLAlertView

protocol ReceiveSearchViewDelegate : class {
    func showView(_ entity:ReceiveEntity?)
}

class ReceiveQueryViewController: UIViewController ,ReceiveTableViewCellDelegate,UITableViewDelegate,UITableViewDataSource {
    
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
    let transition = PopAnimator()
    var receive = Receive()
    fileprivate lazy var dataPicker : DatePickerView = {[weak self] in
        let contentH = kScreenH - kStatusBarH - kNavigationBarH - kTitleViewH - 250
        let pickerView = DatePickerView(frame:  CGRect(x:0, y: contentH, width: kScreenW, height: 250))
        pickerView.dataPickDelegate = self
        return pickerView
    }()
    
    lazy var searchView : SearchViewReceive = {[weak self] in
        let searchV = SearchViewReceive(frame:  CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavigationAndStatusH - 40))
        searchV.delegate = self
        //        searchV.parentController = viewController()
        return searchV
    }()
    
    func couponBtnClick(couponID: Int!, entity: ReceiveQueryItemEntity?) {
        print(couponID)
        print(entity?.toJSONString()!)
        if couponID == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let optVerifVC = storyboard.instantiateViewController(withIdentifier: "showCamera") as! CameraViewController
            let receive = Receive()
            receive.khjcno = entity?.khjcno
            receive.jcno =  entity?.jcno
            receive.finishman = nowUser?.username
            optVerifVC.entity = receive
            optVerifVC.mawb = entity?.khjcno
            viewController()?.navigationController!.pushViewController(optVerifVC, animated: true)
        }else if couponID == 2{
            var imagesResults :[PhotoEntity]? = []
            
            let items = RealmTools.objectsWithPredicate(object: Receive.self, predicate: NSPredicate(format: "area = '\(nowUser!.area)' AND khjcno = '\(entity!.khjcno)'")) as! [Receive]
            if items.count>0 {
                self.receive = items[0]
                for item in items {
                    imagesResults?.append(PhotoEntity(photoName: item.photoname!, status: item.status))
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
        }else{
            
            
        }
        
    }
    @IBOutlet weak var queryTable: UITableView!
    var tag = -1
    var index = 1
    var receiveViewModel : ReceiveViewModel?
    var datas = [ReceiveQueryItemEntity]()
    var searchView1 : SearchView?
    var deleteData = ["3天","4天","5天","6天","7天","8天","9天","10天","11天","12天","13天","14天","15天","16天","17天","18天","19天","20天","21天","22天","23天","24天","25天","26天","27天","28天","29天","30天","31天"]
    weak var delegate:ReceiveSearchViewDelegate?
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
        queryTable.register(UINib(nibName: "ReceiveTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiveTableViewCell")
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.queryTable.mj_header = header
        //上加载相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        self.queryTable!.mj_footer = footer
        //        print(viewController())
        ////        searchView.parentController = viewController()
        receiveViewModel = ReceiveViewModel(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchView.parentController = viewController()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiveTableViewCell")
            as! ReceiveTableViewCell
        cell.selectionStyle = .none
        cell.entity = datas[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let params : Parameters = ["guid" : datas[indexPath.row].guid]
        receiveViewModel!.requestStoreByGuid(params) { (entity:ReceiveEntity) in
            self.delegate?.showView(entity)
        }
    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
        print("下拉刷新.")
        index = 1
        self.queryTable.mj_footer!.resetNoMoreData()
        getData()
    }
    //底部上拉加载
    @objc func footerLoad(){
        self.queryTable.mj_footer!.endRefreshing()
        
        print("上拉加载.")
        //        index+=1
        //        print(index)
        //        getData()
        //结束刷新
    }
    
    func getData() {
        let param = WecanParam()
        param.getChild("adddate").put("begin", searchView.startDate.currentTitle!).put("end", searchView.endDate.currentTitle!);
        if searchView.jcno.text != "" {
            param.getChild("khjcno").put("like", searchView.jcno.text ?? "");
        }
        if searchView.mawb.text != "" {
            param.getChild("mawb").put("like", searchView.mawb.text ?? "");
        }
        if searchView.piece.text != "" {
            param.put("piece", searchView.piece.text ?? "");
        }
        
        if searchView.addman.text != "" {
            param.getChild("addman").put("like", searchView.addman.text ?? "");
        }
        let parameters : Parameters =  ["json":param.getParent("where").toJsonString()]
        //        let parameters : Parameters =  ["logExtraData":"APP,"+nowUser!.area,"pageSize":20,"index":index,"json":param.getParent("where").toJsonString()]
        
        receiveViewModel!.requestReceive(parameters) { [self] (queryEntitys : [ReceiveQueryItemEntity]) in
            print(queryEntitys.toJSONString())
            //结束刷新
            if index == 1{
                self.datas = queryEntitys
                
            }else{
                self.datas.append(contentsOf: queryEntitys)
            }
            self.queryTable.reloadData()
            //
            //            if queryEntitys.count<20{
            //                self.queryTable.mj_footer!.endRefreshingWithNoMoreData()
            //            }else{
            //
            //            self.queryTable.mj_footer!.endRefreshing()
            //            }
            self.queryTable.mj_footer!.endRefreshing()
            self.queryTable.mj_header!.endRefreshing()
            
        }
    }
}

extension ReceiveQueryViewController : DataPickDelegate,SearchDelegate{
    
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

extension ReceiveQueryViewController{
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
    func upload(data:[String])  {
//        SwiftNotice.wait()
        self.view!.makeToastActivity(.center)
        /*
         多文件上传
         */
        RxAlamofire.upload(multipartFormData: { [self] multipartFormData in
            multipartFormData.append((self.receive.groupid.data(using: String.Encoding.utf8))!, withName: "groupid")
            multipartFormData.append((self.receive.dom.data(using: String.Encoding.utf8))!, withName: "dom")
            multipartFormData.append((self.receive.source.data(using: String.Encoding.utf8))!, withName: "source")
            multipartFormData.append((self.receive.khjcno!.data(using: String.Encoding.utf8))!, withName: "khjcno")
            multipartFormData.append((self.receive.finishman!.data(using: String.Encoding.utf8))!, withName: "addman")
            multipartFormData.append((self.receive.jcno!.data(using: String.Encoding.utf8))!, withName: "jcno")
            for item in data{
                let file = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(item)
                multipartFormData.append(file, withName: item)
            }
        },urlRequest: try! urlRequest(.post,URL_IMAGE_DOCUMENT_JCNO)).subscribe{ uploadRequest in
            uploadRequest.uploadProgress(closure: { (progress) in
                debugPrint(progress.fractionCompleted, progress.completedUnitCount / 1024, progress.totalUnitCount / 1024)
            })
            uploadRequest.responseString { response in
                debugPrint(response)
//                SwiftNotice.clear()
                self.view.hideToastActivity()
                print(response.value!)
                let photoResults:[PhotoResult] = Mapper<PhotoResult>().mapArray(JSONString: response.value!)!
                print(photoResults.toJSONString())
                var re : [String] = []
                for item in photoResults{
                    if item.resultstatus == 0 {
                        RealmTools.updateObjectAttribute(object: Receive.self, value: ["photoname": item.filename!, "status": UPLOAD_STATUS_UPLOADED], update: .modified)
                    }else{
                        //                        re.append(item.filename!.replacingOccurrences(of: ".jpg", with: "") + item.resultmessage!)
                        re.append((RealmTools.object(Receive.self, primaryKey: item.filename!) as! Receive).khjcno! + item.resultmessage!.replacingOccurrences(of: "jobno", with: "工作号"))
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
