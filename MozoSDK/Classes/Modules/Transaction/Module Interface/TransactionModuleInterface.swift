//
//  TransactionModuleInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

protocol TransactionModuleInterface {
    func validateTransferTransaction(tokenInfo: TokenInfoDTO?, toAdress: String?, amount: String?, displayContactItem: AddressBookDisplayItem?)
    func sendConfirmTransaction(_ transaction: TransactionDTO, tokenInfo: TokenInfoDTO)
    func showScanQRCodeInterface()
    func loadTokenInfo()
    func requestToRetryTransfer()
    
    func showAddressBookInterface()
}
