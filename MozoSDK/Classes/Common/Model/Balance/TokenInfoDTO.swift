//
//  TokenInfoDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/20/18.
//

import Foundation
import SwiftyJSON

public class TokenInfoDTO: ResponseObjectSerializable {
    
    public var address: String?
    public var balance: NSNumber?
    public var symbol: String?
    public var decimals: Int?
    public var contractAddress: String?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.address = json["address"].string
        self.balance = json["balance"].number
        self.symbol = json["symbol"].string
        self.decimals = json["decimals"].int
        self.contractAddress = json["contractAddress"].string
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let address = self.address {
            json["address"] = address
        }
        if let balance = self.balance {
            json["balance"] = balance
        }
        if let symbol = self.symbol {
            json["symbol"] = symbol
        }
        if let decimals = self.decimals {
            json["decimals"] = decimals
        }
        if let contractAddress = self.contractAddress {
            json["contractAddress"] = contractAddress
        }
        return json
    }
}

extension TokenInfoDTO : Equatable {
    public var safeDecimals: Int {
        return self.decimals ?? 2
    }
    
    public static func == (leftSide: TokenInfoDTO, rightSide: TokenInfoDTO) -> Bool {
        return rightSide.balance == leftSide.balance && rightSide.address == rightSide.address
    }
}

extension Optional where Wrapped == TokenInfoDTO {
    public var safeDecimals: Int {
        return self?.decimals ?? 2
    }
    
    public func displayBalance() -> Double {
        return self?.balance?.convertOutputValue(decimal: safeDecimals) ?? 0
    }
}
