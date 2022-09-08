//
//  TransactionModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

protocol TransactionModuleInterface {
    func validateInputs(toAdress: String?, amount: String?, callback: TransactionValidation?) -> TransactionDTO?
    func validateTransferTransaction(toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?)
    func sendConfirmTransaction(_ transaction: TransactionDTO)
    func showScanQRCodeInterface()
    func loadTokenInfo()
    func requestToRetryTransfer()
    
    func showAddressBookInterface()
    
    func findContact(_ phoneNo: String)
    
    func topUpConfirmTransaction(_ transaction: TransactionDTO)
}
