//
//  PaymentInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
protocol PaymentInteractorInput {
    func loadTokenInfo()
    func getListPaymentRequest(page: Int)
    func validateValueFromScanner(_ scanValue: String, tokenInfo: TokenInfoDTO)
    func prepareTransactionFromRequest(_ request: PaymentRequestDisplayItem, tokenInfo: TokenInfoDTO)
    func deletePaymentRequest(_ request: PaymentRequestDisplayItem)
}
protocol PaymentInteractorOutput {
    func didLoadTokenInfo(_ tokenInfo: TokenInfoDTO)
    func errorWhileLoadingTokenInfo(_ error: ConnectionError)
    func didReceiveError(_ error: Error)
    func didReceiveErrorString(_ error: String)
    func finishGetListPaymentRequest(_ list: [PaymentRequestDTO], forPage: Int)
    func errorWhileLoadPaymentRequest(_ error: ConnectionError)
    
    func didReceiveTransaction(transaction: TransactionDTO, displayContactItem: AddressBookDisplayItem?, isFromScannedValue: Bool)
    
    func didDeletePaymentRequestSuccess()
    func errorWhileDeleting(_ error: Any?)
}
