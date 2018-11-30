//
//  MozoWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/18.
//

import Foundation

class MozoWireframe: NSObject {
    var rootWireframe : RootWireframe?
    
    func dismissModuleInterface(){
        
    }
    
    func presentWaitingInterface() {
        let viewController = waitingViewControllerFromStoryboard()
        rootWireframe?.showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
    }
    
    func waitingViewControllerFromStoryboard() -> MozoBasicViewController {
        let storyboard = StoryboardManager.mozoStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: WaitingViewControllerIdentifier) as! WaitingViewController
        return viewController
    }
    
    public func getTopViewController() -> UIViewController! {
        return rootWireframe?.getTopViewController()
    }
    
    public func viewControllerFromStoryBoard(_ identifier: String) -> UIViewController {
        let storyboard = StoryboardManager.mozoStoryboard()
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return viewController
    }
}
