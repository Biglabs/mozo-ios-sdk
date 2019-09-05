//
//  AddressBookWireframe.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation

class AddressBookWireframe : MozoWireframe {
    var abPresenter : AddressBookPresenter?
    var abImportWireframe: ABImportWireframe?
    var addressBookViewController : AddressBookViewController?
    
    func presentAddressBookInterface(isDisplayForSelect: Bool) {
        let viewController = viewControllerFromStoryBoard(AddressBookViewControllerIdentifier, storyboardName: Module.AddressBook.value) as! AddressBookViewController
        viewController.eventHandler = abPresenter
        addressBookViewController = viewController
        addressBookViewController?.isDisplayForSelect = isDisplayForSelect
        abPresenter?.abUserInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func dismissAddressBookInterface() {
        rootWireframe?.dismissTopViewController()
    }
    
    func presentABImportInterface() {
        abImportWireframe?.presentAddressBookImportInterface()
    }
}
