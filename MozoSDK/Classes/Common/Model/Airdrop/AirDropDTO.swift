//
//  AirDropDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/12/18.
//

import Foundation
import SwiftyJSON

public class AirDropDTO : ResponseObjectSerializable {
    public var airDropColor: String?
    public var airDropAmount: Int?
    
    public required init?(amount: Int, color: String){
        self.airDropAmount = amount
        self.airDropColor = color
    }
    
    public required init?(json: SwiftyJSON.JSON) {
        self.airDropColor = json["airDropColor"].string
        self.airDropAmount = json["airDropAmount"].int
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let airDropColor = self.airDropColor {
            json["airDropColor"] = airDropColor
        }
        if let airDropAmount = self.airDropAmount {
            json["airDropAmount"] = airDropAmount
        }
        return json
    }
}
