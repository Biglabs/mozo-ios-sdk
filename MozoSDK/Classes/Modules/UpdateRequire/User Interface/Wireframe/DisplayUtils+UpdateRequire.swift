//
//  DisplayUtils+UpdateRequire.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/16/20.
//

import Foundation

extension DisplayUtils {
    public static func displayUpdateRequireScreen() {
        if let topViewController = getTopViewController() {
            if topViewController is UpdateRequireViewController {
                print("DisplayUtils - Update require screen is being displayed.")
                return
            }
            if let klass = DisplayUtils.getAuthenticationClass(),
                topViewController.isKind(of: klass) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.displayUpdateRequireScreen()
                }
                return
            }
            let viewController = UpdateRequireViewController.viewControllerFromXIB()
            viewController.modalPresentationStyle = .fullScreen
            topViewController.present(viewController, animated: true)
        } else {
            print("DisplayUtils - Can not display Update require screen - no top view controller")
        }
    }
}
