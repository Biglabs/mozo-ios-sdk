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
    var delegate: PaymentModuleDelegate?
    var wireframe: PaymentWireframe?
}
extension PaymentPresenter: PaymentModuleInterface {
    func openScanner() {
        wireframe?.presentScannerQRCodeInterface()
    }
    
    func createPaymentRequest(_ amount: Double) {
        // TODO: Open QR Payment Request Interface
        
    }
    
    func selectPaymentRequestOnUI(_ item: PaymentRequestDisplayItem) {
        delegate?.didChoosePaymentRequest(item)
    }
    
    func updateDisplayData(page: Int) {
        interactor?.getListPaymentRequest(page: page)
    }
    
    func loadTokenInfo() {
        interactor?.loadTokenInfo()
    }
}
extension PaymentPresenter: PaymentInteractorOutput {
    func didValidateValueFromScanner() {
        
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
        viewInterface?.displayError(error!)
    }
}
extension PaymentPresenter: ScannerViewControllerDelegate {
    func didReceiveValueFromScanner(_ value: String) {
        
    }
}
