//
//  MyTableViewCell.swift
//  hangge_1591
//
//  Created by hangge on 2018/1/3.
//  Copyright © 2018年 hangge. All rights reserved.
//

import UIKit
// MARK:- 定义协议
protocol ModelClickDelegateDelegate : class {
    func modelClick(selectedModel model : String,selectedAut aut : String)
}
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    weak var delegate : ModelClickDelegateDelegate?
    //单元格标题
    @IBOutlet weak var titleLabel: UILabel!
    
    //封面图片集合列表
    @IBOutlet weak var collectionView: UICollectionView!
    
    //collectionView的高度约束
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    //封面数据
    var images:[ModelChild] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置collectionView的代理
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        //        //允许多选
        //        self.collectionView.allowsMultipleSelection = true
        // 注册CollectionViewCell
        self.collectionView!.register(UINib(nibName:"MyCollectionViewCell", bundle:nil),
                                      forCellWithReuseIdentifier: "myCell")
    }
    
    //加载数据
    func reloadData(title:String, images:[ModelChild]) {
        
        //设置标题
        self.titleLabel.text = title
        //保存图片数据
        self.images = images
        
        //collectionView重新加载数据
        self.collectionView.reloadData()
        
        //更新collectionView的高度约束
        let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
        collectionViewHeight.constant = contentSize.height
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //返回collectionView的单元格数量
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    //4.该方法是点击了 CollectionViewCell 时调用的监听方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.modelClick(selectedModel: images[indexPath.row].title, selectedAut: images[indexPath.row].image)
    }
    
    //返回对应的单元格
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell",
                                                       for: indexPath) as! MyCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        cell.imageView.image = UIImage(named: images[indexPath.item].image)
        if !nowUser!.UserAut!.contains(images[indexPath.item].image) {
            cell.isUserInteractionEnabled = false
            cell.alpha = 0.3
        }
        cell.label.text = images[indexPath.item].title
        
        return cell
        
    }
    
    
    
    //绘制单元格底部横线
    //    override func draw(_ rect: CGRect) {
    //        //线宽
    //        let lineWidth = 1 / UIScreen.main.scale
    //        //线偏移量
    //        let lineAdjustOffset = 1 / UIScreen.main.scale / 2
    //        //线条颜色
    //        let lineColor = UIColor(red: 0xe0/255, green: 0xe0/255, blue: 0xe0/255, alpha: 1)
    //
    //        //获取绘图上下文
    //        guard let context = UIGraphicsGetCurrentContext() else {
    //            return
    //        }
    //
    //        //创建一个矩形，它的所有边都内缩固定的偏移量
    //        let drawingRect = self.bounds.insetBy(dx: lineAdjustOffset, dy: lineAdjustOffset)
    //
    //        //创建并设置路径
    //        let path = CGMutablePath()
    //        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
    //        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY))
    //
    //        //添加路径到图形上下文
    //        context.addPath(path)
    //
    //        //设置笔触颜色
    //        context.setStrokeColor(lineColor.cgColor)
    //        //设置笔触宽度
    //        context.setLineWidth(lineWidth)
    //
    //
    //        //绘制路径
    //        context.strokePath()
    //    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
