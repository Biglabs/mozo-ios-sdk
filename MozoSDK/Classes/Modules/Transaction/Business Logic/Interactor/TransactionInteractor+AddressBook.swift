//
//  TransactionInteractor+AddressBook.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/19.
//

import Foundation
extension TransactionInteractor: ABSupportInteractorInput {
    func findContact(_ phoneNo: String) {
        _ = apiManager.getAddressBookByPhoneNo(phoneNo).done({ (addressBook) in
            if let addressBook = addressBook, !(addressBook.soloAddress?.isEmpty ?? true) {
                let item = AddressBookDisplayItem(dto: addressBook)
                self.output?.didFindContact(item)
                return
            }
            self.output?.contactNotFound(phoneNo)
        }).catch({ (error) in
            self.output?.errorWhileFindingContact(phoneNo, error: error as? ConnectionError ?? .systemError)
        })
    }
}
