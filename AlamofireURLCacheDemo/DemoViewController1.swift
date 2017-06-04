//
//  DemoViewController1.swift
//  AlamofireURLCacheDemo
//
//  Created by Kenshin Cui on 2017/5/23.
//  Copyright © 2017年 CMJStudio. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireURLCache

class DemoViewController1: UIViewController {

    @IBOutlet var textView:UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.useData()
    }
    
    @IBAction func useData() {
        self.loadData(isRefresh: false)
    }
    
    @IBAction func refreshCache() {
        self.loadData(isRefresh: true)
    }
    
    private func loadData(isRefresh:Bool) {
        self.dataRequest = Alamofire.request("https://myapi.applinzi.com/url-cache/no-cache.php",refreshCache:isRefresh).responseJSON(completionHandler: { response in
            if response.value != nil {
                self.textView.text = (response.value as! [String:Any]).debugDescription
            } else {
                self.textView.text = "Error!"
            }
            
        }).cache(maxAge: 10)
    }
    
    private var dataRequest:DataRequest?

}

