//
//  MozoWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/18.
//

import Foundation

class MozoWireframe: NSObject {
    var rootWireframe : RootWireframe?
    
    func dismissModuleInterface() {
        let coreEventHandler = rootWireframe?.mozoNavigationController.coreEventHandler
        coreEventHandler?.requestForCloseAllMozoUIs(nil)
    }
    
    func presentWaitingInterface(corePresenter: CorePresenter?) {
        let viewController = viewControllerFromStoryBoard(WaitingViewControllerIdentifier) as! WaitingViewController
        corePresenter?.waitingViewInterface = viewController
        viewController.eventHandler = corePresenter
        rootWireframe?.showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
    }
    
    func presentAutoPINInterface(needShowRoot: Bool = false) {
        let viewController = AutoPINViewController()
        if needShowRoot {
            rootWireframe?.showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
        } else {
            rootWireframe?.displayViewController(viewController)
        }
    }
    
    public func getTopViewController() -> UIViewController! {
        return rootWireframe?.getTopViewController()
    }
    
    public func viewControllerFromStoryBoard(_ identifier: String, storyboardName: String = "") -> UIViewController {
        let storyboard = StoryboardManager.mozoStoryboard(name: storyboardName)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController
    }
}
