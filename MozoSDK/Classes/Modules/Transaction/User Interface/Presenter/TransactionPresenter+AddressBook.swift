//
//  TransactionPresenter+AddressBook.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/19.
//

import Foundation
extension TransactionPresenter: ABSupportInteractorOutput {
    func didFindContact(_ addressBook: AddressBookDisplayItem) {
        transferUserInterface?.removeSpinner()
        transferUserInterface?.updateInterfaceWithDisplayItem(addressBook)
    }
    
    func contactNotFound(_ phoneNo: String) {
        transferUserInterface?.removeSpinner()
        transferUserInterface?.notFoundContact(phoneNo)
    }
    
    func errorWhileFindingContact(_ phoneNo: String, error: ConnectionError) {
        transferUserInterface?.removeSpinner()
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        if (DisplayUtils.getTopViewController() as? TransferViewInterface) != nil {
            searchPhoneNo = phoneNo
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: error, delegate: self)
        }
    }
}
extension TransactionPresenter {
    func findContact(_ phoneNo: String) {
        transferUserInterface?.displaySpinner()
        txInteractor?.findContact(phoneNo)
    }
}
extension TransactionPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let phoneNo = searchPhoneNo {
            self.findContact(phoneNo)
        }
    }
    
    func didClosePopupWithoutRetry() {
        searchPhoneNo = nil
    }
}
