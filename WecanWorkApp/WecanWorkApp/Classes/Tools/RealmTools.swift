//
//  RealmTools.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/21.
//
import UIKit
import RealmSwift

/**
 Realm 致力于平衡数据库读取的灵活性和性能。为了实现这个目标，在 Realm 中所存储的信息的各个方面都有基本的限制。例如：
 （1）类名称的长度最大只能存储 57 个 UTF8 字符。
 （2）属性名称的长度最大只能支持 63 个 UTF8 字符。
 （3）NSData 以及 String 属性不能保存超过 16 MB 大小的数据。如果要存储大量的数据，可通过将其分解为16MB 大小的块，或者直接存储在文件系统中，然后将文件路径存储在 Realm 中。如果您的应用试图存储一个大于 16MB 的单一属性，系统将在运行时抛出异常。
 （4）对字符串进行排序以及不区分大小写查询只支持“基础拉丁字符集”、“拉丁字符补充集”、“拉丁文扩展字符集 A” 以及”拉丁文扩展字符集 B“（UTF-8 的范围在 0~591 之间）。
 */

// 事件闭包(做完Realm操作后的事件)
public typealias RealmDoneTask = () -> Void
class RealmTools: NSObject {
    /// 单粒
    static let sharedInstance = RealmTools()
    /// 当前的 Realm
    fileprivate var currentRealm: Realm?
    /// 当前realm存储的路径
    static var fileURL: URL? {
        return sharedInstance.currentRealm?.configuration.fileURL
    }
    /// 当前的版本号
    fileprivate var currentSchemaVersion: UInt64 = 0
    /// 当前的加密字符串
    fileprivate var currentKeyWord: String? = ""
}

// MARK:- Realm数据库配置和版本差异化配置
/**
 通过调用 Realm() 来初始化以及访问我们的 realm 变量。其指向的是应用的 Documents 文件夹下的一个名为“default.realm”的文件。
 通过对默认配置进行更改，我们可以使用不同的数据库。比如给每个用户帐号创建一个特有的 Realm 文件，通过切换配置，就可以直接使用默认的 Realm 数据库来直接访问各自数据库
 */
// 在(application:didFinishLaunchingWithOptions:)中进行配置
extension RealmTools {
    
    // MARK: 配置数据库，为用户提供个性化的 Realm 配置(加密暂时没有使用)
    /// 配置数据库，为用户提供个性化的 Realm 配置
    /// - Parameters:
    ///   - userID: 用户的ID
    ///   - keyWord: 加密字符串
    ///   - schemaVersion: 设置新的架构版本(如果要存储的数据模型属性发生变化)，这个版本号必须高于之前所用的版本号，如果您之前从未设置过架构版本，那么这个版本号设置为 0）
    static func configRealm(userID: String?,
                            keyWord: String? = nil,
                            schemaVersion: UInt64 = 0, migrationBlock: MigrationBlock? = nil) {
        // 加密串128位结果为：464e5774625e64306771702463336e316a4074487442325145766477335e21346b715169364c406c6a4976346d695958396245346e356f6a62256d2637566126
        // let key: Data = "FNWtb^d0gqp$c3n1j@tHtB2QEvdw3^!4kqQi6L@ljIv4miYX9bE4n5ojb%m&7Va&".data(using: .utf8, allowLossyConversion: false)!
        // 加密的key
        // let key: Data = keyWord.data(using: .utf8, allowLossyConversion: false)!
        // 打开加密文件
        // (encryptionKey: key)
        // 使用默认的目录，但是使用用户 ID 来替换默认的文件名
        let fileURL = NSHomeDirectory() + "/Documents" + "/" + ("\(userID ?? "")default.realm")
        let config = Realm.Configuration(fileURL: URL(string: fileURL), schemaVersion: schemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
            // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
            if oldSchemaVersion < 1 {
                // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
            }
            // 低版本的数据库迁移......
            if migrationBlock != nil {
                migrationBlock!(migration, oldSchemaVersion)
            }
        })
        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = config
        guard let realm = try? Realm(configuration: config) else {
            return
        }
        sharedInstance.currentSchemaVersion = schemaVersion
        sharedInstance.currentRealm = realm
        sharedInstance.currentKeyWord = keyWord
    }
    
    // MARK: 删除当前的realm库
    /// 删除当前的realm库
    @discardableResult
    static func deleteRealmFiles() -> Bool {
        let realmURL = sharedInstance.currentRealm?.configuration.fileURL ?? Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("management")
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
                self.configRealm(userID: nil, keyWord: sharedInstance.currentKeyWord, schemaVersion: sharedInstance.currentSchemaVersion)
            } catch {
                // handle error
                return false
            }
        }
        return true
    }
}

