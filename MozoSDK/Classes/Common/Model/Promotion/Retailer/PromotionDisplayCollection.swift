//
//  PromotionDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/5/19.
//

import Foundation
public class PromotionDisplayCollection {
    public var displayItems : [PromotionDisplayItem] = []
    public var searchText: String?
    public var total: Int64?
    
    public init(items: [PromotionDTO]) {
        displayItems = items.map { PromotionDisplayItem(promotionDTO: $0) }
    }
    
    public func appendCollection(_ collection: PromotionDisplayCollection) {
        displayItems = displayItems + collection.displayItems
    }
}
