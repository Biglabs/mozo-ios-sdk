//
//  MozoWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/18.
//

import Foundation

class MozoWireframe: NSObject {
    var rootWireframe : RootWireframe?
    private var isAutoPinPresenting = false
    
    func dismissModuleInterface() {
        ModuleDependencies.shared.corePresenter.requestForCloseAllMozoUIs(nil)
    }
    
    func presentWaitingInterface(autoPin: Bool = false, isCreateMode: Bool = false) {
        if !autoPin && SessionStoreManager.isWalletSafe() {
            // MARK: The wallet is ready, no need to display waiting
            return
        }
        let vc = viewControllerFromStoryBoard(WaitingViewControllerIdentifier) as! WaitingViewController
        vc.autoPin = autoPin
        vc.isCreateMode = isCreateMode
        rootWireframe?.displayViewController(vc)
    }
    
    func presentAutoPINInterface(needShowRoot: Bool = false) {
        let viewController = AutoPINViewController()
        if needShowRoot {
            rootWireframe?.showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
        } else {
            rootWireframe?.displayViewController(viewController)
        }
        isAutoPinPresenting = true
    }
    
    func dismissAutoPinIfNeed() {
        if isAutoPinPresenting || DisplayUtils.getTopViewController() is AutoPINViewController {
            dismissTopInterface()
            isAutoPinPresenting = false
        }
    }
    
    func dismissTopInterface() {
        rootWireframe?.dismissTopViewController()
    }
    
    public func viewControllerFromStoryBoard(_ identifier: String, storyboardName: String = "") -> UIViewController {
        let storyboard = StoryboardManager.mozoStoryboard(name: storyboardName)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController
    }
}
