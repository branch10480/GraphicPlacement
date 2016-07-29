//
//  ViewController.swift
//  GraphicPlacement
//
//  Created by ImaedaToshiharu on 2016/07/22.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit

protocol ViewControllerDelegate {
    func insertLabel(text:String, isBold:Bool, size:CGFloat) -> Void
}

class ViewController: UIViewController, ViewControllerDelegate {
    
    @IBOutlet weak var bgView: UIView!
    var activeView:UIView?
    
    var currentTransForm:CGAffineTransform = CGAffineTransformIdentity
    var opFrameVC:OperationFrameViewController!
    var frameHandlePointVC:FrameHandlePointViewController!
    var frameHandleVC:FrameHandleViewController!
    var pointRT:FrameHandlePointViewController!
    var pointRB:FrameHandlePointViewController!
    var pointLT:FrameHandlePointViewController!
    var pointLB:FrameHandlePointViewController!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
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
        self.pointRT = self.getPointViewWithColor(UIColor.redColor())
        self.pointRB = self.getPointViewWithColor(UIColor.blueColor())
        self.pointLT = self.getPointViewWithColor(UIColor.greenColor())
        self.pointLB = self.getPointViewWithColor(UIColor.orangeColor())
    }
    
    func getPointViewWithColor(color:UIColor) -> FrameHandlePointViewController {
        let vc:FrameHandlePointViewController = FrameHandlePointViewController()
        vc.view.frame = CGRectMake(0, 0, 30, 30)
        vc.view.backgroundColor = color
        return vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ToImagedView" {
            let vc:ImagedViewController = segue.destinationViewController as! ImagedViewController
            let imgv:UIImageView = UIImageView(image: self.getConvertedImg())
            vc.myImage = imgv
        }
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
        
        self.opFrameVC.view.bounds = self.getOPFrameBounds(CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale, self.activeView!.bounds.size.height * testScale))
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
        self.myScrollView.addSubview(self.opFrameVC.view)
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        print("スケール : \(testScale)")
        
        self.opFrameVC.view.bounds = self.getOPFrameBounds(CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale, self.activeView!.bounds.size.height * testScale))
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
        self.myScrollView.addSubview(self.frameHandleVC.view)
        self.myScrollView.addSubview(self.frameHandlePointVC.view)
        
        // 拡大縮小ハンドル
        let basePointRad:CGFloat = -handleRad
        let basePointRad2:CGFloat = CGFloat(M_PI) - basePointRad
        self.pointRT.view.center.x = (dist*testScale + 15) * cos(basePointRad + radian) + self.activeView!.center.x
        self.pointRT.view.center.y = (dist*testScale + 15) * sin(basePointRad + radian) + self.activeView!.center.y
        self.pointRB.view.center.x = (dist*testScale + 15) * cos(basePointRad + radian + 2*handleRad) + self.activeView!.center.x
        self.pointRB.view.center.y = (dist*testScale + 15) * sin(basePointRad + radian + 2*handleRad) + self.activeView!.center.y
        self.pointLT.view.center.x = (dist*testScale + 15) * cos(basePointRad2 + radian) + self.activeView!.center.x
        self.pointLT.view.center.y = (dist*testScale + 15) * sin(basePointRad2 + radian) + self.activeView!.center.y
        self.pointLB.view.center.x = (dist*testScale + 15) * cos(basePointRad2 + radian - 2*handleRad) + self.activeView!.center.x
        self.pointLB.view.center.y = (dist*testScale + 15) * sin(basePointRad2 + radian - 2*handleRad) + self.activeView!.center.y
        self.myScrollView.addSubview(self.pointRT.view)
        self.myScrollView.addSubview(self.pointRB.view)
        self.myScrollView.addSubview(self.pointLT.view)
        self.myScrollView.addSubview(self.pointLB.view)
        
        /** ドラッグ - 図形移動 **/
        if self.opFrameVC.bgView.gestureRecognizers?.count < 2 {
            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragGesture(_:)))
            self.opFrameVC.view.addGestureRecognizer(grPan)
        }
        
        /** ドラッグ - 拡大縮小 **/
