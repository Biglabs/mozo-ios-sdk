//
//  TransactionInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

protocol TransactionValidation {
    func didReceiveError(_ error: String?, causeByReceiver: Bool)
}

protocol TransactionInteractorInput: ABSupportInteractorInput {
    func validateInputs(toAdress: String?, amount: String?, callback: TransactionValidation?) -> TransactionDTO?
    func validateTransferTransaction(toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?)
    func sendUserConfirmTransaction(_ transaction: TransactionDTO)
    func performTransfer(pin: String)
    func requestToRetryTransfer()
    func validateValueFromScanner(_ scanValue: String)
}

protocol TransactionInteractorOutput: ABSupportInteractorOutput, TransactionValidation {
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    func performTransferWithError(_ error: ConnectionError, isTransferScreen: Bool)
    func requestPinToSignTransaction()
    func continueWithTransaction(_ transaction: TransactionDTO, displayContactItem: AddressBookDisplayItem?)
    func didSendTransactionSuccess(_ transaction: IntermediaryTransactionDTO)
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem)
    func didReceiveAddressfromScanner(_ address: String)
    
    func requestAutoPINInterface()
}
