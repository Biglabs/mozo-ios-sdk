//
//  PaymentPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
class PaymentPresenter: NSObject {
    var viewInterface: PaymentViewInterface?
    var interactor: PaymentInteractorInput?
    
    var wireframe: PaymentWireframe?
    var qrViewInterface: PaymentQRViewInterface?
    
    var isScanningAddress = false
    var tokenInfo: TokenInfoDTO?
    var deleteRequest: PaymentRequestDisplayItem?
}
extension PaymentPresenter: PaymentModuleInterface {
    func openScanner(tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        wireframe?.presentScannerQRCodeInterface()
    }
    
    func createPaymentRequest(_ amount: Double, tokenInfo: TokenInfoDTO) {
        let displayItem = PaymentRequestDisplayItem(id : 0, date: "", amount: amount, displayNameAddress: "", requestingAddress: tokenInfo.address ?? "")
        wireframe?.presentPaymentQRInterface(displayItem: displayItem)
    }
    
    func selectPaymentRequestOnUI(_ item: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        interactor?.prepareTransactionFromRequest(item, tokenInfo: tokenInfo)
    }
    
    func updateDisplayData(page: Int) {
        interactor?.getListPaymentRequest(page: page)
    }
    
    func loadTokenInfo() {
        interactor?.loadTokenInfo()
    }
    
    func deletePaymentRequest(_ request: PaymentRequestDisplayItem) {
        if deleteRequest == nil {
            deleteRequest = request
        }
        viewInterface?.displaySpinner()
        interactor?.deletePaymentRequest(request)
    }
}
extension PaymentPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        deletePaymentRequest(deleteRequest!)
    }
    
    func didClosePopupWithoutRetry() {
        self.deleteRequest = nil
        viewInterface?.removeSpinner()
    }
}
extension PaymentPresenter: PaymentInteractorOutput {
    func didDeletePaymentRequestSuccess() {
        self.deleteRequest = nil
        viewInterface?.removeSpinner()
        interactor?.getListPaymentRequest(page: 0)
    }
    
    func errorWhileDeleting(_ error: Any?) {
        viewInterface?.removeSpinner()
        if let connectionError = error as? ConnectionError {
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: connectionError, delegate: self)
        } else {
            viewInterface?.displayError((error as! Error).localizedDescription)
        }
    }
    
    func didReceiveTransaction(transaction: TransactionDTO, displayName: String?, isFromScannedValue: Bool) {
        wireframe?.presentTransactionConfirmInterface(transaction: transaction, tokenInfo: tokenInfo!, displayName: displayName)
    }
    
    func errorWhileLoadPaymentRequest(_ error: ConnectionError) {
        viewInterface?.displayError(error.localizedDescription)
    }
    
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int) {
//        if list.count > 0 {
            let collection = PaymentRequestDisplayCollection(items: list)
            viewInterface?.showPaymentRequestCollection(collection, forPage: forPage)
//        } else {
//            viewInterface?.showNoContent()
//        }
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        viewInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func didReceiveError(_ error: String?) {
        viewInterface?.removeSpinner()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.viewInterface?.displayError(error!)
        }
    }
}
extension PaymentPresenter: ScannerViewControllerDelegate {
    func didReceiveValueFromScanner(_ value: String) {
        if let tokenInfo = self.tokenInfo {
            interactor?.validateValueFromScanner(value, tokenInfo: tokenInfo)
        } else {
            viewInterface?.displayError("No token info")
        }
    }
}
