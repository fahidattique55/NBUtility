//
//  ViewController.swift
//  NBUtility
//
//  Created by Fahid Attique on 5/29/17.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    fileprivate let manager:ServiceManager = ServiceManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _ = manager.requestForArray(.get, service: EndPoint.countryList, authorized: true, mapperClass: WeatherCondition.self, success: { (response, result) in
            
            print("success")
            
        }) { error in
         
            print("\(error)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
