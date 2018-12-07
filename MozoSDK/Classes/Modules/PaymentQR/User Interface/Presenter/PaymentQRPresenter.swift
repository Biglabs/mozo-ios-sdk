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
}
extension PaymentQRPresenter: PaymentQRModuleInterface {
    func showAddressBookInterface() {
        delegate?.requestAddressBookInterfaceForPaymentRequest()
    }
    
    func showScanQRCodeInterface() {
        wireframe?.presentScannerQRCodeInterface()
    }
    
    func sendPaymentRequest(_ displayItem: PaymentRequestDisplayItem, toAddress: String) {
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
        wireframe?.presentSuccessInterface(toAddress: toAddress, item: item)
    }
    
    func didReceiveAddressFromScannedValue(address: String) {
        viewInterface?.updateUserInterfaceWithAddress(address)
    }
}
