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
    var coreEventHandler : CoreModuleInterface?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    public override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        scanAllViewControllers()
    }
    
    func scanAllViewControllers() {
        print("Mozo Navigation Controller, scan all view controllers")
        for viewController in self.viewControllers {
            // TODO: Apply translation according to localizaion
            print("Controller title: \(viewController.navigationItem.title ?? "DEFAULT")")
            if viewController.navigationItem.rightBarButtonItem == nil {
                addCancelBtn(item: viewController.navigationItem)
            }
        }
    }
    
    func addCloseBtn(item: UINavigationItem) {
        print("Add close button.")
        let button = loadButtonFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapCloseBtn))
        tap.numberOfTapsRequired = 1
        button?.isUserInteractionEnabled = true
        button?.addGestureRecognizer(tap)
    
        item.rightBarButtonItem = UIBarButtonItem(customView: button!)
    }
    
    func addCancelBtn(item: UINavigationItem) {
        let cancelBtn = UIBarButtonItem(title: "Cancel".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.tapCloseBtn))
        item.rightBarButtonItem = cancelBtn
    }
    
    func loadButtonFromNib() -> UIButton! {
        let bundle = BundleManager.mozoBundle()
        let nib = UINib(nibName: "CloseView", bundle: bundle)
        let button = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 78)
        
        return button
    }
    
    @objc func tapCloseBtn() {
        coreEventHandler?.requestForCloseAllMozoUIs(nil)
    }
}
