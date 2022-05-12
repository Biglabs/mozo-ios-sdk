//
//  PromoStatus.swift
//  MozoSDK
//
//  Created by Vu Nguyen on 17/12/2020.
//

import Foundation
import SwiftyJSON

public class PromoStatus {
    public var canBuyPromo: Bool = true
    public var durationCanBuy: Int64?
    public var lastBuyTime: Int64?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.canBuyPromo = json["canBuyPromo"].bool ?? true
        self.durationCanBuy = json["durationCanBuy"].int64
        self.lastBuyTime = json["lastBuyTime"].int64
    }
}
