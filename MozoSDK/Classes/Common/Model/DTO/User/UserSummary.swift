//
//  UserSummary.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/1/20.
//

import Foundation
import SwiftyJSON
public class UserSummary: ResponseObjectSerializable {
    var collectedMozo: NSNumber?
    public var unreadMessages: Int? = 0
    
    public required init?(json: JSON) {
        self.collectedMozo = json["collectedMozo"].number
        self.unreadMessages = json["unreadMessages"].int
    }
    
    public func todayCollected() -> Double {
        return collectedMozo?.convertOutputValue(decimal: SessionStoreManager.tokenInfo?.decimals ?? 0) ?? 0
    }
}
