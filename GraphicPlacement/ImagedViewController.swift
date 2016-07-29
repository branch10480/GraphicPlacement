//
//  ImagedViewController.swift
//  GraphicPlacement
//
//  Created by ImaedaToshiharu on 2016/07/29.
//  Copyright © 2016年 Grand Desgin Co., Ltd. All rights reserved.
//

import UIKit

class ImagedViewController: UIViewController {

    @IBOutlet weak var myImage: UIImageView!
    
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
    
    @IBAction func onTapBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