// MARK:- 增
extension RealmTools {
    
    // MARK: 添加单个对象
    /// 添加单个对象
    /// - Parameters:
    ///   - object: 对象
    ///   - update: 是否更新
    ///   - task: 添加后操作
    static func add(_ object: Object, update: Realm.UpdatePolicy = .error, task: @escaping RealmDoneTask) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.add(object, update: update)
            task()
        }
    }
    
    // MARK: 添加多个对象
    /// 添加多个对象
    /// - Parameters:
    ///   - objects: 对象组
    ///   - update: 是否更新
    ///   - task: 添加后操作
    static func addList(_ objects: Array<Object>, update: Realm.UpdatePolicy = .error, task: @escaping RealmDoneTask) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.add(objects, update: update)
            task()
        }
    }
}

// MARK:- 删
extension RealmTools {
    
    // MARK: 在事务中删除一个对象
    /// 在事务中删除一个对象
    /// - Parameters:
    ///   - object: 单个被删除的对象
    ///   - task: 删除后操作
    static func delete(_ object: Object, task: @escaping RealmDoneTask) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.delete(object)
            task()
        }
    }
    
    // MARK: 在事务中删除多个对象
    /// 在事务中删除多个对象
    /// - Parameters:
    ///   - objects: 多个要被删除的对象
    ///   - task: 删除后操作
    static func deleteList(_ objects: Array<Object>, task: @escaping RealmDoneTask) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.delete(objects)
            task()
        }
    }
    
    // MARK: 删除所有数据（不要轻易调用）
    /// 从 Realm 中删除所有数据
    /// - Parameter task: 删除后操作
    static func deleteAll(task: @escaping RealmDoneTask) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.deleteAll()
            task()
        }
    }
    
    // MARK: 根据条件删除对象
    /// 根据条件删除对象
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate: 条件
    static func deleteByPredicate(object: Object.Type, predicate: NSPredicate) {
        guard let results: Array<Object> = objectsWithPredicate(object: object, predicate: predicate) else {
            return
        }
        deleteList(results) {
        }
    }
}

// MARK:- 改
extension RealmTools {
    
    // MARK: 更改某个对象（根据主键存在来更新，元素必须有主键）
    /// 更改某个对象（根据主键存在来更新）
    /// - Parameters:
    ///   - object: 某个对象
    ///   - update: 是否更新
    static func update(object: Object, update: Realm.UpdatePolicy = .modified) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.add(object, update: update)
        }
    }
    
    // MARK: 更改多个对象（根据主键存在来更新，元素必须有主键）
    /// 更改多个对象（根据主键存在来更新）
    /// - Parameters:
    ///   - objects: 多个对象
    ///   - update: 是否更新
    static func updateList(objects: Array<Object>, update: Realm.UpdatePolicy = .modified) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            weakCurrentRealm.add(objects, update: .modified)
        }
    }
    
    // MARK: 更新操作，对于realm搜索结果集当中的元素，在action当中直接赋值即可修改(比如查询到的某些属性可直接修改)
    /// 更新操作，对于realm搜索结果集当中的元素，在action当中直接赋值即可修改
    /// - Parameter action: 操作
    static func updateWithTranstion(action: (Bool) -> Void) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        try? weakCurrentRealm.write {
            action(true)
        }
    }
    
    // MARK: 更新一个一个对象的多个属性值（根据主键存在来更新，元素必须有主键）
    /// 更新一个一个对象的多个属性值
    /// - Parameters:
    ///   - object: 对象类型
    ///   - value: 数组数组
    ///   - update: 更新类型
    static func updateObjectAttribute(object: Object.Type, value: Any = [:], update: Realm.UpdatePolicy = .modified) {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return
        }
        do {
            try weakCurrentRealm.write {
                weakCurrentRealm.create(object, value: value, update: update)
            }
        } catch _ {
            
        }
    }
}

