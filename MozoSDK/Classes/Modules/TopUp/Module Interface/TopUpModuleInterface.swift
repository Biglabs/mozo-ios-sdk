//
//  TopUpModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/5/19.
//

import Foundation
protocol TopUpModuleInterface {
    func loadTokenInfo()
    func loadTopUpAddress()
    
    func validateTopUpTransferTransaction(tokenInfo: TokenInfoDTO, amount: String)
    func requestGetToken()
    func dismiss()
}
