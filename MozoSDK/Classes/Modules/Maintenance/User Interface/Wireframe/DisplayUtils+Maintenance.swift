//
//  DisplayUtils+Maintenance.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
extension DisplayUtils {
    public static func displayMaintenanceScreen() {
        if let topViewController = getTopViewController() {
            if topViewController is MaintenanceViewController {
                print("Maintenence screen is being displayed.")
                return
            }
            let viewController = MaintenanceViewController.viewControllerFromStoryboard()
            topViewController.present(viewController, animated: false)
        }
    }
}
