//
//  MaintenanceViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import UIKit
let MaintenanceViewControllerIdentifier = "MaintenanceViewControllers"
class MaintenanceViewController: UIViewController {
    
}
extension MaintenanceViewController {
    public static func passPhraseViewControllerFromStoryboard() -> MaintenanceViewController {
        let storyboard = StoryboardManager.mozoStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: MaintenanceViewControllerIdentifier) as! MaintenanceViewController
        return viewController
    }
}
