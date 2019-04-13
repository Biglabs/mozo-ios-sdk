//
//  FullOffchainTokenInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/11/19.
//

import Foundation
import SwiftyJSON

public class OffchainInfoDTO: ResponseObjectSerializable {
    public var balanceOfTokenOffchain: TokenInfoDTO?
    public var balanceOfTokenOnchain: TokenInfoDTO?
    public var convertToMozoXOnchain: Bool?
    public var detectedOnchain: Bool?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.balanceOfTokenOffchain = TokenInfoDTO(json: json["balanceOfTokenOffchain"])
        self.balanceOfTokenOnchain = TokenInfoDTO(json: json["balanceOfTokenOnchain"])
        self.convertToMozoXOnchain = json["convertToMozoXOnchain"].bool
        self.detectedOnchain = json["detectedOnchain"].bool
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let balanceOfTokenOffchain = self.balanceOfTokenOffchain {
            json["balanceOfTokenOffchain"] = balanceOfTokenOffchain.toJSON()
        }
        if let balanceOfTokenOnchain = self.balanceOfTokenOnchain {
            json["balanceOfTokenOnchain"] = balanceOfTokenOnchain.toJSON()
        }
        if let convertToMozoXOnchain = self.convertToMozoXOnchain {
            json["convertToMozoXOnchain"] = convertToMozoXOnchain
        }
        if let detectedOnchain = self.detectedOnchain {
            json["detectedOnchain"] = detectedOnchain
        }
        return json
    }
}
