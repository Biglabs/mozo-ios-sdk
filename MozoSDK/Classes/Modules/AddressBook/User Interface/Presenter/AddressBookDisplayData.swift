//
//  AddressBookDisplayData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/2/18.
//

import Foundation

struct AddressBookDisplayData {
    let sections : [AddressBookDisplaySection]
    
    public func filterByText(_ text: String) -> [AddressBookDisplaySection] {
        var filteredSections : [AddressBookDisplaySection] = []
        for section in sections {
            let filteredItems = section.items.filter({( item : AddressBookDisplayItem) -> Bool in
                let contain = item.name.lowercased().contains(text.lowercased())
                return contain
            })
            if filteredItems.count > 0 {
                let rSection = AddressBookDisplaySection(sectionName: section.sectionName, items: filteredItems)
                filteredSections.append(rSection)
            }
        }
        return filteredSections
    }
    
    public func selectIndexTitles() -> [String]{
        let sectionTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
        return sectionTitles
    }
}

extension AddressBookDisplayData : Equatable {
    static func == (leftSide: AddressBookDisplayData, rightSide: AddressBookDisplayData) -> Bool {
        return rightSide.sections == leftSide.sections
    }
}
