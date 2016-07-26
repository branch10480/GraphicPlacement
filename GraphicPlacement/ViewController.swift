//
//  ViewController.swift
//  GraphicPlacement
//
//  Created by ImaedaToshiharu on 2016/07/22.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    var activeView:UIView?
    
    var currentTransForm:CGAffineTransform = CGAffineTransformIdentity
    var opFrameVC:OperationFrameViewController!
    var frameHandlePointVC:FrameHandlePointViewController!
    var frameHandleVC:FrameHandleViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ピンチ
        let grPinch:UIGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinch(_:)))
        self.view.addGestureRecognizer(grPinch)
        
        // タップ - 背景
        let grTapBG:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.onTapBGView(_:)))
        self.bgView.userInteractionEnabled = true
        self.bgView.addGestureRecognizer(grTapBG)
        
        // 回転 - 背景
        let grRotate:UIGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotateOnBG(_:)))
        self.bgView.addGestureRecognizer(grRotate)
        
        // 操作ビューコントローラ
        self.opFrameVC = OperationFrameViewController()
        self.frameHandlePointVC = FrameHandlePointViewController()
        self.frameHandleVC = FrameHandleViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getGRTap() -> UIGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(ViewController.showOperationFV(_:)))
    }

    func pinch(sender:UIPinchGestureRecognizer) {
        
        if self.activeView == nil {
            return
        }
        
        if sender.state == .Began {
            self.currentTransForm = self.activeView!.transform;
            // currentTransFormは、フィールド変数。imgViewは画像を表示するUIImageView型のフィールド変数。
        }

        // ピンチジェスチャー発生時から、どれだけ拡大率が変化したかを取得する
        // 2本の指の距離が離れた場合には、1以上の値、近づいた場合には、1以下の値が取得できる
        let scale:CGFloat = sender.scale;

        // ピンチジェスチャー開始時からの拡大率の変化を、imgViewのアフィン変形の状態に設定する事で、拡大する。
        self.activeView!.transform = CGAffineTransformConcat(currentTransForm, CGAffineTransformMakeScale(scale, scale));
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        print("スケール : \(testScale)")
        
        self.opFrameVC.view.bounds = CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale + 16, self.activeView!.bounds.size.height * testScale + 16)
        self.opFrameVC.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
        
        // つまみの位置調整
        let w:CGFloat = self.activeView!.bounds.size.width/2
        let h:CGFloat = self.activeView!.bounds.size.height/2
        let dist:CGFloat = sqrt(pow(w, 2) + pow(h, 2))
        let handleRad:CGFloat = atan2(h, w)
        self.frameHandlePointVC.view.center.x = (dist*testScale + 30) * CGFloat(cosf(Float(radian - handleRad))) + self.activeView!.center.x
        self.frameHandlePointVC.view.center.y = (dist*testScale + 30) * CGFloat(sinf(Float(radian - handleRad))) + self.activeView!.center.y
        self.frameHandlePointVC.view.backgroundColor = UIColor.clearColor()
        self.frameHandleVC.view.frame = self.frameHandlePointVC.view.frame
        
    }
    
    func showOperationFV(sender:UITapGestureRecognizer) {
        self.focusOnView(sender.view!)
    }
    
    func focusOnView(view:UIView) {
        
        // 捜査対象のビューとして登録
        self.activeView = view
        
        // 操作フレーム表示
        self.opFrameVC.view.transform = CGAffineTransformIdentity
        self.opFrameVC.view.frame = self.getOPFrameFrame(self.activeView!.frame)
        self.opFrameVC.view.bounds = self.getOPFrameBounds(self.activeView!.frame)
        self.view.addSubview(self.opFrameVC.view)
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        print("スケール : \(testScale)")
        
        self.opFrameVC.view.bounds = CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale + 16, self.activeView!.bounds.size.height * testScale + 16)
        self.opFrameVC.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
        
        // 回転ハンドル表示
        self.frameHandlePointVC.view.frame = CGRectMake(0, 0, 30, 30)
        self.frameHandlePointVC.view.center = CGPointMake(self.opFrameVC.view.center.x + self.opFrameVC.view.bounds.size.width/2,
                                                        self.opFrameVC.view.center.y - self.opFrameVC.view.bounds.size.height/2)
        
        let w:CGFloat = view.bounds.size.width/2
        let h:CGFloat = view.bounds.size.height/2
        let dist:CGFloat = sqrt(pow(w, 2) + pow(h, 2))
        let handleRad:CGFloat = atan2(h, w)
        self.frameHandlePointVC.view.center.x = (dist*testScale + 30) * CGFloat(cosf(Float(radian - handleRad))) + view.center.x
        self.frameHandlePointVC.view.center.y = (dist*testScale + 30) * CGFloat(sinf(Float(radian - handleRad))) + view.center.y
        self.frameHandlePointVC.view.backgroundColor = UIColor.clearColor()
        self.frameHandleVC.view.frame = self.frameHandlePointVC.view.frame
        self.view.addSubview(self.frameHandleVC.view)
        self.view.addSubview(self.frameHandlePointVC.view)
        
        // ドラッグ
        if self.opFrameVC.view.gestureRecognizers?.count < 2 {
            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragGesture(_:)))
            self.opFrameVC.view.addGestureRecognizer(grPan)
        }
        
        // ドラッグ - 回転つまみ
        if self.frameHandlePointVC.view.gestureRecognizers?.count < 2 {
            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.rotateDrag(_:)))
            self.frameHandlePointVC.view.addGestureRecognizer(grPan)
        }
    }
    
    func dragGesture(sender: UIPanGestureRecognizer) {
        
        if self.activeView == nil {
            return
        }
        
        let targetView:UIView = sender.view!
        
        if sender.state == .Began {
            
            // レイヤーを一番上に持ってくる
            self.view.bringSubviewToFront(targetView)
            self.view.bringSubviewToFront(self.frameHandleVC.view)
            self.view.bringSubviewToFront(self.frameHandlePointVC.view)
        }
        
        let point:CGPoint = sender.translationInView(self.view)
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        self.activeView!.center = movePoint
        self.frameHandleVC.view.center = CGPointMake(self.frameHandleVC.view.center.x + point.x, self.frameHandleVC.view.center.y + point.y)
        self.frameHandlePointVC.view.center = CGPointMake(self.frameHandleVC.view.center.x + point.x, self.frameHandleVC.view.center.y + point.y)
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateDrag(sender: UIPanGestureRecognizer) {
        
        if self.activeView == nil {
            return
        }
        
        let point:CGPoint = sender.translationInView(self.view)
        
        if sender.state == .Began {
            
            // 現在の変形情報を取得
            self.currentTransForm = self.activeView!.transform
            
            // 初期位置を覚える
            self.frameHandlePointVC.initPos = sender.view?.center
            
            // 画像中心点からハンドルまでの距離を求める
            let x:Float = Float(sender.view!.center.x - (self.activeView?.center.x)!)
            let y:Float = Float((self.activeView?.center.y)! - sender.view!.center.y)
            self.frameHandleVC.distanceBetImgCenter = CGFloat(sqrt(pow(x, 2) + pow(y, 2)))
            
            // 最初の x軸との角度を記憶
            self.frameHandlePointVC.initTheta = atan2(sender.view!.center.y - self.activeView!.center.y + point.y, sender.view!.center.x - self.activeView!.center.x + point.x)
        }
        
        let theta:CGFloat = atan2(sender.view!.center.y - self.activeView!.center.y + point.y, sender.view!.center.x - self.activeView!.center.x + point.x) - self.frameHandlePointVC.initTheta
        
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: self.view)
        
        // アフィン変換を適用
        let scale:CGFloat = 1.0
        let transform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformConcat(self.currentTransForm, CGAffineTransformMakeRotation(theta)), CGAffineTransformMakeScale(scale, scale))
        self.activeView!.transform = transform
        
        // ハンドル表示部の座標調整
        self.frameHandleVC.view.center = CGPointMake(self.frameHandleVC.distanceBetImgCenter * CGFloat(cosf(Float(theta + self.frameHandlePointVC.initTheta))) + CGFloat(self.activeView!.center.x),
                                                     self.frameHandleVC.distanceBetImgCenter * CGFloat(sinf(Float(theta + self.frameHandlePointVC.initTheta))) + CGFloat(self.activeView!.center.y))
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        print("スケール : \(testScale)")
        
        let testTransform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
        self.opFrameVC.view.transform = testTransform
        
        if sender.state == .Ended {
            // 操作ハンドルを表示ハンドルの位置に移動させる
            self.frameHandlePointVC.view.center = self.frameHandleVC.view.center
        }
    }

    func onTapBGView(sender: UITapGestureRecognizer) {
        
        // 操作フレームを削除 - 削除した場合はすぐに抜ける
        if self.opFrameVC.view.isDescendantOfView(self.view) {
            self.opFrameVC.view.removeFromSuperview()
            self.frameHandleVC.view.removeFromSuperview()
            self.activeView = nil
            return
        }
        
        let pos:CGPoint = sender.locationOfTouch(0, inView: self.view)
        
        // 画像を追加
        let image:UIImage = UIImage(named: "butterfly.png")!
        let imgView:UIImageView = UIImageView(image: image)
        imgView.contentMode = .ScaleAspectFit
        imgView.userInteractionEnabled = true
        let rect:CGRect = CGRectMake(pos.x-100, pos.y-100, 200, 200)
        imgView.frame = rect
        imgView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(imgView)
        
        // タップジェスチャー登録
        imgView.addGestureRecognizer(self.getGRTap())
        
        // アクティブ状態にする
        self.focusOnView(imgView)
    }
    
    func rotateOnBG(sender:UIRotationGestureRecognizer) {
        
        if activeView == nil {
            return
        }
        
        let scale:CGFloat = 1.0
        var angle:CGFloat = 0
        
        // ジェスチャ開始時
        if sender.state == .Began {
            self.currentTransForm = self.activeView!.transform
            
        }
        
        // 回転角度取得
        angle = sender.rotation
        
        // アフィン変換を適用
        let transform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformConcat(self.currentTransForm, CGAffineTransformMakeRotation(angle)), CGAffineTransformMakeScale(scale, scale));
        self.activeView!.transform = transform
        self.opFrameVC.view.frame = self.getOPFrameFrame(self.activeView!.frame)
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        print("スケール : \(testScale)")
        
        self.opFrameVC.view.bounds = CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale + 16, self.activeView!.bounds.size.height * testScale + 16)
        self.opFrameVC.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
    }
    
    func getOPFrameFrame(baseFrame:CGRect) -> CGRect {
        var rect:CGRect = baseFrame
        rect.size = CGSizeMake(rect.size.width + 16, rect.size.height + 16)
        rect.origin = CGPointMake(rect.origin.x - 8, rect.origin.y - 8)
        return rect
    }
    
    func getOPFrameBounds(baseBounds:CGRect) -> CGRect {
        var rect:CGRect = baseBounds
        rect.size = CGSizeMake(rect.size.width + 16, rect.size.height + 16)
        rect.origin = CGPointMake(0, 0)
        return rect
    }
}

