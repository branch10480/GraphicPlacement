//
//  OperationFrameViewController.swift
//  GraphicPlacement
//
//  Created by ImaedaToshiharu on 2016/07/22.
//  Copyright © 2016年 ImaedaToshiharu All rights reserved.
//

import UIKit

class OperationFrameViewController: UIViewController {

    @IBOutlet weak var handleTL: UIView!
    @IBOutlet weak var handleBL: UIView!
    @IBOutlet weak var handleTR: UIView!
    @IBOutlet weak var handleBR: UIView!
    @IBOutlet weak var bgView: UIView!
    
    // 画像の中心から、拡大縮小ハンドルの中心までの初期距離
    var distBetHandelAndImgCenter:CGFloat! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
