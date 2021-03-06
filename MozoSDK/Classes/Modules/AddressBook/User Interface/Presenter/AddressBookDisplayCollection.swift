//
//  AddressBookDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/2/18.
//

import Foundation
let ALPHABET_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
class AddressBookDisplayCollection {
    var displayItems : [AddressBookDisplayItem]
    
    init(items: [AddressBookDTO]) {
        displayItems = []
        for item in items {
            let displayItem = AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.soloAddress ?? "", physicalAddress: "", isStoreBook: false, phoneNo: item.phoneNo ?? "")
            displayItems.append(displayItem)
        }
    }
    
    init(items: [StoreBookDTO]) {
        displayItems = []
        for item in items {
            let displayItem = AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.offchainAddress ?? "", physicalAddress: item.physicalAddress ?? "", isStoreBook: true, phoneNo: item.phoneNo ?? "")
            displayItems.append(displayItem)
        }
    }
    
    func collectedDisplayData() -> AddressBookDisplayData {
        let collectedSections : [AddressBookDisplaySection] = sortedAddressBookDisplaySections()
        return AddressBookDisplayData(sections: collectedSections)
    }
    
    func sortedAddressBookDisplaySections() -> [AddressBookDisplaySection] {
        var displaySections : [AddressBookDisplaySection] = []
        let sortedItems = displayItems.sorted { $0.name < $1.name }
        
        let characters = ALPHABET_CHARACTERS.localized
        for char in characters {
            let prefix = String(char)
            let filteredArr = sortedItems.filter() { $0.name.hasPrefix(prefix, caseSensitive: true) }
            if filteredArr.count > 0 {
                let section = AddressBookDisplaySection(sectionName: prefix, items: filteredArr)
                displaySections.append(section)
            }
        }
        
        let nonPopularArray = sortedItems.filter { (item) -> Bool in
            if let character = item.name.uppercased().first {
                return !characters.contains(character)
            }
            return false
        }
        if nonPopularArray.count > 0 {
            let section = AddressBookDisplaySection(sectionName: "#", items: nonPopularArray)
            displaySections.append(section)
        }
        
        return displaySections
    }
    
    func addressBookItemFromId(_ id: Int64) -> AddressBookDisplayItem? {
        let item = displayItems.filter({ $0.id == id }).first
        return item
    }
    
    func sortByName() {
        displayItems = displayItems.sorted { $0.name < $1.name }
    }
}
