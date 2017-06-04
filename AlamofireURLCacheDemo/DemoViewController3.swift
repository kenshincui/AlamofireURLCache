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
            Alamofire.clearCache(dataRequest: dataRequest)
        }
        self.loadData(autoClear: false)
    }
    
    @IBAction func autoClear() {
        self.loadData(autoClear: true)
    }
    
    private func loadData(autoClear:Bool) {
        self.dataRequest = Alamofire.request("https://myapi.applinzi.com/url-cache/no-cache.php",refreshCache:false).responseJSON(completionHandler: { response in
            if response.value != nil {
                self.textView.text = (response.value as! [String:Any]).debugDescription
            } else {
                self.textView.text = "Error!"
            }
            
        },autoClearCache:autoClear).cache(maxAge: 10)
    }
    
    private var dataRequest:DataRequest?
}
