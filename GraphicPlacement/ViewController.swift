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
        self.opFrameVC.view!.frame = self.getOPFrameFrame(self.activeView!.frame)
    }
    
    func showOperationFV(sender:UITapGestureRecognizer) {
        self.focusOnView(sender.view!)
    }
    
    func focusOnView(view:UIView) {
        
        // 捜査対象のビューとして登録
        self.activeView = view
        
        // 操作フレーム表示
        self.opFrameVC.view.frame = self.getOPFrameFrame(self.activeView!.frame)
        self.view.addSubview(self.opFrameVC.view)
        
        // ドラッグ
        if self.opFrameVC.view.gestureRecognizers?.count < 2 {
            let grPan:UIGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragGesture(_:)))
            self.opFrameVC.view.addGestureRecognizer(grPan)
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
        }
        
        let point:CGPoint = sender.translationInView(self.view)
        // 移動量をドラッグしたViewの中心値に加える
        let movePoint:CGPoint = CGPointMake((sender.view?.center.x)! + point.x, (sender.view?.center.y)! + point.y)
        sender.view?.center = movePoint
        self.activeView!.center = movePoint
        // ドラッグで移動した距離を初期化する
        sender.setTranslation(CGPointZero, inView: self.view)
    }

    func onTapBGView(sender: UITapGestureRecognizer) {
        
        // 操作フレームを削除 - 削除した場合はすぐに抜ける
        if self.opFrameVC.view.isDescendantOfView(self.view) {
            self.opFrameVC.view.removeFromSuperview()
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
            self.currentTransForm = self.activeView!.transform;
        }
        
        // 回転角度取得
        angle = sender.rotation
        
        // アフィン変換を適用
        let transform:CGAffineTransform = CGAffineTransformConcat(CGAffineTransformConcat(self.currentTransForm, CGAffineTransformMakeRotation(angle)), CGAffineTransformMakeScale(scale, scale));
        self.activeView!.transform = transform
        self.opFrameVC.view.frame = self.getOPFrameFrame(self.activeView!.frame)
    }
    
    func getOPFrameFrame(baseFrame:CGRect) -> CGRect {
        var rect:CGRect = baseFrame
        rect.size = CGSizeMake(rect.size.width + 16, rect.size.height + 16)
        rect.origin = CGPointMake(rect.origin.x - 8, rect.origin.y - 8)
        return rect
    }
}

