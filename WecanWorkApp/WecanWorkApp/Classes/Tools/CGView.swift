//
//  File.swift
//  camera
//
//  Created by erp on 2021/8/20.
//  Copyright © 2021 imaginaryCloud. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
class CGView:UIView {
    let count = kScreenH/22
    //运动管理器
       let motionManager = CMMotionManager()
        
       //刷新时间间隔
       let timeInterval: TimeInterval = 2
    //线宽
    let lineWidth = 1 / UIScreen.main.scale
     
    //线偏移量
    let lineAdjustOffset = 1 / UIScreen.main.scale / 2
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        //设置背景色为透明，否则是黑色背景
        self.backgroundColor = UIColor.clear
        //开始陀螺仪更新
                startGyroUpdates()
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    // 开始获取陀螺仪数据
        func startGyroUpdates() {
            //判断设备支持情况
            guard motionManager.isGyroAvailable else {
                print("\n当前设备不支持陀螺仪\n")
                return
            }
             
            //设置刷新时间间隔
            self.motionManager.gyroUpdateInterval = self.timeInterval
             
            //开始实时获取数据
            let queue = OperationQueue.current
            self.motionManager.startGyroUpdates(to: queue!, withHandler: { (gyroData, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                // 有更新
                if self.motionManager.isGyroActive {
                    
                    if let rotationRate = gyroData?.rotationRate {
                        var text = "---当前陀螺仪数据---\n"
                        text += "x: \(rotationRate.x)\n"
                        text += "y: \(rotationRate.y)\n"
                        text += "z: \(rotationRate.z)\n"
                        print(text)
                        
                        //设置动画效果，动画时间长度 1 秒。
                                    UIView.animate(withDuration: 1, delay:0.01, options: [], animations: {
                                        ()-> Void in
                                        //在动画中，数字块有一个角度的旋转。
                                        self.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(rotationRate.z*360)))
                                        
                                    },
                                    completion:{
                                        (finished:Bool) -> Void in
                                        UIView.animate(withDuration: 1, animations:{
                                            ()-> Void in
                                            //完成动画时，数字块复原
                                            self.layer.setAffineTransform(CGAffineTransform.identity)
                                        })
                                    })

                        
                    }
                }
            })
        }
    
    func playLine(aa:Double){
        //设置动画效果，动画时间长度 1 秒。
                    UIView.animate(withDuration: 1, delay:0.01, options: [], animations: {
                        ()-> Void in
                        //在动画中，数字块有一个角度的旋转。
                        self.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(aa*360)))
                        
                    },
                    completion:{
                        (finished:Bool) -> Void in
                        UIView.animate(withDuration: 1, animations:{
                            ()-> Void in
                            //完成动画时，数字块复原
                            self.layer.setAffineTransform(CGAffineTransform.identity)
                        })
                    })
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
         
        //获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
         
        
        for index in 0...10 {
            print("\(index) 乘于 5 为：\(index * 5)")
            //创建一个矩形，它的所有边都内缩固定的偏移量
            let drawingRect = self.bounds.insetBy(dx: lineAdjustOffset, dy: lineAdjustOffset)
             
            //创建并设置路径
            let path = CGMutablePath()
            //外边框
            path.addRect(drawingRect)
            //横向分隔线(中点同样要计算偏移量)
            let midY = CGFloat(Int(self.bounds.midY)) + lineAdjustOffset
            path.move(to: CGPoint(x: drawingRect.minX, y: midY+CGFloat(index*30)))
            path.addLine(to: CGPoint(x: drawingRect.maxX, y: midY+CGFloat(index*30)))
            
            path.move(to: CGPoint(x: drawingRect.minX, y: midY+CGFloat(-index*30)))
            path.addLine(to: CGPoint(x: drawingRect.maxX, y: midY+CGFloat(-index*30)))
            //纵向分隔线(中点同样要计算偏移量)
            let midX = CGFloat(Int(self.bounds.midX)) + lineAdjustOffset
            path.move(to: CGPoint(x: midX+CGFloat(index*30), y: drawingRect.minY))
            path.addLine(to: CGPoint(x: midX+CGFloat(index*30), y: drawingRect.maxY))
            path.move(to: CGPoint(x: midX+CGFloat(-index*30), y: drawingRect.minY))
            path.addLine(to: CGPoint(x: midX+CGFloat(-index*30), y: drawingRect.maxY))
            //添加路径到图形上下文
            context.addPath(path)
             
            //设置笔触颜色
            context.setStrokeColor(UIColor.red.cgColor)
            if index == 0 {
                context.setStrokeColor(UIColor.green.cgColor)
            }
            

            //设置笔触宽度
            context.setLineWidth(lineWidth)
     
            //绘制路径
            context.strokePath()
        }
        
        
    }
}
