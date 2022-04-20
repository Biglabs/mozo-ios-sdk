//
//  AccessDeniedWireframe.swift
//  MozoRetailer
//
//  Created by Hoang Nguyen on 3/13/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation

extension DisplayUtils {
    public static func displayAccessDeniedScreen() {
        print("DisplayUtils - Display access denied screen")
        if let topViewController = getTopViewController() {
            if topViewController is AccessDeniedViewController {
                print("DisplayUtils - Access denied screen is being displayed.")
                return
            }
            if let klass = DisplayUtils.getAuthenticationClass(),
                topViewController.isKind(of: klass) {
                print("DisplayUtils - Authentication screen is being displayed.")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.displayAccessDeniedScreen()
                }
                return
            }
            print("DisplayUtils - topViewController - presentingViewController: \(String(describing: topViewController.presentingViewController))")
            print("DisplayUtils - topViewController - presentedViewController: \(String(describing: topViewController.presentedViewController))")
            print("DisplayUtils - Display access denied screen with top view controller: \(topViewController)")
            let viewController = AccessDeniedViewController.viewControllerFromXIB()
            viewController.modalPresentationStyle = .fullScreen
            topViewController.present(viewController, animated: false)
        } else {
            print("DisplayUtils - Can not display access denied screen - no top view controller")
        }
    }
}
