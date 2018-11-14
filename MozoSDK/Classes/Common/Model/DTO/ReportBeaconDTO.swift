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
    
    public var beaconInfoDTOList: [BeaconInfoDTO]?
    public var status: ReportBeaconStatus?
    
    public required init(beaconInfoDTOList: [BeaconInfoDTO], status: Bool){
        self.beaconInfoDTOList = beaconInfoDTOList
        self.status = status ? .ON : .OFF
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let beaconInfoDTOList = self.beaconInfoDTOList {
            json["beaconInfoDTOList"] = beaconInfoDTOList.map({$0.toJSON()})
        }
        if let status = self.status {
            json["status"] = status.rawValue
        }
        return json
    }
}
