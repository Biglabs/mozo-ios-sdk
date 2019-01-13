//
//  PaymentWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
class PaymentWireframe: MozoWireframe {
    var presenter: PaymentPresenter?
    var paymentViewController: PaymentViewController?
    var paymentQRWireframe: PaymentQRWireframe?
    var txWireframe: TransactionWireframe?
    
    func presentPaymentRequestInterface() {
        let viewController = viewControllerFromStoryBoard(PaymentViewControllerIdentifier) as! PaymentViewController
        viewController.eventHandler = presenter
        paymentViewController = viewController
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentScannerQRCodeInterface() {
        let viewController = ScannerViewController()
        viewController.delegate = presenter
        rootWireframe?.presentViewController(viewController)
    }
    
    func presentPaymentQRInterface(displayItem: PaymentRequestDisplayItem) {
        paymentQRWireframe?.presentPaymentQRInterface(displayItem: displayItem)
    }
    
    func presentTransactionConfirmInterface(transaction: TransactionDTO, tokenInfo: TokenInfoDTO, displayContactItem: AddressBookDisplayItem?) {
        txWireframe?.presentConfirmInterface(transaction: transaction, tokenInfo: tokenInfo, displayContactItem: displayContactItem, isPaymentRequest: true)
    }
}
