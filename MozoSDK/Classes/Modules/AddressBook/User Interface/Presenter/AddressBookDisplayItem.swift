//
//  AddressBookDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/2/18.
//

import Foundation

public struct AddressBookDisplayItem {
    let id : Int64
    let name : String
    let address : String
    let physicalAddress: String
    let isStoreBook: Bool
}

extension AddressBookDisplayItem : Equatable {
    public static func == (leftSide: AddressBookDisplayItem, rightSide: AddressBookDisplayItem) -> Bool {
        return rightSide.name == leftSide.name && rightSide.address == rightSide.address
    }
}
