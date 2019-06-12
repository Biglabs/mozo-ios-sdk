//
//  SpeedSelectionWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
class SpeedSelectionWireframe: MozoWireframe {
    var presenter: SpeedSelectionPresenter?
    
    func presentSpeedSelectionInterface() {
        let viewController = viewControllerFromStoryBoard(SpeedSelectionViewControllerIdentifier, storyboardName: "SpeedSelection") as! SpeedSelectionViewController
        viewController.eventHandler = presenter
        rootWireframe?.displayViewController(viewController)
    }
}
