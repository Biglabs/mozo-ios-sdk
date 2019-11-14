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
    
    func presentPinInterfaceForMultiSign() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = presenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.TopUp)
    }
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func presentTopUpTransferInterface(delegate: TopUpDelegate) {
        presenter?.topUpDelegate = delegate
        
        let viewController = viewControllerFromStoryBoard(TopUpTransferViewControllerIdentifier, storyboardName: Module.TopUp.value) as! TopUpTransferViewController
        viewController.eventHandler = presenter
        presenter?.transferViewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentTopUpFailureInterface() {
        let viewController = viewControllerFromStoryBoard(TopUpFailureViewControllerIdentifier, storyboardName: Module.TopUp.value) as! TopUpFailureViewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentTransactionCompleteInterface(_ detail: TxDetailDisplayItem, moduleRequest: Module) {
        txCompletionWireframe?.presentTransactionCompleteInterface(detail, moduleRequest: moduleRequest)
    }
    
    func presentConfirmTransferInterface(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO) {
        txWireframe?.presentConfirmInterface(transaction: transaction, tokenInfo: tokenInfo, displayContactItem: nil, moduleRequest: .TopUp)
    }
}
