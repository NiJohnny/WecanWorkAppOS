//
//  CheckViewController.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/10.
//
//let person = self.realm.object(ofType: UsersEntity.self, forPrimaryKey: self.userName.text)
import UIKit
import Realm
import RealmSwift
class CheckViewController: UIViewController {
    let realm = try! Realm()
    var datas : [String]!
    let user = RealmTools.object(UserEntity.self, primaryKey: nowUser!.username!) as! UserEntity
    //    var consumeItems:Results<UserEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(user)
        //         person = self.realm.object(ofType: UserEntity.self, forPrimaryKey: "张三")
        
        //        user = RealmTools.object(UserEntity.self, primaryKey: nowUser!.username!)
        //        consumeItems = realm.objects(UserEntity.self)
        //        let u = UserEntity()
        //        u.username = "张三"
        //        u.deletePhoto = "5天"
        //        u.uploadphoto = "无限制"
        //        try! realm.write {
        //            realm.add(u, update: .all)
        ////            realm.create(UserEntity.self, value: ["id": 1, "price": 22], update: .modified)
        //        }
    }
    
}

extension CheckViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //同一形式的单元格重复使用，在声明时已注册
        //        var cell = tableView.dequeueReusableCell(withIdentifier: "checkCell") as? CheckTableViewCell
        //                if cell == nil {
        //                    cell = CheckTableViewCell(style: .subtitle, reuseIdentifier: "checkCell")
        //                }
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkCell", for: indexPath)
            as! CheckTableViewCell
        cell.selectionStyle = .none
        let data = datas[indexPath.row]
        cell.title.text = data
        if data == user.deletePhoto ||  data == user.uploadphoto{
            tableView.selectRow(at: IndexPath(row: indexPath.row, section: 0), animated: false, scrollPosition: .none)
            
        }
        
        return cell
    }
    
    //表格单元格选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(datas[indexPath.row])
        let data = datas[indexPath.row]
        if data.contains("天") {
            RealmTools.updateWithTranstion { (true) in
                user.deletePhoto = data
                nowUser?.deletePhoto = data
            }
        }else{
            RealmTools.updateWithTranstion { (true) in
                user.uploadphoto = data
                nowUser?.uploadphoto = data
            }
        }
        //        self.navigationController?.popViewController(animated: true)
    }
    
}
