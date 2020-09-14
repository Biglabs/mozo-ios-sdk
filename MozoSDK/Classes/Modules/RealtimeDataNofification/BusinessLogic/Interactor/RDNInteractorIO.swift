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
    func didInvitedSuccess(inviteNoti: InviteNotification, rawMessage: String)
    
    func didInvalidToken(tokenNoti: InvalidTokenNotification)
    func didConvertOnchainToOffchainSuccess(balanceNoti: BalanceNotification, rawMessage: String)
    
    func profileDidChange()
    
    func didReceivedAirdrop(eventType: NotificationEventType, balanceNoti: BalanceNotification, rawMessage: String)
    func didReceivedPromotionUsed(eventType: NotificationEventType, usedNoti: PromotionUsedNotification, rawMessage: String)
    func didReceivedPromotionPurchased(eventType: NotificationEventType, purchasedNoti: PromotionPurchasedNotification, rawMessage: String)
    func didReceivedCovidWarning(eventType: NotificationEventType, warningNoti: CovidWarningNotification, rawMessage: String)
    func didReceivedLuckyDraw(noti: LuckyDrawNotification, rawMessage: String)
}
