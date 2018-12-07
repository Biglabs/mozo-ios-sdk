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
}
extension PaymentPresenter: PaymentModuleInterface {
    func openScanner(tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        wireframe?.presentScannerQRCodeInterface()
    }
    
    func createPaymentRequest(_ amount: Double, tokenInfo: TokenInfoDTO) {
        let displayItem = PaymentRequestDisplayItem(date: "", amount: amount, displayNameAddress: "", requestingAddress: tokenInfo.address ?? "")
        wireframe?.presentPaymentQRInterface(displayItem: displayItem)
    }
    
    func selectPaymentRequestOnUI(_ item: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        interactor?.prepareTransactionFromRequest(item, tokenInfo: tokenInfo)
    }
    
    func updateDisplayData(page: Int) {
        let collection = PaymentRequestDisplayCollection(items: [])
        viewInterface?.showPaymentRequestCollection(collection, forPage: page)
//        interactor?.getListPaymentRequest(page: page)
    }
    
    func loadTokenInfo() {
        interactor?.loadTokenInfo()
    }
}
extension PaymentPresenter: PaymentInteractorOutput {
    func didReceiveTransaction(transaction: TransactionDTO, displayName: String?, isFromScannedValue: Bool) {
        wireframe?.presentTransactionConfirmInterface(transaction: transaction, tokenInfo: tokenInfo!, displayName: displayName)
    }
    
    func errorWhileLoadPaymentRequest(_ error: ConnectionError) {
        viewInterface?.displayError(error.localizedDescription)
    }
    
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int) {
        if list.count > 0 {
            let collection = PaymentRequestDisplayCollection(items: list)
            viewInterface?.showPaymentRequestCollection(collection, forPage: forPage)
        } else {
            viewInterface?.showNoContent()
        }
    }
    
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO) {
        viewInterface?.updateUserInterfaceWithTokenInfo(tokenInfo)
    }
    
    func didReceiveError(_ error: String?) {
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
