//
//  TxProcessWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class TxProcessWireframe: MozoWireframe {
    var presenter: TxProcessPresenter?
    
    func presentTxProcessInterface(transaction: IntermediaryTransactionDTO) {
        let viewController = viewControllerFromStoryBoard(TxProcessViewControllerIdentifier) as! TxProcessViewController
        viewController.eventHandler = presenter
<<<<<<< HEAD
        rootWireframe?.displayViewController(viewController)
=======
        rootWireframe?.presentViewController(viewController)
>>>>>>> SDK_Version_1.3
        presenter?.startWaitingTxStatus(transaction: transaction)
    }
}
