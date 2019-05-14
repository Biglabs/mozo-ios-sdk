//
//  NotiDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/16/18.
//

import Foundation
public struct NotiDisplayItem {
    public let event: NotificationEventType
    public let title : String
    public let subTitle : String
    public let body: String
    public let image: String
    
    public let actionText: String
    public let amountText: String
    public let detailText: String
    
    public let summaryArgumentCount: Int
    public let categoryType: NotificationCategoryType
}
