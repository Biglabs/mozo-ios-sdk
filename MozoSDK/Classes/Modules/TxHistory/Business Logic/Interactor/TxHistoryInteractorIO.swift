//
//  TxHistoryInteractorIO.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation

protocol TxHistoryInteractorInput {
    func getListTxHistory(page: Int)
    func getTokenInfoForHistory()
}

protocol TxHistoryInteractorOutput {
    func finishGetListTxHistory(_ txHistories: [TxHistoryDTO], forPage: Int)
    func finishGetTokenInfo(_ tokenInfo: TokenInfoDTO)
    func errorWhileLoadTokenInfo(error: Error)
    func errorWhileLoadTxHistory(_ error: ConnectionError)
}
