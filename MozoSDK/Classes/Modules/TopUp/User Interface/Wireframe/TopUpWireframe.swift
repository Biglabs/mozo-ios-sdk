//
//  TopUpWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/29/19.
//

import Foundation
class TopUpWireframe: MozoWireframe {
    var txWireframe: TransactionWireframe?
    var txCompletionWireframe: TxCompletionWireframe?
    var walletWireframe: WalletWireframe?
    var presenter: TopUpPresenter?
    
    func requestTopUp(transferAmount: NSNumber, delegate: TopUpDelegate) {
        presenter?.topUpDelegate = delegate
        presenter?.prepareTransactionTopUp(amount: transferAmount)
    }
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
}
