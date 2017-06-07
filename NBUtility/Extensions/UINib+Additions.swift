//
//  UINib+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 01/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension UINib {
    convenience init(nibClassName:UIView.Type) {

        let bundle = Bundle(for: nibClassName)
        self.init(nibName: className(nibClassName), bundle: bundle)
    }
}
