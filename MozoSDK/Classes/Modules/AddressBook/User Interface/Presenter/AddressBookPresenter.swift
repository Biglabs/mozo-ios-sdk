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
    
    override init() {
        super.init()
        registerAddressBookChangedNotification()
    }
    
    func registerAddressBookChangedNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onAddressBookChanged(_:)), name: .didChangeAddressBook, object: nil)
    }
    
    @objc func onAddressBookChanged(_ notification: NSNotification) {
        print("AddressBookPresenter - On address book changed")
        abInteractor?.getListAddressBook()
    }
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
    
    func openImportContact() {
        abWireframe?.presentABImportInterface()
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
extension AddressBookPresenter: ABImportModuleDelegate {
    func didFinishImport() {
        abWireframe?.rootWireframe?.dismissTopViewController()
        abUserInterface?.showImportSuccess()
        updateDisplayData(forAddressBook: true)
    }
}
