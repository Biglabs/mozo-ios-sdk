//
//  TodoDisplayCollection.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/15/19.
//

import Foundation
public class TodoDisplayCollection {
    public var displayItems: [TodoDTO] = []
    
    public init(items: [TodoDTO]) {
        displayItems = items
    }
}
