//
//  PaymentQRWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
class PaymentQRWireframe: MozoWireframe {
    var presenter: PaymentQRPresenter?
    var paymentQRViewController: PaymentQRViewController?
    
    func presentPaymentQRInterface(displayItem: PaymentRequestDisplayItem) {
        let viewController = viewControllerFromStoryBoard(PaymentQRViewControllerIdentifier) as! PaymentQRViewController
        viewController.eventHandler = presenter
        viewController.displayItem = displayItem
        paymentQRViewController = viewController
        presenter?.viewInterface = viewController
        rootWireframe?.displayViewController(viewController)
    }
    
    func updateInterfaceWithAddressBook(_ addressBookDisplayItem: AddressBookDisplayItem) {
        presenter?.viewInterface?.updateInterfaceWithDisplayItem(addressBookDisplayItem)
    }
    
    func dismissInterface() {
        rootWireframe?.dismissTopViewController()
    }
    
    func presentSuccessInterface(toAddress: String, item: PaymentRequestDisplayItem) {
        let viewController = viewControllerFromStoryBoard(PaymentSendSuccessViewControllerIdentifier) as! PaymentSendSuccessViewController
        viewController.toAddress = toAddress
        viewController.displayItem = item
        rootWireframe?.displayViewController(viewController)
    }
    
    func presentScannerQRCodeInterface() {
        let viewController = ScannerViewController()
        viewController.delegate = presenter
        rootWireframe?.presentViewController(viewController)
    }
}
