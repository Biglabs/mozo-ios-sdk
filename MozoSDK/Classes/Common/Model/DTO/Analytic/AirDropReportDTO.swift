//
//  AirDropReportDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/21/19.
//

import Foundation
import SwiftyJSON

public class AirDropReportDTO {
    public var airdropDetailsId: Int64?
    public var airdropFreq: Int?
    public var amountOfReceived: NSNumber?
    public var appliedDateOfWeek: [Int]?
    public var beaconInfoId: Int64?
    public var createdOn: Int64?
    public var decimals: Int?
    public var eventStatus: String?
    public var hourOfDayFrom: Int?
    public var hourOfDayTo: Int?
    public var id: Int64?
    public var mozoAirdropPerCustomerVisit: NSNumber?
    public var name: String?
    public var numberOfReceivedShopper: Int?
    public var periodFromDate: Int64?
    public var periodToDate: Int64?
    public var salePersonUserId: String?
    public var smartAddress: String?
    public var stayIn: Int?
    public var symbol: String?
    public var totalNumMozoOffchain: NSNumber?
    public var userOffChainAddress: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.airdropDetailsId = json["airdropDetailsId"].int64
        self.airdropFreq = json["airdropFreq"].int
        self.amountOfReceived = json["amountOfReceived"].number
        self.appliedDateOfWeek = json["appliedDateOfWeek"].array?.map ({ $0.int ?? 0 })
        self.beaconInfoId = json["beaconInfoId"].int64
        self.createdOn = json["createdOn"].int64
        self.decimals = json["decimals"].int
        self.eventStatus = json["eventStatus"].string
        self.hourOfDayFrom = json["hourOfDayFrom"].int
        self.hourOfDayTo = json["hourOfDayTo"].int
        self.id = json["id"].int64
        self.mozoAirdropPerCustomerVisit = json["mozoAirdropPerCustomerVisit"].number
        self.name = json["name"].string
        self.numberOfReceivedShopper = json["numberOfReceivedShopper"].int
        self.periodFromDate = json["periodFromDate"].int64
        self.periodToDate = json["periodToDate"].int64
        self.salePersonUserId = json["salePersonUserId"].string
        self.smartAddress = json["smartAddress"].string
        self.stayIn = json["stayIn"].int
        self.symbol = json["symbol"].string
        self.totalNumMozoOffchain = json["totalNumMozoOffchain"].number
        self.userOffChainAddress = json["userOffChainAddress"].string
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        let json = Dictionary<String, Any>()
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [AirDropReportDTO] {
        let array = json.array?.map({ AirDropReportDTO(json: $0)! })
        return array ?? []
    }
}
