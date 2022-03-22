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
        if let topViewController = getTopViewController() {
            if topViewController is MaintenanceViewController {
                print("DisplayUtils - Maintenence screen is being displayed.")
                return
            }
            if let klass = DisplayUtils.getAuthenticationClass(),
                topViewController.isKind(of: klass) {
                print("DisplayUtils - Authentication screen is being displayed.")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.displayMaintenanceScreen()
                }
                return
            }
            print("DisplayUtils - topViewController - presentingViewController: \(String(describing: topViewController.presentingViewController))")
            print("DisplayUtils - topViewController - presentedViewController: \(String(describing: topViewController.presentedViewController))")
            print("DisplayUtils - Display maintenance screen with top view controller: \(topViewController)")
            let viewController = MaintenanceViewController.viewControllerFromStoryboard()
            viewController.modalPresentationStyle = .fullScreen
            topViewController.present(viewController, animated: true)
        } else {
            print("DisplayUtils - Can not display maintenance screen - no top view controller")
        }
    }
}
