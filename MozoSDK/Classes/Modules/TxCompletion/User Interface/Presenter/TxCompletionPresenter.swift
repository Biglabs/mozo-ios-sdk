//
//  TxCompletionPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation

class TxCompletionPresenter : NSObject {
    var completionModuleDelegate: TxCompletionModuleDelegate?
    var completionUserInterface : TxCompletionViewInterface?
    var completionInteractor: TxCompletionInteractorInput?
    
    var transactionHash: String?
    
    var moduleRequest = Module.Transaction
    
    var topUpModuleDelegate: TopUpCompletionModuleDelegate?
}

extension TxCompletionPresenter : TxCompletionModuleInterface {
    func requestWaitingForTxStatus(hash: String) {
        self.transactionHash = hash
        completionInteractor?.startWaitingStatusService(hash: hash, moduleRequest: moduleRequest)
    }
    
    func requestStopWaiting() {
        completionInteractor?.stopService()
    }
    
    func requestAddToAddressBook(_ address: String) {
        // Verify address is existing in address book list or not
        let list = SafetyDataManager.shared.addressBookList
        let contain = AddressBookDTO.arrayContainsItem(address, array: list)
        if contain {
            // Show message
            completionUserInterface?.displayError("Address is existing in address book list.")
        } else {
            completionModuleDelegate?.requestAddToAddressBook(address)
        }
    }
    
    func requestShowDetail(_ detail: TxDetailDisplayItem) {
        completionModuleDelegate?.requestShowDetail(detail)
    }
}

extension TxCompletionPresenter : TxCompletionInteractorOutput {
    func didReceiveTxStatus(_ status: TransactionStatusType) {
        if status == .FAILED, moduleRequest == .TopUp || moduleRequest == .TopUpTransfer {
            topUpModuleDelegate?.didTopUpCompleteFailure()
            return
        }
        completionUserInterface?.updateView(status: status)
    }
    
    func didReceiveError(error: ConnectionError) {
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
    }
}

extension TxCompletionPresenter : PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let hash = self.transactionHash {
            requestWaitingForTxStatus(hash: hash)
        }
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
