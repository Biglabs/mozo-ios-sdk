//
//  MozoNavigationController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/30/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

public class MozoNavigationController : UINavigationController {
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        }
        return UIInterfaceOrientationMask.all
    }
    
    public override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        }
        return true
    }
    
    func loadButtonFromNib() -> UIButton! {
        let bundle = BundleManager.mozoBundle()
        let nib = UINib(nibName: "CloseView", bundle: bundle)
        let button = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 78)
        
        return button
    }
}