// MARK:- 查
extension RealmTools {
    // MARK: 通过主键查询某个对象数据
    /// 查询某个对象数据
    /// - Parameter type: 对象类型
    /// - Returns: 返回查询的结果
    static func object(_ object: Object.Type,primaryKey: String) -> Object? {
        guard let result = queryWithPrimaryKey(object: object, primaryKey: primaryKey) else {
            return nil
        }
        return result
    }
    
    // MARK: 查询某个对象数据
    /// 查询某个对象数据
    /// - Parameter type: 对象类型
    /// - Returns: 返回查询的结果
    static func objects(_ object: Object.Type) -> Array<Object>? {
        guard let results = queryWithType(object: object) else {
            return nil
        }
        return resultsToObjectList(results: results)
    }
    
    // MARK: 查询某个对象数据(根据条件)
    /// 查询某个对象数据(根据条件)
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate: 查询条件
    /// - Returns: 返回查询结果
    static func objectsWithPredicate(object: Object.Type, predicate: NSPredicate) -> Array<Object>? {
        guard let results = queryWith(object: object, predicate: predicate) else {
            return nil
        }
        return resultsToObjectList(results: results)
    }
    
    // MARK: 带排序条件查询
    ///  带排序条件查询
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate:  查询条件
    ///   - sortedKey: 排序的键
    ///   - isAssending: 升序还是降序，默认升序
    /// - Returns: 返回查询对象数组
    static func objectsWithPredicateAndSorted(object: Object.Type,
                                              predicate: NSPredicate,
                                              sortedKey: String,
                                              isAssending: Bool = true) -> Array<Object>? {
        guard let results = queryWithSorted(object: object, predicate: predicate, sortedKey: sortedKey, isAssending: isAssending) else {
            return nil
        }
        return resultsToObjectList(results: results)
    }
    
    // MARK: 带分页的查询
    /// 带分页的查询
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate: 查询条件
    ///   - sortedKey: 排序的键
    ///   - isAssending: 升序还是降序，默认升序
    ///   - fromIndex: 起始页
    ///   - pageSize: 一页的数量
    /// - Returns: 返回查询对象数组
    static func objectsWithPredicateAndSortedForPages(object: Object.Type,
                                                      predicate: NSPredicate,
                                                      sortedKey: String,
                                                      isAssending: Bool,
                                                      fromIndex: Int,
                                                      pageSize: Int) -> Array<Object>? {
        guard let results = queryWithSorted(object: object,
                                            predicate: predicate,
                                            sortedKey: sortedKey,
                                            isAssending: isAssending) else {
            return nil
        }
        var resultsArray = Array<Object>()
        if results.count <= pageSize * (fromIndex - 1) || fromIndex <= 0 {
            return resultsArray
        }
        if results.count > 0 {
            for i in pageSize * (fromIndex - 1)...(fromIndex * pageSize - 1) {
                resultsArray.append(results[i])
            }
        }
        return resultsArray
    }
}

//MARK:- 私有(查询)
extension RealmTools {
    
    /// 查询某个对象数据
    /// - Parameter object: 对象类型
    /// - Returns: 返回查询对象数组
    private static func queryWithType(object: Object.Type) -> Results<Object>? {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return nil
        }
        return weakCurrentRealm.objects(object)
    }
    
    // MARK: 主键查询
    /// - Parameter object: 对象类型
    /// - Returns: 返回查询对象
    private static func queryWithPrimaryKey(object: Object.Type,primaryKey: String) -> Object? {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return nil
        }
