//
//  VehicleInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/19.
//

import Foundation
import SwiftyJSON
public class VehicleInfoDTO: ResponseObjectSerializable {
    public var defaultValue: String?
    public var items: [VehicleDTO]?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.defaultValue = json["defaultValue"].string
        self.items = json["items"].array?.map({ VehicleDTO(json: $0)! })
    }
}
