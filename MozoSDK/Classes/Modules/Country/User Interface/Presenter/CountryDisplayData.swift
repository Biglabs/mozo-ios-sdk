//
//  CountryDisplayData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation
public struct CountryDisplayData {
    public var collection: CountryDisplayCollection
    
    public init(collection: CountryDisplayCollection = CountryDisplayCollection(items: [])) {
        self.collection = collection
    }
    
    public func filterByText(_ text: String) -> CountryDisplayCollection {
        let filteredItems = collection.displayItems.filter({( item : CountryDisplayItem) -> Bool in
            let contain = item.country.lowercased().contains(text.lowercased())
                || item.isoCode.lowercased().contains(text.lowercased())
                || item.countryCode.lowercased().contains(text.lowercased())
            return contain
        })
        return CountryDisplayCollection(displayItems: filteredItems)
    }
    
    public func findCountryByText(_ text: String) -> CountryDisplayItem? {
        let item = collection.displayItems.first(where: {( item : CountryDisplayItem) -> Bool in
            let contain = text.contains(item.countryCode)
            return contain
        })
        return item
    }
}
