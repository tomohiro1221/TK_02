//
//  ViewController.swift
//  Bubbly
//
//  Created by Takumi Takahashi on 11/28/15.
//  Copyright © 2015 Takumi Takahashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func pushPayButton(sender: UIButton) {
        let paymentViewController = WPYPaymentViewController(priceTag: "¥350", callback: { viewController, token, error in
            if let _ = error {
                print("error:\(error.localizedDescription)")
            } else {
                print("payment success!")
                // tokenをサーバーにPOSTし、決済を完了させます
                
                // 決済完了後
                viewController.setPayButtonComplete()
                viewController.dismissAfterDelay(2.0)
            }
        })
        
        self.presentViewController(paymentViewController, animated: true, completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WPYTokenizer.setPublicKey("test_public_6A7bi15wfdPbbGMfPNbb16lC")
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
