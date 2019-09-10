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
    let phoneNo: String
    
    init(id: Int64 = 0, name: String = "", address: String = "", physicalAddress: String = "", isStoreBook: Bool = false, phoneNo: String = "") {
        self.id = id
        self.name = name
        self.address = address
        self.physicalAddress = physicalAddress
        self.isStoreBook = isStoreBook
        self.phoneNo = phoneNo
    }
    
    init(dto: AddressBookDTO) {
        self.id = dto.id ?? 0
        self.name = dto.name ?? ""
        self.address = dto.soloAddress ?? ""
        self.physicalAddress = ""
        self.isStoreBook = false
        self.phoneNo = dto.phoneNo ?? ""
    }
}

extension AddressBookDisplayItem : Equatable {
    public static func == (leftSide: AddressBookDisplayItem, rightSide: AddressBookDisplayItem) -> Bool {
        return rightSide.name == leftSide.name && rightSide.address == rightSide.address
    }
}
