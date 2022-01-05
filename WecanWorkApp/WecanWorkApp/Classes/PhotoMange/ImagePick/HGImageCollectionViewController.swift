//
//  HGImageCollectionViewController.swift
//  hangge_1512
//
//  Created by hangge on 2017/1/7.
//  Copyright © 2017年 hangge.com. All rights reserved.
//
import UIKit
import Photos
import Kingfisher
import RxAlamofire
import Toast_Swift
extension UIViewController {
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
//    func presentHGImagePicker(maxSelected:Int = Int.max,
//                              completeHandler:((_ assets:[String])->())?)
//        -> HGImagePickerController?{
//        //获取图片选择视图控制器
//        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main)
//            .instantiateViewController(withIdentifier: "imagePickerVC")
//            as? HGImagePickerController{
//            //设置选择完毕后的回调
//            vc.completeHandler = completeHandler
//            //设置图片最多选择的数量
//            vc.maxSelected = maxSelected
//            //将图片选择视图控制器外添加个导航控制器，并显示
//            let nav = UINavigationController(rootViewController: vc)
//            self.present(nav, animated: true, completion: nil)
//            return vc
//        }
//        return nil
//    }
//
    
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentPreviewPicker(maxSelected:Int = Int.max,imagesResults:[PhotoEntity],
                              completeHandler:((_ assets:[String])->())?)
        -> HGImageCollectionViewController?{
        //获取图片选择视图控制器
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "hgImageCollectionVC")
            as? HGImageCollectionViewController{
            //设置选择完毕后的回调
            vc.completeHandler = completeHandler
            //设置图片最多选择的数量
            vc.maxSelected = maxSelected
            
            vc.imagesResults = imagesResults
            
            //将图片选择视图控制器外添加个导航控制器，并显示
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: false, completion: nil)
//            viewController()?.navigationController?.pushViewController(nav, animated: true)

            return vc
        }
        return nil
    }
    
    //HGImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentPreviewPicker(uivc:UIViewController,isShowUpload  : Bool = true,maxSelected:Int = Int.max,imagesResults:[PhotoEntity],
                              completeHandler:((_ assets:[String])->())?)
        -> HGImageCollectionViewController?{
        //获取图片选择视图控制器
        if let vc = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "hgImageCollectionVC")
            as? HGImageCollectionViewController{
            //设置选择完毕后的回调
            vc.completeHandler = completeHandler
            //设置图片最多选择的数量
            vc.maxSelected = maxSelected
            
            vc.imagesResults = imagesResults
            
            vc.isShowUpload = isShowUpload
            //将图片选择视图控制器外添加个导航控制器，并显示
            uivc.navigationController!.pushViewController(vc, animated: true)
            return vc
        }
        return nil
    }
}

//图片缩略图集合页控制器
class HGImageCollectionViewController: UIViewController {
    //用于显示所有图片缩略图的collectionView
    @IBOutlet weak var collectionView:UICollectionView!

    //下方工具栏
    @IBOutlet weak var toolBar:UIToolbar!

    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?

    //取得的资源结果，用了存放的PHAsset
    var imagesResults:[PhotoEntity]?

    //带缓存的图片管理对象
    var imageManager:PHCachingImageManager!

    //缩略图大小
    var assetGridThumbnailSize:CGSize!

    //每次最多可选择的照片数量
    var maxSelected:Int = Int.max

    //照片选择完毕后的回调
    var completeHandler:((_ assets:[String])->())?

    //完成按钮
    var completeButton:HGImageCompleteButton!

    //完成按钮
    var previewButton:HGImageCompleteButton!

    var isShowUpload : Bool!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //根据单元格的尺寸计算我们需要的缩略图大小
//        let scale = UIScreen.main.scale
//        let cellSize = (self.collectionView.collectionViewLayout as!
//                            UICollectionViewFlowLayout).itemSize
//        assetGridThumbnailSize = CGSize(width: cellSize.width*scale ,
//                                        height: cellSize.height*scale)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (kScreenW-3*10)/3, height: (kScreenW-3*10)/3)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.collectionView.collectionViewLayout = layout

    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        imagesResults = ["1627242977319.jpg","1627242983717.jpg"]
        //背景色设置为白色（默认是黑色）
        self.collectionView.backgroundColor = UIColor.white

        //初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()

        //设置单元格尺寸
        let layout = (self.collectionView.collectionViewLayout as!
                        UICollectionViewFlowLayout)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/4-1,
                                 height: UIScreen.main.bounds.size.width/4-1)
        //允许多选
        self.collectionView.allowsMultipleSelection = true
        
        //添加导航栏右侧的取消按钮
