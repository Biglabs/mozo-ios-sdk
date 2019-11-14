//
//  ReportBeaconDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/13/18.
//

import Foundation
import SwiftyJSON

public enum ReportBeaconStatus : String {
    case ON = "ON"
    case OFF = "OFF"
}

public class ReportBeaconDTO {
    public var beaconMacList: [String]?
    public var locale: String?
    public var status: ReportBeaconStatus?
    
    public required init(beaconInfoDTOList: [BeaconInfoDTO], status: Bool){
        self.beaconMacList = beaconInfoDTOList.map { $0.macAddress! }
        self.status = status ? .ON : .OFF
        self.locale = Configuration.LOCALE
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let beaconMacList = self.beaconMacList {
            json["beaconMacList"] = beaconMacList
        }
        if let status = self.status {
            json["status"] = status.rawValue
        }
        json["locale"] = self.locale
        return json
    }
    
    func rawString() -> String? {
        let json = JSON(self.toJSON())
        return json.rawString()
    }
}
