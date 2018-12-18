//
//  AddressBookDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/2/18.
//

import Foundation

struct AddressBookDisplayItem {
    let id : Int64
    let name : String
    let address : String
}

extension AddressBookDisplayItem : Equatable {
    static func == (leftSide: AddressBookDisplayItem, rightSide: AddressBookDisplayItem) -> Bool {
        return rightSide.name == leftSide.name && rightSide.address == rightSide.address
    }
}
