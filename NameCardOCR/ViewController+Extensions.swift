//
//  ViewController+Extensions.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func add(childController: UIViewController) {
        childController.willMove(toParent: self)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func alertDisplay(title: String, message: String) {
        let alertController = UIAlertController(title: title , message: message , preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.view.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        let blurredEffectViews = self.view.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
    
    func startIndicator() {
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
    }
    
    func stopIndicator() {
        let indicatorViews = self.view.subviews.filter{$0 is UIActivityIndicatorView}
        indicatorViews.forEach { indicator in
            indicator.removeFromSuperview()
        }
    }
    
    func hideCameraView() {
        CameraController().view.isHidden = true
        CameraController().view.layoutIfNeeded()
    }
    
    func showCameraView() {
        CameraController().view.isHidden = false
        CameraController().view.layoutIfNeeded()
    }
}
