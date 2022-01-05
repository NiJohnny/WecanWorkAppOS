//
//  UITableViewOperate.swift
//  WecanWorkApp
//
//  Created by erp on 2021/6/2.
//

import Foundation
//定义各种操作命令
enum TableEditingCommand {
    case setItems(items: [String])  //设置表格数据
    case addItem(item: String)  //新增数据
    case moveItem(from: IndexPath, to: IndexPath) //移动数据
    case deleteItem(IndexPath) //删除数据
}
//定义表格对应的ViewModel
struct TableViewModel {
    //表格数据项
     var items:[String]
      
    init(items: [String] = []) {
        self.items = items
    }
      
    //执行相应的命令，并返回最终的结果
    func execute(command: TableEditingCommand) -> TableViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据。")
            return TableViewModel(items: items)
        case .addItem(let item):
            print("新增数据项。")
            var items = self.items
            items.append(item)
            return TableViewModel(items: items)
        case .moveItem(let from, let to):
            print("移动数据项。")
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return TableViewModel(items: items)
        case .deleteItem(let indexPath):
            print("删除数据项。")
            var items = self.items
            items.remove(at: indexPath.row)
            return TableViewModel(items: items)
        }
    }
}
