//
//  AirdropEventDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/3/18.
//

import Foundation
import SwiftyJSON

public class AirdropEventDTO {
    public var active: Bool?
    public var address: String?
    public var airdropFreq: Int?
    public var appliedDateOfWeek: [Int]?
    public var beaconInfoId: Int?
    public var hourOfDayFrom: Int?
    public var hourOfDayTo: Int?
    public var id: Int?
    public var mozoAirdropPerCustomerVisit: Int?
    public var receivedShopper: Int?
    public var name: String?
    public var periodFromDate: Int?
    public var periodToDate: Int?
    public var smartAddress: String?
    public var stayIn: Int?
    public var totalNumMozoOffchain: Int64?
    
    public init?(name: String, address: String, receivedShopper: Int,
                          mozoAirdropPerCustomerVisit: Int, airdropFreq: Int,
                          hourOfDayFrom: Int, hourOfDayTo: Int,
                          periodFromDate: Int, periodToDate: Int,
                          totalNumMozoOffchain: Int64){
        self.name = name
        self.address = address
        self.receivedShopper = receivedShopper
        self.mozoAirdropPerCustomerVisit = mozoAirdropPerCustomerVisit
        self.airdropFreq = airdropFreq
        self.hourOfDayFrom = hourOfDayFrom
        self.hourOfDayTo = hourOfDayTo
        self.periodFromDate = periodFromDate
        self.periodToDate = periodToDate
        self.totalNumMozoOffchain = totalNumMozoOffchain
    }

    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let name = self.name {
            json["name"] = name
        }
        if let address = self.address {
            json["address"] = address
        }
        if let receivedShopper = self.receivedShopper {
            json["receivedShopper"] = receivedShopper
        }
        if let mozoAirdropPerCustomerVisit = self.mozoAirdropPerCustomerVisit {
            json["mozoAirdropPerCustomerVisit"] = mozoAirdropPerCustomerVisit
        }
        if let airdropFreq = self.airdropFreq {
            json["airdropFreq"] = airdropFreq
        }
        if let hourOfDayFrom = self.hourOfDayFrom {
            json["hourOfDayFrom"] = hourOfDayFrom
        }
        if let hourOfDayTo = self.hourOfDayTo {
            json["hourOfDayTo"] = hourOfDayTo
        }
        if let periodFromDate = self.periodFromDate {
            json["periodFromDate"] = periodFromDate
        }
        if let periodToDate = self.periodToDate {
            json["periodToDate"] = periodToDate
        }
        if let totalNumMozoOffchain = self.totalNumMozoOffchain {
            json["totalNumMozoOffchain"] = totalNumMozoOffchain
        }
        return json
    }
}
