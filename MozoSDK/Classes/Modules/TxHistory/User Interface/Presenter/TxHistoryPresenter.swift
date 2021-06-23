//
//  TxHistoryPresenter.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation

class TxHistoryPresenter : NSObject {
    var txhInteractor : TxHistoryInteractorInput?
    var txhWireframe : TxHistoryWireframe?
    var txhModuleDelegate : TxHistoryModuleDelegate?
    var txhUserInterface: TxHistoryViewInterface?
}
extension TxHistoryPresenter : TxHistoryModuleInterface {
    func selectTxHistoryOnUI(_ txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        txhModuleDelegate?.txHistoryModuleDidChooseItemOnUI(txHistory: txHistory, tokenInfo: tokenInfo)
    }
    
    func loadTokenInfo() {
        txhInteractor?.getTokenInfoForHistory()
    }
    
    func updateDisplayData(page: Int, type: TransactionType) {
        txhInteractor?.getListTxHistory(page: page, type: type)
    }
}
extension TxHistoryPresenter: TxHistoryInteractorOutput {
    func finishGetTokenInfo(_ tokenInfo: TokenInfoDTO) {
        txhUserInterface?.didReceiveTokenInfo(tokenInfo)
    }
    
    func errorWhileLoadTokenInfo(error: Error) {
        
    }
    
    func finishGetListTxHistory(_ txHistories: [TxHistoryDTO], forPage: Int) {
        let collection = TxHistoryDisplayCollection(items: txHistories)
        txhUserInterface?.showTxHistoryDisplayData(collection, forPage: forPage)
    }
    
    func errorWhileLoadTxHistory(_ error: ConnectionError) {
        txhUserInterface?.displayTryAgain(error)
    }
}
