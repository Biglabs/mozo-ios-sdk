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
    
    func updateDisplayData(page: Int) {
        txhInteractor?.getListTxHistory(page: page)
    }
}
extension TxHistoryPresenter: TxHistoryInteractorOutput {
    func finishGetTokenInfo(_ tokenInfo: TokenInfoDTO) {
        txhUserInterface?.didReceiveTokenInfo(tokenInfo)
    }
    
    func errorWhileLoadTokenInfo(error: String) {
        txhUserInterface?.displayError(error)
    }
    
    func finishGetListTxHistory(_ txHistories: [TxHistoryDTO], forPage: Int) {
        if txHistories.count > 0 {
            let collection = TxHistoryDisplayCollection(items: txHistories)
            txhUserInterface?.showTxHistoryDisplayData(collection, forPage: forPage)
        } else {
            txhUserInterface?.showNoContentMessage()
        }
    }
    
    func errorWhileLoadTxHistory(_ error: ConnectionError) {
        txhUserInterface?.displayTryAgain(error)
    }
}
