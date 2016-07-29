//
//  TextInsertViewController.swift
//  GraphicPlacement
//
//  Created by ImaedaToshiharu on 2016/07/29.
//  Copyright © 2016年 Grand Desgin Co., Ltd. All rights reserved.
//

import UIKit

class TextInsertViewController: ModalViewController {

    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    var isBold:Bool = false
    var initContentViewPos: CGPoint! = CGPointZero
    var keyBoardIsVisible:Bool = false
    var delegate:ViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TextInsertViewController.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TextInsertViewController.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // ボーダー設定
        self.borderView.layer.borderWidth = 1
        self.borderView.layer.borderColor = UIColor.lightGrayColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.contentView.frame.origin.y = self.contentView.frame.origin.y + 10
        UIView.animateWithDuration(0.2, animations: {() -> Void in
            self.contentView.frame.origin.y = self.contentView.frame.origin.y - 10
        })
    }
    
    // MARK: - Keyboard
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        self.keyBoardIsVisible = true
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        var txtLimit = self.contentView.frame.origin.y + self.contentView.frame.size.height + 8.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        self.initContentViewPos = self.contentView.frame.origin
        
        
        print("テキストフィールドの下辺：\(txtLimit)")
        print("キーボードの上辺：\(kbdLimit)")
        
        if txtLimit >= kbdLimit {
            self.myScrollView.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        self.keyBoardIsVisible = false
        self.myScrollView.contentOffset.y = 0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onTapBold(sender: AnyObject) {
        if self.isBold {
            // 元に戻す
            self.myTextView.font = UIFont.systemFontOfSize(16)
        } else {
            // 太くする
            self.myTextView.font = UIFont.boldSystemFontOfSize(16)
        }
        self.isBold = !self.isBold
        self.boldButton.selected = !self.boldButton.selected
    }
    
    @IBAction func onTapBG(sender: AnyObject) {
        
        if self.keyBoardIsVisible {
            if self.myTextView.isFirstResponder() {
                self.myTextView.resignFirstResponder()
            }
            return
        }
        
        self.closeModalView(nil)
    }
    
    @IBAction func onTapComp(sender: AnyObject) {
        
        // 文字挿入を命令
        self.delegate.insertLabel(self.myTextView.text, isBold: self.isBold, size: 15)
        self.closeModalView(nil)
    }
}
