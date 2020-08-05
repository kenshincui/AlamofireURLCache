//
//  DemoViewController2.swift
//  AlamofireURLCacheDemo
//
//  Created by Kenshin Cui on 2017/5/27.
//  Copyright © 2017年 CMJStudio. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireURLCache

class DemoViewController3: UIViewController {

    @IBOutlet var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearCache()
    }

    @IBAction func clearCache() {
        if let dataRequest = self.dataRequest {
            AF.clearCache(dataRequest: dataRequest)
        }
        self.loadData(autoClear: false)
    }
    
    @IBAction func autoClear() {
        self.loadData(autoClear: true)
    }
    
    private func loadData(autoClear:Bool) {
        LoadingHUD.showLoading(in: self)
        self.dataRequest = AF.request("https://urlcachetest.herokuapp.com/no-cache.php",refreshCache:false).responseJSON(completionHandler: { response in
            if response.value != nil {
                self.textView.text = (response.value as! [String:Any]).debugDescription
            } else {
                self.textView.text = "Error!"
            }
            LoadingHUD.hide()
        },autoClearCache:autoClear).cache(maxAge: 10)
    }
    
    private var dataRequest:DataRequest?
}
