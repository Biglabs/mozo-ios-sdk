//
//  DisplayUtils+Maintenance.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import AppAuth
extension DisplayUtils {
    public static func displayMaintenanceScreen() {
        print("DisplayUtils - Display maintenance screen")
        if let topViewController = getTopViewController() {
            if topViewController is MaintenanceViewController {
                print("DisplayUtils - Maintenence screen is being displayed.")
                return
            }
            if topViewController.isKind(of: NSClassFromString("SFAuthenticationViewController")!) {
                print("DisplayUtils - Authentication screen is being displayed.")
                return
            }
            print("DisplayUtils - topViewController - presentingViewController: \(String(describing: topViewController.presentingViewController))")
            print("DisplayUtils - topViewController - presentedViewController: \(String(describing: topViewController.presentedViewController))")
            print("DisplayUtils - Display maintenance screen with top view controller: \(topViewController)")
            let viewController = MaintenanceViewController.viewControllerFromStoryboard()
            topViewController.present(viewController, animated: false)
        } else {
            print("DisplayUtils - Can not display maintenance screen - no top view controller")
        }
    }
}
