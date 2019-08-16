//
//  TodoDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/15/19.
//

import Foundation
public class TodoDisplayCollection {
    public var displayItems: [TodoDisplayItem] = []
    
    public init(items: [TodoDTO]) {
        displayItems = items.map { TodoDisplayItem(dto: $0) }
    }
}
