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

class DemoViewController2: UIViewController {

    @IBOutlet var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.useServerConfig()
    }

    @IBAction func useServerConfig() {
        self.loadData(ignoreServer: false)
    }
    
    @IBAction func useCustomConfig() {
        self.loadData(ignoreServer: true)
    }
    
    private func loadData(ignoreServer:Bool) {
        LoadingHUD.showLoading(in: self)
        self.dataRequest = AF.request("https://urlcachetest.herokuapp.com/default-cache.php",refreshCache:false).responseJSON(completionHandler: { response in
            if response.value != nil {
                self.textView.text = (response.value as! [String:Any]).debugDescription
            } else {
                self.textView.text = "Error!"
            }
            LoadingHUD.hide()
        }).cache(maxAge: 10,isPrivate: false,ignoreServer: ignoreServer)
    }
    
    private var dataRequest:DataRequest?
}
