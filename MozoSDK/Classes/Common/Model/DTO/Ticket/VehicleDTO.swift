//
//  VehicleDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/19.
//

import Foundation
import SwiftyJSON
public class VehicleDTO: ResponseObjectSerializable {
    public var key: String?
    public var name: String?
    public var image: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.key = json["key"].string
        self.name = json["name"].string
        self.image = json["image"].string
    }
}
