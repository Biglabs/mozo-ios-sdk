//
//  PaymentPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
enum PaymentModuleRetryAction {
    case TokenInfo
    case PaymentList
    case DeletePayment
}
class PaymentPresenter: NSObject {
    var viewInterface: PaymentViewInterface?
    var interactor: PaymentInteractorInput?
    
    var wireframe: PaymentWireframe?
    var qrViewInterface: PaymentQRViewInterface?
    
    var isScanningAddress = false
    var tokenInfo: TokenInfoDTO?
    var deleteRequest: PaymentRequestDisplayItem?
    
    var retryAction: PaymentModuleRetryAction?
    
    func handleError(error: ConnectionError, retryAction: PaymentModuleRetryAction) {
        if !error.isApiError {
            self.retryAction = retryAction
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
        }
        else {
            var errText = error.localizedDescription
            if let apiError = error.apiError {
                errText = apiError.description
            }
            viewInterface?.displayError(errText)
        }
    }
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
        if let action = retryAction {
            switch action {
            case .TokenInfo, .PaymentList:
                interactor?.loadTokenInfo()
                interactor?.getListPaymentRequest(page: 0)
                break
            default:
                if let deleteRequest = deleteRequest {
                    deletePaymentRequest(deleteRequest)
                }
                break
            }
        }
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
        handleError(error: error as? ConnectionError ?? .systemError, retryAction: .DeletePayment)
    }
    
    func didReceiveTransaction(transaction: TransactionDTO, displayContactItem: AddressBookDisplayItem?, isFromScannedValue: Bool) {
        wireframe?.presentTransactionConfirmInterface(transaction: transaction, tokenInfo: tokenInfo!, displayContactItem: displayContactItem)
    }
    
    func errorWhileLoadPaymentRequest(_ error: ConnectionError) {
        handleError(error: error, retryAction: .PaymentList)
    }
    
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int) {
        let collection = PaymentRequestDisplayCollection(items: list)
        viewInterface?.showPaymentRequestCollection(collection, forPage: forPage)
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        viewInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func errorWhileLoadingTokenInfo(_ error: ConnectionError) {
        handleError(error: error, retryAction: .TokenInfo)
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
