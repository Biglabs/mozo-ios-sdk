//
//  TxHistoryModuleInterface.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation

protocol TxHistoryModuleInterface {
    func selectTxHistoryOnUI(_ txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO)
    func updateDisplayData(page: Int, type: TransactionType)
    func loadTokenInfo()
}
