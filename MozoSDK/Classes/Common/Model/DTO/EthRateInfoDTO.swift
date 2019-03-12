//
//  EthRateInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
import SwiftyJSON

public class EthRateInfoDTO: ResponseObjectSerializable {
    public var eth: RateInfoDTO?
    public var token: RateInfoDTO?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.eth = RateInfoDTO(json: json["eth"])
        self.token = RateInfoDTO(json: json["token"])
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let eth = self.eth {
            json["eth"] = eth.toJSON()
        }
        if let token = self.token {
            json["token"] = token.toJSON()
        }
        return json
    }
}
