//
//  SettingsWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
public class SettingsWireframe: NSObject {
    var presenter: SettingsPresenter?
    
    public override init() {
        super.init()
        presenter = SettingsPresenter()
    }
    
    public func presentSettingsInterface(rootNavigationController: UINavigationController) {
        let viewController = SettingsViewController()
        viewController.eventHandler = presenter
        rootNavigationController.pushViewController(viewController, animated: false)
    }    
}
