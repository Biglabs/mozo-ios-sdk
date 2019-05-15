//
//  MaintenanceViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/14/19.
//

import Foundation
import UIKit
let MaintenanceViewControllerIdentifier = "MaintenanceViewController"
class MaintenanceViewController: UIViewController {
    let eventHandler = MaintenancePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
extension MaintenanceViewController {
    public static func viewControllerFromStoryboard() -> MaintenanceViewController {
        let storyboard = StoryboardManager.mozoStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: MaintenanceViewControllerIdentifier) as! MaintenanceViewController
        return viewController
    }
}
