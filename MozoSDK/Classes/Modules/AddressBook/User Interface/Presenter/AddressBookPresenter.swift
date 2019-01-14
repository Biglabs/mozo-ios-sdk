//
//  AddressBookPresenter.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation
class AddressBookPresenter : NSObject {
    var abInteractor : AddressBookInteractorInput?
    var abWireframe : AddressBookWireframe?
    var abModuleDelegate : AddressBookModuleDelegate?
    var abUserInterface: AddressBookViewInterface?
}
extension AddressBookPresenter : AddressBookModuleInterface {
    func selectAddressBookOnUI(_ addressBook: AddressBookDisplayItem, isDisplayForSelect: Bool) {
        abModuleDelegate?.addressBookModuleDidChooseItemOnUI(addressBook: addressBook, isDisplayForSelect: isDisplayForSelect)
    }
    func updateDisplayData(forAddressBook: Bool) {
        if forAddressBook {
            abInteractor?.getListAddressBook()
        } else {
            abInteractor?.getListStoreBook()
        }
    }
}
extension AddressBookPresenter: AddressBookInteractorOutput {
    func finishGetListAddressBook(_ addressBook: [AddressBookDTO]) {
        if addressBook.count > 0 {
            let collection = AddressBookDisplayCollection(items: addressBook)
            let data = collection.collectedDisplayData()
            abUserInterface?.showAddressBookDisplayData(data, allItems: collection.displayItems)
        } else {
            abUserInterface?.showNoContentMessage()
        }
    }
    
    func finishGetListStoreBook(_ storeBook: [StoreBookDTO]) {
        if storeBook.count > 0 {
            let collection = AddressBookDisplayCollection(items: storeBook)
            let data = collection.collectedDisplayData()
            abUserInterface?.showAddressBookDisplayData(data, allItems: collection.displayItems)
        } else {
            abUserInterface?.showNoContentMessage()
        }
    }
}
