//
//  ABEditPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation
class ABEditPresenter : NSObject {
    var editInteractor : ABEditInteractorInput?
    var editUserInterface: ABEditViewInterface?
    var editWireframe : ABEditWireframe?
}
extension ABEditPresenter : ABEditModuleInterface {
    func requestDeleteAddressBook(_ addressBook: AddressBookDisplayItem) {
        editUserInterface?.displaySpinner()
        editInteractor?.deleteAddressBook(addressBook)
    }
    
    func requestUpdateAddressBook(_ addressBook: AddressBookDisplayItem, updateName: String) {
        editUserInterface?.displaySpinner()
        editInteractor?.updateAddressBook(addressBook)
    }
    
    func finishEditAddressBook() {
        editWireframe?.dismissAddressBookEditInterface()
    }
}
extension ABEditPresenter : ABEditInteractorOutput {
    func finishUpdate() {
        editUserInterface?.removeSpinner()
        editUserInterface?.displaySuccess()
    }
    
    func finishDelete() {
        editUserInterface?.removeSpinner()
        editUserInterface?.displaySuccess()
    }
    
    func didReceiveError(_ error: ConnectionError, forDelete: Bool) {
        editUserInterface?.removeSpinner()
        editUserInterface?.displayTryAgain(error, forDelete: forDelete)
    }
}
