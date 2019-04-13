//
//  OnchainInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/8/19.
//

import Foundation
import SwiftyJSON

public class OnchainInfoDTO: ResponseObjectSerializable {
    
    public var balanceOfToken: TokenInfoDTO?
    public var balanceOfETH: TokenInfoDTO?
    public var convertToMozoXOnchain: Bool?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.balanceOfToken = TokenInfoDTO(json: json["balanceOfToken"])
        self.balanceOfETH = TokenInfoDTO(json: json["balanceOfETH"])
        self.convertToMozoXOnchain = json["convertToMozoXOnchain"].bool
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let balanceOfToken = self.balanceOfToken {
            json["balanceOfToken"] = balanceOfToken.toJSON()
        }
        if let balanceOfETH = self.balanceOfETH {
            json["balanceOfETH"] = balanceOfETH.toJSON()
        }
        if let convertToMozoXOnchain = self.convertToMozoXOnchain {
            json["convertToMozoXOnchain"] = convertToMozoXOnchain
        }
        return json
    }
}
