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
    public var beaconInfoId: Int64?
    public var hourOfDayFrom: Int?
    public var hourOfDayTo: Int?
    public var id: Int64?
    public var mozoAirdropPerCustomerVisit: NSNumber?
    public var receivedShopper: Int64?
    public var name: String?
    public var periodFromDate: Int64?
    public var periodToDate: Int64?
    public var smartAddress: String?
    public var stayIn: Int?
    public var totalNumMozoOffchain: NSNumber?
    public var actualAirdroppedTime: Int?
    public var symbol: String?
    public var decimals: Int?
    
    public var eventStatus: String?
    public var ownerCreateEvent: Bool?
    
    public init?(name: String, address: String, receivedShopper: Int64,
                  mozoAirdropPerCustomerVisit: NSNumber, airdropFreq: Int,
                  hourOfDayFrom: Int, hourOfDayTo: Int,
                  periodFromDate: Int64, periodToDate: Int64,
                  totalNumMozoOffchain: NSNumber, active: Bool,
                  beaconInfoId: Int64, appliedDateOfWeek: [Int]){
        self.active = active
        self.name = name
        self.address = address
        self.beaconInfoId = beaconInfoId
        self.receivedShopper = receivedShopper
        self.mozoAirdropPerCustomerVisit = mozoAirdropPerCustomerVisit
        self.airdropFreq = airdropFreq
        self.hourOfDayFrom = hourOfDayFrom
        self.hourOfDayTo = hourOfDayTo
        self.periodFromDate = periodFromDate
        self.periodToDate = periodToDate
        self.totalNumMozoOffchain = totalNumMozoOffchain
        self.appliedDateOfWeek = appliedDateOfWeek
    }
    
    public init?(smartAddress: String, totalNumMozoOffchain: NSNumber){
        self.smartAddress = smartAddress
        self.totalNumMozoOffchain = totalNumMozoOffchain
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.active = json["active"].bool
        self.name = json["name"].string
        self.address = json["address"].string
        self.receivedShopper = json["receivedShopper"].int64
        self.mozoAirdropPerCustomerVisit = json["mozoAirdropPerCustomerVisit"].number
        self.airdropFreq = json["airdropFreq"].int
        self.hourOfDayFrom = json["hourOfDayFrom"].int
        self.hourOfDayTo = json["hourOfDayTo"].int
        self.id = json["id"].int64
        self.periodFromDate = json["periodFromDate"].int64
        self.periodToDate = json["periodToDate"].int64
        self.totalNumMozoOffchain = json["totalNumMozoOffchain"].number
        self.appliedDateOfWeek = json["appliedDateOfWeek"].array?.map ({ $0.int ?? 0 })
        self.actualAirdroppedTime = json["actualAirdroppedTime"].int
        self.symbol = json["symbol"].string
        self.decimals = json["decimals"].int
        self.beaconInfoId = json["beaconInfoId"].int64
        self.smartAddress = json["smartAddress"].string
        self.stayIn = json["stayIn"].int
        self.eventStatus = json["eventStatus"].string
        self.ownerCreateEvent = json["ownerCreateEvent"].bool
    }

    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let id = self.id {
            json["id"] = id
        }
        if let active = self.active {
            json["active"] = active
        }
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
        if let appliedDateOfWeek = self.appliedDateOfWeek {
            json["appliedDateOfWeek"] = appliedDateOfWeek
        }
        if let actualAirdroppedTime = self.actualAirdroppedTime {
            json["actualAirdroppedTime"] = actualAirdroppedTime
        }
        if let decimals = self.decimals {
            json["decimals"] = decimals
        }
        if let symbol = self.symbol {
            json["symbol"] = symbol
        }
        if let beaconInfoId = self.beaconInfoId {
            json["beaconInfoId"] = beaconInfoId
        }
        if let smartAddress = self.smartAddress {
            json["smartAddress"] = smartAddress
        }
        if let eventStatus = self.eventStatus {
            json["eventStatus"] = eventStatus
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [AirdropEventDTO] {
        let array = json.array?.map({ AirdropEventDTO(json: $0)! })
        return array ?? []
    }
}