//        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain,
//                                           target: self, action: #selector(cancel))
//        self.navigationItem.rightBarButtonItem = rightBarItem

        //添加下方工具栏的完成按钮
        completeButton = HGImageCompleteButton("上传")
        completeButton.addTarget(target: self, action: #selector(finishSelect))
        completeButton.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: 22)
        completeButton.isEnabled = true
        //添加下方工具栏的预览按钮
        previewButton = HGImageCompleteButton("预览")
        previewButton.addTarget(target: self, action: #selector(preViewSelect))
        previewButton.center = CGPoint(x: 50, y: 22)
        previewButton.isEnabled = true

        if !isShowUpload {
            completeButton.isHidden = true
        }
        
        toolBar.addSubview(completeButton)
        toolBar.addSubview(previewButton)
        toolBar.backgroundColor = .white

    }

    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }


    //取消按钮点击
    @objc func cancel() {
        //退出当前视图控制器
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    //获取已选择个数
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }
   

    //上传按钮点击
    @objc func finishSelect(){
        //取出已选择的图片资源
        //        var assets:[PHAsset] = []
        //        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
        //            for indexPath in indexPaths{
        //                assets.append(assetsFetchResults![indexPath.row] )
        //            }
        //        }

        var assets:[String] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                let photoEntity = imagesResults![indexPath.row]
                if photoEntity.status == UPLOAD_STATUS_UNUPLOADED {
                    assets.append(photoEntity.photoName!)
                }
                print("---\(imagesResults![indexPath.row])****")
            }
        }
       
        if assets.count != 0 {
            self.completeHandler?(assets)
        }else{
//            SwiftNotice.showText("没有未上传照片")
            self.view.makeToast("没有未上传照片", position: .center)
        }
        
        self.collectionView.reloadData()
        completeButton.num = 0
        previewButton.num = 0
        completeButton.isEnabled = false
        previewButton.isEnabled = false
        
        //调用回调函数
//        self.navigationController?.dismiss(animated: true, completion: {
//            self.completeHandler?(assets)
//        })
    }

    @objc func preViewSelect(){
        var assets:[String] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(imagesResults![indexPath.row].photoName! )
                print("---\(imagesResults![indexPath.row])****")
            }
        }
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: assets, index: 0)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
}

//图片缩略图集合页控制器UICollectionViewDataSource,UICollectionViewDelegate协议方法的实现
extension HGImageCollectionViewController:UICollectionViewDataSource
                                          ,UICollectionViewDelegate{
    //CollectionView项目
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imagesResults!.count
    }

    // 获取单元格
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获取storyboard里设计的单元格，不需要再动态添加界面元素
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                      for: indexPath) as! HGImageCollectionViewCell
        let asset = self.imagesResults![indexPath.row]
        //获取缩略图
        //        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
        //                                       contentMode: .aspectFill, options: nil) {
        //                                        (image, nfo) in
        //            cell.imageView.image = image
        //
        //
        //
        //
        //        }
        print(kPhotoPath)
        print(asset.photoName!)
        let path = URL(fileURLWithPath: kPhotoPath).appendingPathComponent(asset.photoName!)
        cell.imageView.kf.setImage(with:path)

        return cell
    }

    //单元格选中响应
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath)
            as? HGImageCollectionViewCell{
            //获取选中的数量
            let count = self.selectedCount()
            //如果选择的个数大于最大选择数
            if count > self.maxSelected {
                //设置为不选中状态
                collectionView.deselectItem(at: indexPath, animated: false)
                //弹出提示
                let title = "你最多只能选择\(self.maxSelected)张照片"
                let alertController = UIAlertController(title: title, message: nil,
                                                        preferredStyle: .alert)

                let cancelAction = UIAlertAction(title:"我知道了", style: .cancel,
                                                 handler:nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
            //如果不超过最大选择数
            else{
                //改变完成按钮数字，并播放动画
                completeButton.num = count
                previewButton.num = count
                if count > 0 && !self.completeButton.isEnabled{
                    completeButton.isEnabled = true
                    previewButton.isEnabled = true
                }
                cell.playAnimate()
            }
            
            let photoname = imagesResults![indexPath.row].photoName
            
            let predicate = NSPredicate(format: "photoname = '\(photoname ?? "")' AND status = 0")
            if nowUser?.workspace == MARKER {
               let items = RealmTools.objectsWithPredicate(object: Marker.self, predicate: predicate) as! [Marker]
                if items.count==0 {
                    imagesResults![indexPath.row].status = 1
                }
            } else if nowUser?.workspace == CUSTOM {
                let items = RealmTools.objectsWithPredicate(object: Custom.self, predicate: predicate) as! [Custom]
                 if items.count==0 {
                     imagesResults![indexPath.row].status = 1
                 }
             }else if nowUser?.workspace == RECEIVE {
                let items = RealmTools.objectsWithPredicate(object: Receive.self, predicate: predicate) as! [Receive]
                 if items.count==0 {
                     imagesResults![indexPath.row].status = 1
                 }
             }
            
            
        }
    }

    //单元格取消选中响应
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)
            as? HGImageCollectionViewCell{
            //获取选中的数量
            let count = self.selectedCount()
            completeButton.num = count
            previewButton.num = count
            //改变完成按钮数字，并播放动画
            if count == 0{
                completeButton.isEnabled = false
                previewButton.isEnabled = false
            }
            cell.playAnimate()
        }
    }
}