//        weakCurrentRealm.object(ofType: object, forPrimaryKey: primaryKey)
        return weakCurrentRealm.object(ofType: object, forPrimaryKey: primaryKey)
    }
    
    // MARK: 根据条件查询数据
    /// 根据条件查询数据
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate: 查询条件
    /// - Returns: 返回查询对象数组
    private static func queryWith(object: Object.Type,
                                  predicate: NSPredicate) -> Results<Object>? {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return nil
        }
        return weakCurrentRealm.objects(object).filter(predicate)
    }
    
    // MARK: 带排序条件查询
    /// 带排序条件查询
    /// - Parameters:
    ///   - object: 对象类型
    ///   - predicate: 查询条件
    ///   - sortedKey: 排序的键
    ///   - isAssending: 升序还是降序，默认升序
    /// - Returns: 返回查询对象数组
    private static func queryWithSorted(object: Object.Type,
                                        predicate: NSPredicate,
                                        sortedKey: String,
                                        isAssending: Bool = true) -> Results<Object>? {
        guard let weakCurrentRealm = sharedInstance.currentRealm else {
            return nil
        }
        return weakCurrentRealm.objects(object).filter(predicate)
            .sorted(byKeyPath: sortedKey, ascending: isAssending)
    }
    
    // MARK: 查询结果转Array<Object>
    /// 查询结果转Array<Object>
    /// - Parameter results: 查询结果
    /// - Returns: 返回Array<Object>
    private static func resultsToObjectList(results: Results<Object>) -> Array<Object> {
        var resultsArray = Array<Object>()
        if results.count > 0 {
            for i in 0...(results.count - 1) {
                resultsArray.append(results[i])
            }
        }
        return resultsArray
    }
}









