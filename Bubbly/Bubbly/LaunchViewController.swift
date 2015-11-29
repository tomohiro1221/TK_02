//
//  LaunchViewController.swift
//  Bubbly
//
//  Created by Takumi Takahashi on 11/29/15.
//  Copyright © 2015 Takumi Takahashi. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view = UIView(frame: CGRectMake(0, 0, 50, 50))
//        self.view.backgroundColor = UIColor.redColor()
//        var layer = createSplashLayer("logo", frameNumber: 119, frameRate: 29.7)
//        self.view.layer.addSublayer(layer)
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
//    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
//        var viewController: ViewController = self.storyboard?.instantiateViewControllerWithIdentifier("viewController") as! ViewController
//        self.presentViewController(viewController, animated: true, completion: nil)
//    }
//    
//    func createSplashLayer(baseformat: NSString, frameNumber: Int, frameRate: Double) -> CALayer {
//        var splashLayer = CALayer()
//        splashLayer.frame = CGRectMake(0, 0, 200, 200)
//        var imageListArray : Array<UIImage> = []
//        var timingArray : Array<Float> = []
//        
//        var animation = CAKeyframeAnimation()
//        animation.keyPath = "contents"
//        animation.duration = Double(frameNumber) / frameRate
//        animation.removedOnCompletion = false
//        
//        for i in 0...frameNumber {
//            var path = (baseformat as String) + "_" + (NSString(format: "%05d", i) as String) + ".png"
//            var image = UIImage(named: path)
//            imageListArray.append(image!)
//            timingArray.append(Float(i / frameNumber))
//        }
//        
//        animation.keyTimes = timingArray
//        animation.values = imageListArray
//        animation.calculationMode = kCAAnimationDiscrete;
//        animation.repeatCount = 1;
//        animation.fillMode = kCAFillModeForwards;
//        animation.delegate = self;
//        
//        splashLayer.addAnimation(animation, forKey: "splash")
//        return splashLayer
//    }
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
