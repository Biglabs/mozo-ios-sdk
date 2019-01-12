//
//  AddressBookInteractorIO.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation

protocol AddressBookInteractorInput {
    func getListAddressBook()
    func getListStoreBook()
}

protocol AddressBookInteractorOutput {
    func finishGetListAddressBook(_ addressBook: [AddressBookDTO])
    func finishGetListStoreBook(_ storeBook: [StoreBookDTO])
}
