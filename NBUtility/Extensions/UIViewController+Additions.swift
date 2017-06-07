//
//  UIViewController+Additions.swift
//  NBUtility
//
//  Created by Fahid Attique on 01/08/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Specific Methods
    
    @IBAction func showMenu() {
        
        hideKeyboard()
        
        guard let slideMenuController = slideMenuController() else { return}
        slideMenuController.openLeft()
    }
    
    func presentViewController(_ viewControllerToPresent: UIViewController) {
        self.presentViewController(viewControllerToPresent, animated: true)
    }
    
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool) {
        self.present(viewControllerToPresent, animated: flag) { () -> Void in
            QL2("\(String(describing: type(of: viewControllerToPresent))) is presented.")
        }
    }
    
    func dismissViewController(_ completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
    
    func dismissMe() {
        if let navigationViewController = self.navigationController {
            
            if (navigationViewController.viewControllers.count > 1) {
                dismissPushedController()
            } else {
                dismissPresentedController()
            }
            
        } else {
            dismissPresentedController()
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func addCancelButton() {
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(dismissMe))
        navigationItem.leftBarButtonItem = cancelButton
        
    }
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first!.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    fileprivate func dismissPresentedController() {
        self.dismiss(animated: true, completion: { () -> Void in
            QL2("\(String(describing: type(of: self))) is dismiss.")
        })
    }
    
    fileprivate func dismissPushedController() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
