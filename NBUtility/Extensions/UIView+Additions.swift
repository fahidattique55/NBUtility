//
//  UIView+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 01/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension UIView {
    
    class func viewFromNibClassName<T:UIView>(_ nibClassName:T.Type) -> T {
        return viewFromNibName(className(nibClassName), bundle: Bundle(for: nibClassName)) as! T
    }
    
    class func viewFromNibName(_ name:String, bundle: Bundle = Bundle.main) -> UIView? {
        let views = bundle.loadNibNamed(name, owner: nil, options: nil)
        guard let view = views!.first as? UIView else {
            fatalError("Could not find view from nib name: " + name)
        }
        
        return view
        
    }
    
    // MARK: - Easy Frames
    
    func setFrameWidth(_ width:CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
    }
    
    func setFrameHeight(_ height:CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
    }
    
    func setFrameX(_ x:CGFloat) {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func setFrameY(_ y:CGFloat) {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func frameWidth() -> CGFloat {
        return self.frame.size.width;
    }
    
    func frameHeight() -> CGFloat {
        return self.frame.size.height;
    }
    
    func frameX() -> CGFloat {
        return self.frame.origin.x;
    }
    
    func frameY() -> CGFloat {
        return self.frame.origin.y;
    }
    
    // MARK: - Cornar Radius
    
    func setCornarRadius(_ cornarRadius:CGFloat, cornars:UIRectCorner, strokeColor:UIColor?) {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornars, cornerRadii: CGSize(width: cornarRadius, height: cornarRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        if (strokeColor != nil) { maskLayer.strokeColor = strokeColor?.cgColor}
        maskLayer.path = maskPath.cgPath
        
        // Set the newly created shape layer as the mask for the image view's layer
        layer.mask = maskLayer
        
    }
    
    // MARK: - Utility
    
    func removeAllSubviews() {
        self.subviews.forEach{ $0.removeFromSuperview() }
    }
    
}

