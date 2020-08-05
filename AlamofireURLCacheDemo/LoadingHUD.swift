//
//  LoadingHUD.swift
//  AlamofireURLCacheDemo
//
//  Created by 崔江涛 on 2020/8/5.
//  Copyright © 2020 CMJStudio. All rights reserved.
//

import UIKit

class LoadingHUD {

    static var alertController:UIAlertController?
    
    static func showLoading(in controller:UIViewController) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        self.alertController = alert
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func hide() {
        self.alertController?.dismiss(animated: true, completion: nil)
    }
    
}
