//
//  PaymentQRInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
class PaymentQRInteractor: NSObject {
    var output: PaymentQRInteractorOutput?
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
}
extension PaymentQRInteractor: PaymentQRInteractorInput {
    func validateValueFromScanner(_ scanValue: String) {
        if !scanValue.isEthAddress() {
            output?.didReceiveError("Scanning value is not a valid address. \n\(scanValue)")
        } else {
            let list = SafetyDataManager.shared.addressBookList
            if let addressBook = AddressBookDTO.addressBookFromAddress(scanValue, array: list) {
                let displayItem = AddressBookDisplayItem(id: addressBook.id!, name: addressBook.name!, address: addressBook.soloAddress!)
                output?.didReceiveAddressBookDisplayItem(displayItem)
            } else {
                output?.didReceiveAddressFromScannedValue(address: scanValue)
            }
        }
    }
    
    func sendPaymentRequest(toAddress: String, item: PaymentRequestDisplayItem) {
        output?.didSendPaymentRequestSuccess(toAddress: toAddress, item: item)
    }
}
