//
//  CheckMoreViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/17.
//

import UIKit

struct CheckModel {
    var modelTitle:String
    var values:[String]
}

struct CheckValues {
    var title:String
}

class CheckMoreViewController: UIViewController {
    let user = RealmTools.object(UserEntity.self, primaryKey: nowUser!.username!) as! UserEntity
    var datas : String?
    //    CheckModel(modelTitle: "区域",values: ["上海","北京","昆明","成都","重庆","厦门","广州","杭州","宁波","海外部","武汉"]),
//    CheckModel(modelTitle: "收货地",values: ["1期货站","2期货站","3期货站","UPS","2期上航","3期上航","物流","FM货栈","虹桥货栈","空港物流"])
    @IBOutlet weak var tableView: UITableView!
    var models : [CheckModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print(datas)
        setTableVIew()
        let typecodeEntitys = RealmTools.objectsWithPredicate(object: TypecodeEntity.self, predicate: NSPredicate(format: "groupid = 53")) as! [TypecodeEntity]
//        let areaModel = CheckModel(modelTitle: "区域", values: getArea(typecodeEntitys)!)
        let areaModel = CheckModel(modelTitle: "区域", values: AREA)
       
        
        
        let terminalList = RealmTools.objectsWithPredicate(object: TerminalEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [TerminalEntity]
        let warehouseList = RealmTools.objectsWithPredicate(object: WarehouseEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [WarehouseEntity]
//        let terminalList = RealmTools.objectsWithPredicate(object: TerminalEntity.self, predicate: NSPredicate(format: "ready01 = '上海'")) as! [TerminalEntity]
//        let warehouseList = RealmTools.objectsWithPredicate(object: WarehouseEntity.self, predicate: NSPredicate(format: "area = '上海'")) as! [WarehouseEntity]
        let shdModel = CheckModel(modelTitle: "收货地", values: AnyTool.getShd(terminalList: terminalList, warehouseList: warehouseList)!)
        models.append(areaModel)
        models.append(shdModel)
        
    }
    

    func getArea(_ typecodeEntitys:[TypecodeEntity]) -> [String]? {
        var areas : [String] = []
        
        for typecodeEntity in typecodeEntitys {
            areas.append(typecodeEntity.typename!)
        }
        return areas
    }
    
    func setTableVIew(){
        //设置tableView代理
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        
        //去除单元格分隔线
        self.tableView!.separatorStyle = .none
        
        //创建一个重用的单元格
        self.tableView!.register(UINib(nibName:"MyCheckTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"myCheckTableCell")
        
        //设置estimatedRowHeight属性默认值
        self.tableView!.estimatedRowHeight = 44.0
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.tableView!.rowHeight = UITableView.automaticDimension
    }
    
}

// MARK:- 遵守UItableview协议
extension CheckMoreViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    //返回表格行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    //创建各单元显示内容(创建参数indexPath指定的单元）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCheckTableCell")
            as! MyCheckTableViewCell
        cell.delegate = self
        //下面这两个语句一定要添加，否则第一屏显示的collection view尺寸，以及里面的单元格位置会不正确
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        //重新加载单元格数据
        //        cell.reloadData(title:models[indexPath.row].modelTitle,
        //                        images: models[indexPath.row])
        cell.reloadData(title: models[indexPath.row].modelTitle, values: models[indexPath.row].values)
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK:- 遵守ModelClickDelegateDelegate协议
extension CheckMoreViewController : CheckValueDelegateDelegate {
    func check(selectedValue value: String) {
        print(value)
//        if value == nowUser?.area || value == nowUser?.shd{
//            return
//        }
        
        let area = models[0].values.firstIndex(of: value)
        if area != nil {
            RealmTools.updateWithTranstion { (true) in
                user.area = value
                nowUser?.area = value
                user.shd = ""
                nowUser?.shd = ""
                let terminalList1 = RealmTools.objectsWithPredicate(object: TerminalEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [TerminalEntity]
                let warehouseList1 = RealmTools.objectsWithPredicate(object: WarehouseEntity.self, predicate: NSPredicate(format: "area = '\((nowUser?.area)!)'")) as! [WarehouseEntity]
                models[1].values = AnyTool.getShd(terminalList: terminalList1, warehouseList: warehouseList1)!
//                if models[1].values.count == 0{
//                    user.shd = ""
//                }
                self.tableView.reloadData()
            }
        }
        let shd = models[1].values.firstIndex(of: value)
        if shd != nil {
            RealmTools.updateWithTranstion { (true) in
                user.shd = value
                nowUser?.shd = value
            }
        }
        
//        let index = values.firstIndex(of: nowUser!.area)
//        let index1 = values.firstIndex(of: nowUser!.shd)
        
        //        //更具定义的Segue Indentifier进行跳转()点击连线
        //                self.performSegue(withIdentifier: "model", sender: value)
    }
}




