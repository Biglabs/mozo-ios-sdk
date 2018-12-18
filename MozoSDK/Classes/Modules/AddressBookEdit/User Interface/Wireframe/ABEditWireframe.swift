//
//  ABEditWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation
class ABEditWireframe : MozoWireframe {
    var editPresenter : ABEditPresenter?
    var editViewController : ABEditViewController?
    
    func presentAddressBookEditInterface(_ addressBook: AddressBookDisplayItem) {
        let viewController = viewControllerFromStoryBoard(ABEditViewControllerIdentifier) as! ABEditViewController
        viewController.eventHandler = editPresenter
        viewController.displayItem = addressBook
        editViewController = viewController
        
        rootWireframe?.displayViewController(viewController)
    }
    
    func dismissAddressBookEditInterface() {
        rootWireframe?.dismissTopViewController()
    }
}
