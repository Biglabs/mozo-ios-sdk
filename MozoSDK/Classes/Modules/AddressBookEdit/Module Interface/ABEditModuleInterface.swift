//
//  ABEditModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

protocol ABEditModuleInterface {
    func requestDeleteAddressBook(_ addressBook: AddressBookDisplayItem)
    func requestUpdateAddressBook(_ addressBook: AddressBookDisplayItem, updateName: String)
    func finishEditAddressBook()
}
