//
//  ConvertWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConvertWireframe: MozoWireframe {
    var walletWireframe: WalletWireframe?
    var txProcessWireframe: TxProcessWireframe?
    var convertCompletionWireframe: ConvertCompletionWireframe?
    var presenter: ConvertPresenter?
    
    func presentConvertInterface() {
        let viewController = viewControllerFromStoryBoard(ConvertViewControllerIdentifier) as! ConvertViewController
        viewController.eventHandler = presenter
        presenter?.isDisplayingConfirm = false
        presenter?.convertViewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentConfirmInterface(_ transaction: ConvertTransactionDTO, onchainInfo: OnchainInfoDTO, gasLimit: NSNumber, gasPrice: NSNumber) {
        let viewController = viewControllerFromStoryBoard(ConfirmConvertViewControllerIdentifier) as! ConfirmConvertViewController
        viewController.eventHandler = presenter
        viewController.transaction = transaction
        viewController.onchainInfo = onchainInfo
        viewController.gasLimit = gasLimit
        viewController.gasPrice = gasPrice
        presenter?.confirmConvertViewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentPinInterface() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = presenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Convert)
    }
    
    func removeDelegateAfterSigning() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func presentTrasactionProcess(_ tx: IntermediaryTransactionDTO) {
        txProcessWireframe?.presenter?.delegate = presenter
        txProcessWireframe?.presentTxProcessInterface(transaction: tx)
    }
    
    func presentConvertCompletion(_ tx: IntermediaryTransactionDTO, status: TransactionStatusType) {
        convertCompletionWireframe?.presentConvertCompletionInterface(transaction: tx, status: status)
    }
}
