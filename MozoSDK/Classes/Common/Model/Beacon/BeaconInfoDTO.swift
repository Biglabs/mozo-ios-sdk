//
//  BeaconInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/6/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import SwiftyJSON
public enum BeaconBranchSynchronizationStatus: String {
    case NO_NEED_TO_SYNC = "NO_NEED_TO_SYNC"
    case NEED_SYNC_ADDRESS = "NEED_SYNC_ADDRESS"
    case NEED_SYNC_LOCATION = "NEED_SYNC_LOCATION"
    case NEED_SYNC_BOTH = "NEED_SYNC_BOTH"
}
public class BeaconInfoDTO : ResponseObjectSerializable {
    public var broadcastingPower: Int8?
    public var distance: NSNumber?
    public var id: Int64?
    public var settingCurrentStep: Int?
    public var settingTotalStep: Int?
    public var finishedConfiguration: Bool?
    public var latitude: NSNumber?
    public var longitude: NSNumber?
    public var macAddress: String?
    public var major: Int64?
    public var measuredPower: Int8?
    public var minor: Int64?
    public var rssi: Int?
    public var storeInfoId: Int64?
    public var uuId: String?
    public var zoneId: String?
    
    public var name: String?
    
    public var branchId: Int64?
    public var address: String?
    public var beaconBranchSyncStatus: BeaconBranchSynchronizationStatus?
    
    public required init(macAddress: String, name: String){
        self.macAddress = macAddress
        self.name = name
    }
    
    public required init(macAddress: String, address: String){
        self.macAddress = macAddress
        self.address = address
    }
    
    public required init(macAddress: String){
        self.macAddress = macAddress
    }
    
    public required init(name: String){
        self.name = name
    }
    
    public required init(macAddress: String, latitude: NSNumber, longitude: NSNumber){
        self.macAddress = macAddress
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public required init(macAddress: String, address: String, latitude: NSNumber, longitude: NSNumber){
        self.macAddress = macAddress
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public required init?(name: String, distance: NSNumber, major: Int64, minor: Int64, rssi: Int, uuid: String, macAddress: String, measuredPower: Int8, branchId: Int64) {
        self.name = name
        self.distance = distance
        self.major = major
        self.minor = minor
        self.rssi = rssi
        self.uuId = uuid
        self.macAddress = macAddress
        self.measuredPower = measuredPower
        self.branchId = branchId
    }
    
    public required init?(distance: NSNumber, major: Int64, minor: Int64, rssi: Int, uuid: String, macAddress: String, measuredPower: Int8) {
        self.distance = distance
        self.major = major
        self.minor = minor
        self.rssi = rssi
        self.uuId = uuid
        self.macAddress = macAddress
        self.measuredPower = measuredPower
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.name = json["name"].string
        self.broadcastingPower = json["broadcastingPower"].int8
        self.distance = json["distance"].number
        self.id = json["id"].int64
        self.settingCurrentStep = json["settingCurrentStep"].int
        self.settingTotalStep = json["settingTotalStep"].int
        self.finishedConfiguration = json["finishedConfiguration"].bool
        self.latitude = json["latitude"].number
        self.longitude = json["longitude"].number
        self.macAddress = json["macAddress"].string
        self.major = json["major"].int64
        self.measuredPower = json["measuredPower"].int8
        self.minor = json["minor"].int64
        self.rssi = json["rssi"].int
        self.storeInfoId = json["storeInfoId"].int64
        self.uuId = json["uuId"].string
        self.zoneId = json["zoneId"].string
        self.address = json["address"].string
        self.beaconBranchSyncStatus = BeaconBranchSynchronizationStatus(rawValue: json["beaconBranchSyncStatus"].string ?? "")
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let name = self.name {
            json["name"] = name
        }
        if let broadcastingPower = self.broadcastingPower {
            json["broadcastingPower"] = broadcastingPower
        }
        if let distance = self.distance {
            json["distance"] = distance
        }
        if let id = self.id {
            json["id"] = id
        }
        if let settingCurrentStep = self.settingCurrentStep {
            json["settingCurrentStep"] = settingCurrentStep
        }
        if let settingTotalStep = self.settingTotalStep {
            json["settingTotalStep"] = settingTotalStep
        }
        if let finishedConfiguration = self.finishedConfiguration {
            json["finishedConfiguration"] = finishedConfiguration
        }
        if let latitude = self.latitude {json["latitude"] = latitude}
        if let longitude = self.longitude {json["longitude"] = longitude}
        if let macAddress = self.macAddress {json["macAddress"] = macAddress}
        if let major = self.major {json["major"] = major}
        if let measuredPower = self.measuredPower {json["measuredPower"] = measuredPower}
        if let minor = self.minor {json["minor"] = minor}
        if let rssi = self.rssi {json["rssi"] = rssi}
        if let storeInfoId = self.storeInfoId {json["storeInfoId"] = storeInfoId}
        if let uuId = self.uuId {json["uuId"] = uuId}
        if let zoneId = self.zoneId {json["zoneId"] = zoneId}
        
        if let branchId = self.branchId {
            json["branchId"] = branchId
        }
        
        if let address = self.address {
            json["address"] = address
        }
        return json
    }
    
    public static func arrayFromJson(_ json: SwiftyJSON.JSON) -> [BeaconInfoDTO] {
        let array = json.array?.filter({ BeaconInfoDTO(json: $0) != nil }).map({ BeaconInfoDTO(json: $0)! })
        return array ?? []
    }
}
