//
//  DetailInfoDisplayItem.swift
//  Alamofire
//
//  Created by Hoang Nguyen on 9/27/18.
//

import Foundation

public struct DetailInfoDisplayItem {
    public let balance : Double
    public let address: String
    
    init(balance: Double, address: String) {
        self.balance = balance
        self.address = address
    }
    
    init(tokenInfo: TokenInfoDTO) {
        self.balance = tokenInfo.balance?.convertOutputValue(decimal: tokenInfo.decimals ?? 0) ?? -1
        self.address = tokenInfo.address ?? ""
    }
}

extension DetailInfoDisplayItem : Equatable {
    public static func == (leftSide: DetailInfoDisplayItem, rightSide: DetailInfoDisplayItem) -> Bool {
        return rightSide.balance == leftSide.balance && rightSide.address == rightSide.address
    }
}
