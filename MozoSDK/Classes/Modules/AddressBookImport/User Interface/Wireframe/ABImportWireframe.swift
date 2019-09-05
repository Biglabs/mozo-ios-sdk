//
//  ABImportWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
class ABImportWireframe: MozoWireframe {
    var presenter: ABImportPresenter?
    
    func presentAddressBookImportInterface() {
        let viewController = viewControllerFromStoryBoard(ABImportViewControllerIdentifier, storyboardName: Module.AddressBook.value) as! ABImportViewController
        viewController.eventHandler = presenter
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
}
