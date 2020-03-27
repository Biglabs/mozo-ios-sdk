//
//  DisplayUtils+UpdateRequire.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/16/20.
//

import Foundation
import AppAuth
extension DisplayUtils {
    public static func displayUpdateRequireScreen() {
        print("DisplayUtils - Display update require screen")
        if let topViewController = getTopViewController() {
            if topViewController is UpdateRequireViewController {
                print("DisplayUtils - Update require screen is being displayed.")
                return
            }
            if let klass = DisplayUtils.getAuthenticationClass(),
                topViewController.isKind(of: klass) {
                print("DisplayUtils - Authentication screen is being displayed.")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.displayUpdateRequireScreen()
                }
                return
            }
            print("DisplayUtils - topViewController - presentingViewController: \(String(describing: topViewController.presentingViewController))")
            print("DisplayUtils - topViewController - presentedViewController: \(String(describing: topViewController.presentedViewController))")
            print("DisplayUtils - Display Update require screen with top view controller: \(topViewController)")
            let viewController = UpdateRequireViewController.viewControllerFromXIB()
            viewController.modalPresentationStyle = .fullScreen
            topViewController.present(viewController, animated: false)
        } else {
            print("DisplayUtils - Can not display Update require screen - no top view controller")
        }
    }
}
