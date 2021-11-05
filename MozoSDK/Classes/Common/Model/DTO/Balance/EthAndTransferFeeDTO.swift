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
    
    func getMissingEthAmount() -> Double {
        /*
         val balance = balanceOfETH?.balance.safe()
                 val missing = feeTransferERC20.safe() - balance
                 return Support.toAmountNonDecimal(
                     missing,
                     balanceOfETH?.decimals ?: 18 //WEI -> ETH
                 )
         */
        let balance: NSDecimalNumber = NSDecimalNumber(decimal: balanceOfETH?.balance?.decimalValue ?? 0)
        let missing: NSDecimalNumber = NSDecimalNumber(decimal: feeTransferERC20?.decimalValue ?? 0).subtracting(balance)
        
        
//        let feeDecimalNumber = NSDecimalNumber(decimal: (info.feeTransferERC20 ?? 0).decimalValue)
//        let ethBalanceDecimalNumber = NSDecimalNumber(decimal: (info.balanceOfETH?.balance ?? 0).decimalValue)
//        let result = feeDecimalNumber.subtracting(ethBalanceDecimalNumber)
        return missing.convertOutputValue(decimal: balanceOfETH?.decimals ?? 18 /*WEI -> ETH*/)
    }
    
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
