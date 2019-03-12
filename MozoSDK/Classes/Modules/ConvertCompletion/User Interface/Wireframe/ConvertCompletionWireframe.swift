//
//  ConvertCompletionWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class ConvertCompletionWireframe: MozoWireframe {
    var presenter: ConvertCompletionPresenter?
    
    func presentConvertCompletionInterface(transaction: IntermediaryTransactionDTO, status: TransactionStatusType) {
        if status == .SUCCESS {
            let viewController = viewControllerFromStoryBoard(ConvertCompletionViewControllerIdentifier) as! ConvertCompletionViewController
            viewController.transaction = transaction
            viewController.eventHandler = presenter
            rootWireframe?.displayViewController(viewController)
        } else {
            let viewController = viewControllerFromStoryBoard(ConvertFailedViewControllerIdentifier) as! ConvertFailedViewController
            viewController.transaction = transaction
            viewController.eventHandler = presenter
            rootWireframe?.displayViewController(viewController)
        }
    }
}
