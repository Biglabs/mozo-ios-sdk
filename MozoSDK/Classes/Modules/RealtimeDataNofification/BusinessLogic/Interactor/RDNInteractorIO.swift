//
//  RDNInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/18.
//
protocol RDNInteractorInput {
    func startService()
    func stopService(shouldReconnect: Bool)
}

protocol RDNInteractorOutput {
    func balanceDidChange(balanceNoti: BalanceNotification, rawMessage: String)
    func addressBookDidChange(addressBookList: [AddressBookDTO], rawMessage: String)
    func storeBookDidChange(storeBook: StoreBookDTO, rawMessage: String)
    func didAirdropped(airdropNoti: BalanceNotification, rawMessage: String)
    func didCustomerCame(ccNoti: CustomerComeNotification, rawMessage: String)
    
    func didInvalidToken(tokenNoti: InvalidTokenNotification)
    func didConvertOnchainToOffchainSuccess(balanceNoti: BalanceNotification, rawMessage: String)
}
