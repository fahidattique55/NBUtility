//
//  UITableView+UIRefresehControl.swift
//  NBUtility
//
//  Created by Fahid Attique on 4/18/17.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation


extension UITableView {
    
    // Add to Table View
    
    func addRefreshControl(_ refresher: UIRefreshControl, withSelector selector:Selector) {
    
        refresher.addTarget(nil, action: selector, for: .valueChanged)
        if #available(iOS 10.0, *) {
            refreshControl = refresher
        } else {
            addSubview(refresher)
        }
    }
    
}
