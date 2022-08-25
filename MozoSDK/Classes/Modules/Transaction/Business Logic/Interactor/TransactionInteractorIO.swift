//
//  TransactionInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

protocol TransactionInteractorInput: ABSupportInteractorInput {
    func validateTransferTransaction(toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?)
    func sendUserConfirmTransaction(_ transaction: TransactionDTO)
    func performTransfer(pin: String)
    func requestToRetryTransfer()
    func validateValueFromScanner(_ scanValue: String)
}

protocol TransactionInteractorOutput: ABSupportInteractorOutput {
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    func didReceiveError(_ error: String?)
    func performTransferWithError(_ error: ConnectionError, isTransferScreen: Bool)
    func requestPinToSignTransaction()
    func didValidateTransferTransaction(_ error: String?, isAddress: Bool)
    func continueWithTransaction(_ transaction: TransactionDTO, displayContactItem: AddressBookDisplayItem?)
    func didSendTransactionSuccess(_ transaction: IntermediaryTransactionDTO)
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem)
    func didReceiveAddressfromScanner(_ address: String)
    
    func requestAutoPINInterface()
}