//        // 右上
//        if self.opFrameVC.handleTR.gestureRecognizers?.count < 2 {
//            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.scaleDrag(_:)))
//            self.opFrameVC.handleTR.addGestureRecognizer(grPan)
//        }
//        // 右下
//        if self.opFrameVC.handleBR.gestureRecognizers?.count < 2 {
//            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.scaleDrag(_:)))
//            self.opFrameVC.handleBR.addGestureRecognizer(grPan)
//        }
//        // 左上
//        if self.opFrameVC.handleTL.gestureRecognizers?.count < 2 {
//            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.scaleDrag(_:)))
//            self.opFrameVC.handleTL.addGestureRecognizer(grPan)
//        }
//        // 左下
//        if self.opFrameVC.handleBL.gestureRecognizers?.count < 2 {
//            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.scaleDrag(_:)))
//            self.opFrameVC.handleBL.addGestureRecognizer(grPan)
//        }
        // 左下
        if self.opFrameVC.handleBL.gestureRecognizers?.count < 2 {
            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.scaleDrag(_:)))
            self.opFrameVC.handleBL.addGestureRecognizer(grPan)
        }
        
        /** ドラッグ - 回転つまみ **/
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
            self.myScrollView.bringSubviewToFront(targetView)
            self.myScrollView.bringSubviewToFront(self.frameHandleVC.view)
            self.myScrollView.bringSubviewToFront(self.frameHandlePointVC.view)
            self.myScrollView.bringSubviewToFront(self.pointRT.view)
            self.myScrollView.bringSubviewToFront(self.pointRB.view)
            self.myScrollView.bringSubviewToFront(self.pointLT.view)
            self.myScrollView.bringSubviewToFront(self.pointLB.view)
        }
        
        let point:CGPoint = sender.translationInView(myScrollView)
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        self.activeView!.center = movePoint
        self.frameHandleVC.view.center = CGPointMake(self.frameHandleVC.view.center.x + point.x, self.frameHandleVC.view.center.y + point.y)
        self.frameHandlePointVC.view.center = CGPointMake(self.frameHandleVC.view.center.x + point.x, self.frameHandleVC.view.center.y + point.y)
        self.pointRT.view.center = CGPointMake(self.pointRT.view.center.x + point.x, self.pointRT.view.center.y + point.y)
        self.pointRB.view.center = CGPointMake(self.pointRB.view.center.x + point.x, self.pointRB.view.center.y + point.y)
        self.pointLT.view.center = CGPointMake(self.pointLT.view.center.x + point.x, self.pointLT.view.center.y + point.y)
        self.pointLB.view.center = CGPointMake(self.pointLB.view.center.x + point.x, self.pointLB.view.center.y + point.y)
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: myScrollView)
    }
    
    func rotateDrag(sender: UIPanGestureRecognizer) {
        
        if self.activeView == nil {
            return
        }
        
        let point:CGPoint = sender.translationInView(myScrollView)
        
        if sender.state == .Began {
            
            // 現在の変形情報を取得
            self.currentTransForm = self.activeView!.transform
            
            // 初期位置を覚える
            self.frameHandlePointVC.initPos = sender.view?.center
            
            // 画像中心点からハンドルまでの距離を求める
            let x:Float = Float(sender.view!.center.x - (self.activeView?.center.x)!)
            let y:Float = Float((self.activeView?.center.y)! - sender.view!.center.y)
            self.frameHandleVC.distanceBetImgCenter = CGFloat(sqrt(pow(x, 2) + pow(y, 2)))
            
            // 拡大縮小つまみドラッグビューの初期位置記憶
            self.pointRT.initPos = self.pointRT.view.center
            
            // 最初の x軸との角度を記憶
            self.frameHandlePointVC.initTheta = atan2(sender.view!.center.y - self.activeView!.center.y + point.y, sender.view!.center.x - self.activeView!.center.x + point.x)
        }
        
        let theta:CGFloat = atan2(sender.view!.center.y - self.activeView!.center.y + point.y, sender.view!.center.x - self.activeView!.center.x + point.x) - self.frameHandlePointVC.initTheta
        
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: myScrollView)
        
        // アフィン変換を適用
        let scale:CGFloat = 1.0
        let transform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformConcat(self.currentTransForm, CGAffineTransformMakeRotation(theta)), CGAffineTransformMakeScale(scale, scale))
        self.activeView!.transform = transform
        
        // ハンドル表示部の座標調整
        self.frameHandleVC.view.center = CGPointMake(self.frameHandleVC.distanceBetImgCenter * cos(theta + self.frameHandlePointVC.initTheta) + self.activeView!.center.x,
                                                     self.frameHandleVC.distanceBetImgCenter * sin(theta + self.frameHandlePointVC.initTheta) + self.activeView!.center.y)
        
        // 回転
        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        let degree:CGFloat = radian/CGFloat(M_PI/180)
        print("回転 : \(degree)度")
        
        // スケール
