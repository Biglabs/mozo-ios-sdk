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
        if let errorConnection = error as? ConnectionError {
            if !errorConnection.isApiError {
                DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: errorConnection, delegate: self)
            }
            else {
                var errText = errorConnection.localizedDescription
                if let apiError = errorConnection.apiError {
                    errText = apiError.description
                }
                viewInterface?.displayError(errText)
            }
        }
    }
    
    func didReceiveTransaction(transaction: TransactionDTO, displayName: String?, isFromScannedValue: Bool) {
        wireframe?.presentTransactionConfirmInterface(transaction: transaction, tokenInfo: tokenInfo!, displayName: displayName)
    }
    
    func errorWhileLoadPaymentRequest(_ error: ConnectionError) {
        var errText = error.localizedDescription
        if error.isApiError, let apiError = error.apiError {
            errText = apiError.description
        }
        viewInterface?.displayError(errText)
    }
    
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int) {
        let collection = PaymentRequestDisplayCollection(items: list)
        viewInterface?.showPaymentRequestCollection(collection, forPage: forPage)
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        viewInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func didReceiveError(_ error: Error) {
        viewInterface?.removeSpinner()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            let connError = error as? ConnectionError ?? .systemError
            var errText = connError.localizedDescription
            if let apiError = connError.apiError {
                errText = apiError.description
            }
            self.viewInterface?.displayError(errText)
        }
    }
    
    func didReceiveErrorString(_ error: String) {
        viewInterface?.removeSpinner()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.viewInterface?.displayError(error)
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
