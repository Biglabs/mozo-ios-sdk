//
//  PaymentQRPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
class PaymentQRPresenter: NSObject {
    var wireframe: PaymentQRWireframe?
    var interactor: PaymentQRInteractorInput?
    var viewInterface: PaymentQRViewInterface?
    var delegate: PaymentQRModuleDelegate?
    
    var toAddress: String?
    var paymentRequestToSend: PaymentRequestDisplayItem?
}
extension PaymentQRPresenter: PaymentQRModuleInterface {
    func showAddressBookInterface() {
        delegate?.requestAddressBookInterfaceForPaymentRequest()
    }
    
    func showScanQRCodeInterface() {
        wireframe?.presentScannerQRCodeInterface()
    }
    
    func sendPaymentRequest(_ displayItem: PaymentRequestDisplayItem, toAddress: String) {
        self.toAddress = toAddress
        self.paymentRequestToSend = displayItem
        viewInterface?.displaySpinner()
        interactor?.sendPaymentRequest(toAddress: toAddress, item: displayItem)
    }
    
    func close() {
        wireframe?.dismissInterface()
    }
}
extension PaymentQRPresenter: ScannerViewControllerDelegate {
    func didReceiveValueFromScanner(_ value: String) {
        interactor?.validateValueFromScanner(value)
    }
}
extension PaymentQRPresenter: PaymentQRInteractorOutput {
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem) {
        viewInterface?.updateInterfaceWithDisplayItem(item)
    }
    
    func didReceiveError(_ error: String?) {
        viewInterface?.displayError(error ?? "Error")
    }
    
    func didSendPaymentRequestSuccess(toAddress: String, item: PaymentRequestDisplayItem) {
        self.toAddress = nil
        self.paymentRequestToSend = nil
        viewInterface?.removeSpinner()
        wireframe?.presentSuccessInterface(toAddress: toAddress, item: item)
    }
    
    func didReceiveAddressFromScannedValue(address: String) {
        viewInterface?.updateUserInterfaceWithAddress(address)
    }
    
    func errorWhileSendPayment(error: Any, toAddress: String, item: PaymentRequestDisplayItem) {
        viewInterface?.removeSpinner()
        if let errorConnection = error as? ConnectionError {
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: errorConnection, delegate: self)
        } else {
            viewInterface?.displayError((error as! Error).localizedDescription)
        }
    }
}
extension PaymentQRPresenter: PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        self.toAddress = nil
        self.paymentRequestToSend = nil
        viewInterface?.removeSpinner()
    }
    
    func didTouchTryAgainButton() {
        sendPaymentRequest(self.paymentRequestToSend!, toAddress: self.toAddress!)
    }
}