//        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
//        print("スケール : \(testScale)")
        
        let testTransform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
        self.opFrameVC.view.transform = testTransform
        
        self.pointRT.view.center = self.rotatePoint(self.pointRT.initPos, base: self.activeView!.center, radian: theta + self.frameHandlePointVC.initTheta)
        
        if sender.state == .Ended {
            // 操作ハンドルを表示ハンドルの位置に移動させる
            self.frameHandlePointVC.view.center = self.frameHandleVC.view.center
        }
    }
    
    func scaleDrag(sender:UIPanGestureRecognizer) {
        
        let r:CGFloat = sqrt(pow(sender.view!.center.x - self.opFrameVC.bgView!.center.x, 2) + pow(sender.view!.center.y - self.opFrameVC.bgView!.center.y, 2))
        
        // 回転
//        let radian:CGFloat = atan2(self.activeView!.transform.b, self.activeView!.transform.a)
        
        // スケール
        let testScale:CGFloat = sqrt(abs(self.activeView!.transform.a * self.activeView!.transform.d - self.activeView!.transform.b * self.activeView!.transform.c))
        
        self.opFrameVC.view.bounds = self.getOPFrameBounds(CGRectMake(0, 0, self.activeView!.bounds.size.width * testScale, self.activeView!.bounds.size.height * testScale))
//        self.opFrameVC.view.transform = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeRotation(radian))
        
        
        /** スケールを求める **/
        
        // 移動後の点を求める
        // 移動量
        let point:CGPoint = sender.translationInView(myScrollView)
        let movedPoint:CGPoint = CGPointMake(sender.view!.center.x + point.x, sender.view!.center.y + point.y)
        
        // Affine変換を記憶して一時的に初期化する
        let opFrameAffine:CGAffineTransform = self.opFrameVC.view.transform
        opFrameVC.view.transform = CGAffineTransformIdentity
        
        // 移動後の点と、画像中心点までの距離
        let R:CGFloat = sqrt(pow(movedPoint.x - self.opFrameVC.bgView!.center.x, 2) + pow(movedPoint.y - self.opFrameVC.bgView!.center.y, 2))
        
        // x軸に対する 移動前の点と画像中心点を結んだ線との角度、移動後の点と画像中心点を結んだ線との角度の差を求める
        let theta:CGFloat = atan2(sender.view!.center.x - self.opFrameVC.bgView!.center.x, sender.view!.center.y - self.opFrameVC.bgView!.center.y) -
atan2(movedPoint.x - self.opFrameVC.bgView!.center.x, movedPoint.y - self.opFrameVC.bgView!.center.y)
        
        let scale:CGFloat = R * cos(theta) / r
        
        
        // 画像にスケールを適用
        self.activeView!.transform = CGAffineTransformScale(self.activeView!.transform, scale, scale)
        
        // 描画
        self.opFrameVC.view.bounds.size = CGSizeMake(scale * self.opFrameVC.view.bounds.size.width, scale * self.opFrameVC.view.bounds.size.height)
        self.opFrameVC.view.transform = opFrameAffine
        
        print("スケール")
        print(scale)
        print("------------------")
        
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: myScrollView)
    }

    func onTapBGView(sender: UITapGestureRecognizer) {
        
        // 操作フレームを削除 - 削除した場合はすぐに抜ける
        if self.opFrameVC.view.isDescendantOfView(myScrollView) {
            self.opFrameVC.view.removeFromSuperview()
            self.frameHandleVC.view.removeFromSuperview()
            self.pointRT.view.removeFromSuperview()
            self.pointRB.view.removeFromSuperview()
            self.pointLT.view.removeFromSuperview()
            self.pointLB.view.removeFromSuperview()
            self.activeView = nil
            return
        }
        
        let pos:CGPoint = sender.locationOfTouch(0, inView: myScrollView)
        
        // 画像を追加
        let image:UIImage = UIImage(named: "item_rotation2.png")!
        let imgView:UIImageView = UIImageView(image: image)
        imgView.contentMode = .ScaleAspectFit
        imgView.userInteractionEnabled = true
        let rect:CGRect = CGRectMake(pos.x-100, pos.y-100, 200, 200)
        imgView.frame = rect
        imgView.backgroundColor = UIColor.clearColor()
        myScrollView.addSubview(imgView)
        
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
        rect.size = CGSizeMake(rect.size.width + 32, rect.size.height + 32)
        rect.origin = CGPointMake(rect.origin.x - 16, rect.origin.y - 16)
        return rect
    }
    
    func getOPFrameBounds(baseBounds:CGRect) -> CGRect {
        var rect:CGRect = baseBounds
        rect.size = CGSizeMake(rect.size.width + 32, rect.size.height + 32)
        rect.origin = CGPointMake(0, 0)
        return rect
    }
    
    func rotatePoint(point:CGPoint, base:CGPoint, radian:CGFloat) -> CGPoint {
        var retPoint:CGPoint = point
        let dist:CGFloat = sqrt(pow(retPoint.x - base.x, 2) + pow(retPoint.y - base.y, 2))
        // 原点に戻して回転
        retPoint.x = (retPoint.x - base.x)*cos(radian) + (retPoint.y - base.y)*sin(radian)
        retPoint.y = -(retPoint.x - base.x)*sin(radian) + (retPoint.y - base.y)*cos(radian)
        
        print("point:\(point)")
        print("point:\(base)")
        print("radian:\(radian)")
        
        // 平行移動
        retPoint = CGPointMake(retPoint.x + base.x, retPoint.y + base.y)
        return retPoint
    }
    @IBAction func onTapInsertChara(sender: AnyObject) {
        let vc:TextInsertViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TextInsertView") as! TextInsertViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    // MARK: - ViewControllerDelegate
    
    func insertLabel(text: String, isBold:Bool, size:CGFloat) {
        let label:UILabel = UILabel()
        label.text = text
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.frame = CGRectZero
        label.frame.size = CGSizeMake(1100, 5000)
        label.sizeToFit()
        
        myScrollView.addSubview(label)
        label.center = self.view.center
        label.frame.origin.y = label.frame.origin.y + self.myScrollView.contentOffset.y
        label.userInteractionEnabled = true
        
        if isBold {
            label.font = UIFont.boldSystemFontOfSize(size)
        }
        
        // タップジェスチャー登録
        label.addGestureRecognizer(self.getGRTap())
        
        self.focusOnView(label)
    }
    
    // 画像化
    func getConvertedImg() -> UIImage {
        
        // 撮影用の UIView を準備
        let scrRect:CGRect = CGRectMake(0, 0, self.myScrollView.contentSize.width, self.myScrollView.contentSize.height)
        let baseView:UIView = UIView(frame: scrRect)
        let initFrameOfScrView = self.myScrollView.frame
        self.myScrollView.frame = scrRect
        
        UIGraphicsBeginImageContextWithOptions(self.myScrollView.contentSize, self.myScrollView.opaque, 0.0)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        //        CGContextTranslateCTM(context, -self.targetView.frame.origin.x, -self.targetView.frame.origin.y)      // 平行移動メソッド
        baseView.layer.renderInContext(context)
        let renderImg:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // スクロールビューを元に戻す
        self.myScrollView.frame = initFrameOfScrView
        
        return renderImg
    }
}

