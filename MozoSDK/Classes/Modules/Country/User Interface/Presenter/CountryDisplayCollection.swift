//
//  CountryDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation

public class CountryDisplayCollection: NSObject {
    public var displayItems: [CountryDisplayItem] = []
    
    public init(items: [CountryCodeDTO]) {
        displayItems = items.map { CountryDisplayItem(item: $0) }
    }
    
    public init(displayItems: [CountryDisplayItem]) {
        self.displayItems = displayItems
    }
}
