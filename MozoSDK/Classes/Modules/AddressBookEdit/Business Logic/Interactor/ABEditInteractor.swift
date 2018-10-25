//
//  ABEditInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

class ABEditInteractor : NSObject {
    var apiManager : ApiManager?
    var output: ABEditInteractorOutput?
}

extension ABEditInteractor: ABEditInteractorInput {
    func updateAddressBook(_ addressBook: AddressBookDisplayItem) {
        let model = AddressBookDTO(name: addressBook.name, address: addressBook.address)
        model.id = addressBook.id
        _ = apiManager?.updateAddressBook(model, isCreateNew: false).done({ (adrBook) in
            if let item = adrBook {
                AddressBookDTO.updateAddressBookName(item, array: &SafetyDataManager.shared.addressBookList)
            }
            self.output?.finishUpdate()
        }).catch({ (error) in
            self.output?.didReceiveError(error as! ConnectionError, forDelete: false)
        })
    }
    
    func deleteAddressBook(_ addressBook: AddressBookDisplayItem) {
        _ = apiManager?.deleteAddressBook(addressBook.id).done({ (result) in
            AddressBookDTO.removeAddressBook(addressBook.id, array: &SafetyDataManager.shared.addressBookList)
            self.output?.finishDelete()
        }).catch({ (error) in
            self.output?.didReceiveError(error as! ConnectionError, forDelete: true)
        })
    }
}
