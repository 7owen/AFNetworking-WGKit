//
//  ViewController.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = "http://baidu.com/"
        let requestContext = WGURLRequestContext(url: url)
        WGURLSession.request(requestContext!){ (response, responseObj, error) in
            if error != nil {
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

