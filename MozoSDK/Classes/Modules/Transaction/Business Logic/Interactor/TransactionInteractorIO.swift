//
//  TransactionInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

protocol TransactionInteractorInput {
    func loadTokenInfo()
    func validateTransferTransaction(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?)
    func sendUserConfirmTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO)
    func performTransfer(pin: String)
    func requestToRetryTransfer()
    func validateValueFromScanner(_ scanValue: String)
}

protocol TransactionInteractorOutput {
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    func didReceiveError(_ error: String?)
    func performTransferWithError(_ error: ConnectionError, isTransferScreen: Bool)
    func requestPinToSignTransaction()
    func didValidateTransferTransaction(_ error: String?, isAddress: Bool)
    func continueWithTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO, displayContactItem: AddressBookDisplayItem?)
    func didSendTransactionSuccess(_ transaction: IntermediaryTransactionDTO, tokenInfo: TokenInfoDTO)
    func didReceiveAddressBookDisplayItem(_ item: AddressBookDisplayItem)
    func didReceiveAddressfromScanner(_ address: String)
}