//import Foundation
//import Realm
//import RealmSwift
///**
// Realm 致力于平衡数据库读取的灵活性和性能。为了实现这个目标，在 Realm 中所存储的信息的各个方面都有基本的限制。例如：
// （1）类名称的长度最大只能存储 57 个 UTF8 字符。
// （2）属性名称的长度最大只能支持 63 个 UTF8 字符。
// （3）NSData 以及 String 属性不能保存超过 16 MB 大小的数据。如果要存储大量的数据，可通过将其分解为16MB 大小的块，或者直接存储在文件系统中，然后将文件路径存储在 Realm 中。如果您的应用试图存储一个大于 16MB 的单一属性，系统将在运行时抛出异常。
// （4）对字符串进行排序以及不区分大小写查询只支持“基础拉丁字符集”、“拉丁字符补充集”、“拉丁文扩展字符集 A” 以及”拉丁文扩展字符集 B“（UTF-8 的范围在 0~591 之间）。
// */
//
//// 事件闭包(做完Realm操作后的事件)
//public typealias RealmDoneTask = () -> Void
//class RealmTools: NSObject {
//    /// 单粒
//    static let sharedInstance = RealmTools()
//    /// 当前的 Realm
//    fileprivate var currentRealm: Realm?
//    /// 当前realm存储的路径
//    static var fileURL: URL? {
//        return sharedInstance.currentRealm?.configuration.fileURL
//    }
//    /// 当前的版本号
//    fileprivate var currentSchemaVersion: UInt64 = 0
//    /// 当前的加密字符串
//    fileprivate var currentKeyWord: String? = ""
//}
//
//// MARK:- Realm数据库配置和版本差异化配置
///**
// 通过调用 Realm() 来初始化以及访问我们的 realm 变量。其指向的是应用的 Documents 文件夹下的一个名为“default.realm”的文件。
// 通过对默认配置进行更改，我们可以使用不同的数据库。比如给每个用户帐号创建一个特有的 Realm 文件，通过切换配置，就可以直接使用默认的 Realm 数据库来直接访问各自数据库
// */
//// 在(application:didFinishLaunchingWithOptions:)中进行配置
//extension RealmTools {
//
//    // MARK: 配置数据库，为用户提供个性化的 Realm 配置(加密暂时没有使用)
//    /// 配置数据库，为用户提供个性化的 Realm 配置
//    /// - Parameters:
//    ///   - userID: 用户的ID
//    ///   - keyWord: 加密字符串
//    ///   - schemaVersion: 设置新的架构版本(如果要存储的数据模型属性发生变化)，这个版本号必须高于之前所用的版本号，如果您之前从未设置过架构版本，那么这个版本号设置为 0）
//    static func configRealm(userID: String?,
//                        keyWord: String? = nil,
//                        schemaVersion: UInt64 = 0, migrationBlock: MigrationBlock? = nil) {
//        // 加密串128位结果为：464e5774625e64306771702463336e316a4074487442325145766477335e21346b715169364c406c6a4976346d695958396245346e356f6a62256d2637566126
//        // let key: Data = "FNWtb^d0gqp$c3n1j@tHtB2QEvdw3^!4kqQi6L@ljIv4miYX9bE4n5ojb%m&7Va&".data(using: .utf8, allowLossyConversion: false)!
//        // 加密的key
//        // let key: Data = keyWord.data(using: .utf8, allowLossyConversion: false)!
//        // 打开加密文件
//        // (encryptionKey: key)
//        // 使用默认的目录，但是使用用户 ID 来替换默认的文件名
////        NSHomeDirectory() + "/Documents"
//
////        let fileURL = FileManager.DocumnetsDirectory() + "/" + ("\(userID ?? "")default.realm")
//        let fileURL = NSHomeDirectory() + "/Documents" + "/" + ("\(userID ?? "")default.realm")
//        let config = Realm.Configuration(fileURL: URL(string: fileURL), schemaVersion: schemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
//            // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
//            if oldSchemaVersion < 1 {
//                // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
//            }
//            // 低版本的数据库迁移......
//            if migrationBlock != nil {
//                migrationBlock!(migration, oldSchemaVersion)
//            }
//        })
//        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
//        Realm.Configuration.defaultConfiguration = config
//        guard let realm = try? Realm(configuration: config) else {
//            return
//        }
//        sharedInstance.currentSchemaVersion = schemaVersion
//        sharedInstance.currentRealm = realm
//        sharedInstance.currentKeyWord = keyWord
//    }
//
//    // MARK: 删除当前的realm库
//    /// 删除当前的realm库
//    @discardableResult
//    static func deleteRealmFiles() -> Bool {
//        let realmURL = sharedInstance.currentRealm?.configuration.fileURL ?? Realm.Configuration.defaultConfiguration.fileURL!
//        let realmURLs = [
//            realmURL,
//            realmURL.appendingPathExtension("lock"),
//            realmURL.appendingPathExtension("management")
//        ]
//        for URL in realmURLs {
//            do {
//                try FileManager.default.removeItem(at: URL)
//                self.configRealm(userID: nil, keyWord: sharedInstance.currentKeyWord, schemaVersion: sharedInstance.currentSchemaVersion)
//            } catch {
//                // handle error
//               return false
//            }
//        }
//        return true
//    }
//}
//
//
//// MARK:- 增
//extension RealmTools {
//
//    // MARK: 添加单个对象
//    /// 添加单个对象
//    /// - Parameters:
//    ///   - object: 对象
//    ///   - update: 是否更新
//    ///   - task: 添加后操作
//    static func add(_ object: Object, update: Realm.UpdatePolicy = .error, task: @escaping RealmDoneTask) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.add(object, update: update)
//            task()
//        }
//    }
//
//    // MARK: 添加多个对象
//    /// 添加多个对象
//    /// - Parameters:
//    ///   - objects: 对象组
//    ///   - update: 是否更新
//    ///   - task: 添加后操作
//    static func addList(_ objects: Array<Object>, update: Realm.UpdatePolicy = .error, task: @escaping RealmDoneTask) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.add(objects, update: update)
//            task()
//        }
//    }
//}
//
//// MARK:- 删
//extension RealmTools {
//
//    // MARK: 在事务中删除一个对象
//    /// 在事务中删除一个对象
//    /// - Parameters:
//    ///   - object: 单个被删除的对象
//    ///   - task: 删除后操作
//    static func delete(_ object: Object, task: @escaping RealmDoneTask) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.delete(object)
//            task()
//        }
//    }
//
//    // MARK: 在事务中删除多个对象
//    /// 在事务中删除多个对象
//    /// - Parameters:
//    ///   - objects: 多个要被删除的对象
//    ///   - task: 删除后操作
//    static func deleteList(_ objects: Array<Object>, task: @escaping RealmDoneTask) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.delete(objects)
//            task()
//        }
//    }
//
//    // MARK: 删除所有数据（不要轻易调用）
//    /// 从 Realm 中删除所有数据
//    /// - Parameter task: 删除后操作
//    static func deleteAll(task: @escaping RealmDoneTask) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.deleteAll()
//            task()
//        }
//    }
//
//    // MARK: 根据条件删除对象
//    /// 根据条件删除对象
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate: 条件
//    static func deleteByPredicate(object: Object.Type, predicate: NSPredicate) {
//        guard let results: Array<Object> = objectsWithPredicate(object: object, predicate: predicate) else {
//            return
//        }
//        deleteList(results) {
//        }
//    }
//}
//
//// MARK:- 改
//extension RealmTools {
//
//    // MARK: 更改某个对象（根据主键存在来更新，元素必须有主键）
//    /// 更改某个对象（根据主键存在来更新）
//    /// - Parameters:
//    ///   - object: 某个对象
//    ///   - update: 是否更新
//    static func update(object: Object, update: Realm.UpdatePolicy = .modified) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.add(object, update: update)
//        }
//    }
//
//    // MARK: 更改多个对象（根据主键存在来更新，元素必须有主键）
//    /// 更改多个对象（根据主键存在来更新）
//    /// - Parameters:
//    ///   - objects: 多个对象
//    ///   - update: 是否更新
//    static func updateList(objects: Array<Object>, update: Realm.UpdatePolicy = .modified) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            weakCurrentRealm.add(objects, update: .modified)
//        }
//    }
//
//    // MARK: 更新操作，对于realm搜索结果集当中的元素，在action当中直接赋值即可修改(比如查询到的某些属性可直接修改)
//    /// 更新操作，对于realm搜索结果集当中的元素，在action当中直接赋值即可修改
//    /// - Parameter action: 操作
//    static func updateWithTranstion(action: (Bool) -> Void) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        try? weakCurrentRealm.write {
//            action(true)
//        }
//    }
//
//    // MARK: 更新一个一个对象的多个属性值（根据主键存在来更新，元素必须有主键）
//    /// 更新一个一个对象的多个属性值
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - value: 数组数组
//    ///   - update: 更新类型
//    static func updateObjectAttribute(object: Object.Type, value: Any = [:], update: Realm.UpdatePolicy = .modified) {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return
//        }
//        do {
//            try weakCurrentRealm.write {
//                weakCurrentRealm.create(object, value: value, update: update)
//            }
//        } catch _ {
//
//        }
//    }
//}
//
//// MARK:- 查
//extension RealmTools {
//    // MARK: 查询某个对象数据
//    /// 查询某个对象数据
//    /// - Parameter type: 对象类型
//    /// - Returns: 返回查询的结果
//    static func objects(_ object: Object.Type) -> Array<Object>? {
//        guard let results = queryWithType(object: object) else {
//            return nil
//        }
//        return resultsToObjectList(results: results)
//    }
//
//    // MARK: 查询某个对象数据(根据条件)
//    /// 查询某个对象数据(根据条件)
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate: 查询条件
//    /// - Returns: 返回查询结果
//    static func objectsWithPredicate(object: Object.Type, predicate: NSPredicate) -> Array<Object>? {
//        guard let results = queryWith(object: object, predicate: predicate) else {
//            return nil
//        }
//        return resultsToObjectList(results: results)
//    }
//
//    // MARK: 带排序条件查询
//    ///  带排序条件查询
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate:  查询条件
//    ///   - sortedKey: 排序的键
//    ///   - isAssending: 升序还是降序，默认升序
//    /// - Returns: 返回查询对象数组
//    static func objectsWithPredicateAndSorted(object: Object.Type,
//                                       predicate: NSPredicate,
//                                       sortedKey: String,
//                                     isAssending: Bool = true) -> Array<Object>? {
//        guard let results = queryWithSorted(object: object, predicate: predicate, sortedKey: sortedKey, isAssending: isAssending) else {
//            return nil
//        }
//        return resultsToObjectList(results: results)
//    }
//
//    // MARK: 带分页的查询
//    /// 带分页的查询
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate: 查询条件
//    ///   - sortedKey: 排序的键
//    ///   - isAssending: 升序还是降序，默认升序
//    ///   - fromIndex: 起始页
//    ///   - pageSize: 一页的数量
//    /// - Returns: 返回查询对象数组
//    static func objectsWithPredicateAndSortedForPages(object: Object.Type,
//                                                  predicate: NSPredicate,
//                                                  sortedKey: String,
//                                                  isAssending: Bool,
//                                                  fromIndex: Int,
//                                                  pageSize: Int) -> Array<Object>? {
//        guard let results = queryWithSorted(object: object,
//                                     predicate: predicate,
//                                     sortedKey: sortedKey,
//                                 isAssending: isAssending) else {
//            return nil
//        }
//        var resultsArray = Array<Object>()
//        if results.count <= pageSize * (fromIndex - 1) || fromIndex <= 0 {
//            return resultsArray
//        }
//        if results.count > 0 {
//            for i in pageSize * (fromIndex - 1)...(fromIndex * pageSize - 1) {
//                resultsArray.append(results[i])
//            }
//        }
//        return resultsArray
//    }
//}
//
////MARK:- 私有(查询)
//extension RealmTools {
//
//    /// 查询某个对象数据
//    /// - Parameter object: 对象类型
//    /// - Returns: 返回查询对象数组
//    private static func queryWithType(object: Object.Type) -> Results<Object>? {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return nil
//        }
//        return weakCurrentRealm.objects(object)
//    }
//
//    // MARK: 根据条件查询数据
//    /// 根据条件查询数据
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate: 查询条件
//    /// - Returns: 返回查询对象数组
//    private static func queryWith(object: Object.Type,
//                           predicate: NSPredicate) -> Results<Object>? {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return nil
//        }
//        return weakCurrentRealm.objects(object).filter(predicate)
//    }
//
//    // MARK: 带排序条件查询
//    /// 带排序条件查询
//    /// - Parameters:
//    ///   - object: 对象类型
//    ///   - predicate: 查询条件
//    ///   - sortedKey: 排序的键
//    ///   - isAssending: 升序还是降序，默认升序
//    /// - Returns: 返回查询对象数组
//    private static func queryWithSorted(object: Object.Type,
//                                 predicate: NSPredicate,
//                                 sortedKey: String,
//                               isAssending: Bool = true) -> Results<Object>? {
//        guard let weakCurrentRealm = sharedInstance.currentRealm else {
//            return nil
//        }
//        return weakCurrentRealm.objects(object).filter(predicate)
//        .sorted(byKeyPath: sortedKey, ascending: isAssending)
//    }
//
//    // MARK: 查询结果转Array<Object>
//    /// 查询结果转Array<Object>
//    /// - Parameter results: 查询结果
//    /// - Returns: 返回Array<Object>
//    private static func resultsToObjectList(results: Results<Object>) -> Array<Object> {
//        var resultsArray = Array<Object>()
//        if results.count > 0 {
//            for i in 0...(results.count - 1) {
//                resultsArray.append(results[i])
//            }
//        }
//        return resultsArray
//    }
//}
