//
//  TxHistoryInteractor.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation

class TxHistoryInteractor: NSObject {
    var output: TxHistoryInteractorOutput?
    let apiManager : ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }
}
extension TxHistoryInteractor : TxHistoryInteractorInput {
    func getListTxHistory(page: Int = 0, type: TransactionType = .All) {
        if let userObj = SessionStoreManager.loadCurrentUser(),
            let address = userObj.profile?.walletInfo?.offchainAddress {
                apiManager.getListTxHistory(address: address, page: page, type: type)
                .done { (listTxHistory) in
                    self.output?.finishGetListTxHistory(listTxHistory, forPage: page)
                }.catch { (error) in
                    self.output?.errorWhileLoadTxHistory(error as? ConnectionError ?? .systemError)
                }
        }
    }
}
