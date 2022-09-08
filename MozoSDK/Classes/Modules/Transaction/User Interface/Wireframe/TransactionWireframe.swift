//
//  TransactionWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation
import UIKit

class TransactionWireframe: MozoWireframe {
    var pay: [String: String]?

    func presentTransferInterface() {
        if pay != nil {
            let viewController = viewControllerFromStoryBoard(ConfirmTransferViewControllerIdentifier) as! ConfirmTransferViewController
            viewController.pay = pay
            rootWireframe?.displayViewController(viewController)
            self.pay = nil
        }else {
            let viewController = viewControllerFromStoryBoard(TransferViewControllerIdentifier) as! TransferViewController
            rootWireframe?.displayViewController(viewController)
        }
    }
    
    func presentConfirmInterface(transaction: TransactionDTO, displayContactItem: AddressBookDisplayItem?, moduleRequest: Module = .Transaction) {
        let viewController = viewControllerFromStoryBoard(ConfirmTransferViewControllerIdentifier) as! ConfirmTransferViewController
        viewController.transaction = transaction
        viewController.displayContactItem = displayContactItem
        viewController.moduleRequest = moduleRequest
        rootWireframe?.displayViewController(viewController)
    }
}
