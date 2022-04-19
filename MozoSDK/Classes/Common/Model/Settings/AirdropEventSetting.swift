//
//  AirdropEventSetting.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/28/19.
//

import Foundation
import SwiftyJSON

public class AirdropEventSettingDTO : ResponseObjectSerializable {
    public var numberOfShopper: Int64?
    public var minNumberOfShopper: Int64?
    public var maxNumberOfShopper: Int64?
    public var numberMozoXAirdropPerShopper: NSNumber?
    public var minNumberMozoXAirdropPerShopper: NSNumber?
    public var maxNumberMozoXAirdropPerShopper: NSNumber?
    public var symbol: String?
    public var decimals: Int?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.numberOfShopper = json["numberOfShopper"].int64
        self.minNumberOfShopper = json["minNumberOfShopper"].int64
        self.maxNumberOfShopper = json["maxNumberOfShopper"].int64
        self.numberMozoXAirdropPerShopper = json["numberMozoXAirdropPerShopper"].number
        self.minNumberMozoXAirdropPerShopper = json["minNumberMozoXAirdropPerShopper"].number
        self.maxNumberMozoXAirdropPerShopper = json["maxNumberMozoXAirdropPerShopper"].number
        self.symbol = json["symbol"].string
        self.decimals = json["decimals"].int
    }
}
