//
//  PaymentQRPresenter+AddressBook.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/19.
//

import Foundation
extension PaymentQRPresenter: ABSupportInteractorOutput {
    func didFindContact(_ addressBook: AddressBookDisplayItem) {
        viewInterface?.removeSpinner()
        viewInterface?.updateInterfaceWithDisplayItem(addressBook)
    }
    
    func contactNotFound(_ phoneNo: String) {
        viewInterface?.removeSpinner()
        viewInterface?.notFoundContact(phoneNo)
    }
    
    func errorWhileFindingContact(_ phoneNo: String, error: ConnectionError) {
        viewInterface?.removeSpinner()
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        if (DisplayUtils.getTopViewController() as? PaymentQRViewInterface) != nil {
            searchPhoneNo = phoneNo
            retryAction = .FindContact
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: error, delegate: self)
        }
    }
}
extension PaymentQRPresenter {
    func findContact(_ phoneNo: String) {
        viewInterface?.displaySpinner()
        interactor?.findContact(phoneNo)
    }
}
