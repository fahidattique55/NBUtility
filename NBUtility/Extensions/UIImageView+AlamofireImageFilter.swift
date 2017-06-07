//
//  UIImageView+AlamofireImageFilter.swift
//  NBUtility
//
//  Created by Fahid Attique on 17/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension UIImageView {
    
    fileprivate class func circleFilter(_ size: CGSize) -> ImageFilter {
        return AspectScaledToFillSizeCircleFilter(size: size)
    }
    
    func setCirlceImageWithURL(_ URL: Foundation.URL, filterSize: CGSize) {
        
        af_setImage(withURL: URL, placeholderImage: nil, filter: UIImageView.circleFilter(filterSize), progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: nil)
        
    }
    
    class func removeCircleImageWithURL(_ URL: Foundation.URL, filterSize: CGSize) -> Bool {
        
        guard let imageCache = af_sharedImageDownloader.imageCache else { return false}
        let isRemoved = imageCache.removeImage(for: URLRequest( url: URL), withIdentifier: circleFilter(filterSize).identifier)
        print("Image removed: " + String(isRemoved))
        return isRemoved
    }
    
}
