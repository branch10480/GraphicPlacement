//
//  ModalViewController.swift
//  ItemListDemo02_01
//
//  Created by ImaedaToshiharu on H28/06/27.
//  Copyright © 平成28年 Grand Desgin Co., Ltd. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.2, animations: {() -> Void in
                self.view.alpha = 1
            }, completion: {(result:Bool) -> Void in
                
            })
    }
    
    // MARK: - ModalWindowMethod
    
    func closeModalView(completion:(()->Void)?) {
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.view.alpha = 0
            }, completion: {(result:Bool) -> Void in
                self.dismissViewControllerAnimated(false, completion: {() -> Void in
                    if completion != nil {
                        completion!()
                    }
            })
        })
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
