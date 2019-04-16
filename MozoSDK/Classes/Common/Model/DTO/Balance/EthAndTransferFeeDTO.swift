//
//  EthAndTransferFeeDTO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 4/12/19.
//

import Foundation
import SwiftyJSON

public class EthAndTransferFeeDTO: ResponseObjectSerializable {
    public var balanceOfETH: TokenInfoDTO?
    public var feeTransferERC20: NSNumber?
    
    public required init?(json: SwiftyJSON.JSON) {
        self.balanceOfETH = TokenInfoDTO(json: json["balanceOfETH"])
        self.feeTransferERC20 = json["feeTransferERC20"].number
    }
    
    public required init?(){}
    
    public func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let balanceOfETH = self.balanceOfETH {
            json["balanceOfETH"] = balanceOfETH.toJSON()
        }
        if let feeTransferERC20 = self.feeTransferERC20 {
            json["feeTransferERC20"] = feeTransferERC20
        }
        return json
    }
}
