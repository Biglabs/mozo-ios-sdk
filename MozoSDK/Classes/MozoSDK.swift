//
//  MozoSDK.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import SwiftyJSON

public class MozoSDK {

    private(set) static var network: MozoNetwork = .TestNet
    
    private(set) static var appType: AppType = .Shopper {
        didSet {
            ModuleDependencies.shared.webSocketManager.appType = appType
            ModuleDependencies.shared.authPresenter.authInteractor?.updateClientId(appType)
        }
    }
    
    public private(set) static var homePage: String = "https://\(Configuration.BASE_DOMAIN.landingPage)"
    
    public static func configure(network: MozoNetwork = .TestNet, appType: AppType = .Shopper) {
        switch network {
            case .DevNet: Configuration.BASE_DOMAIN = .DEVELOP
            case .TestNet: Configuration.BASE_DOMAIN = .STAGING
            case .MainNet: Configuration.BASE_DOMAIN = .PRODUCTION
        }
        self.network = network
        self.appType = appType
    }
    
    public static func setAuthDelegate(_ delegate: AuthenticationDelegate) {
        ModuleDependencies.shared.setAuthDelegate(delegate)
    }
    
    public static func isNetworkReachable() -> Bool {
        return ModuleDependencies.shared.isNetworkReachable()
    }
    
    public static func authenticate() {
        ModuleDependencies.shared.authenticate()
    }
    
    public static func logout() {
        ModuleDependencies.shared.logout()
    }
    
    public static func transferMozo() {
        ModuleDependencies.shared.transferMozo()
    }
    
    public static func displayTransactionHistory() {
        ModuleDependencies.shared.displayTransactionHistory()
    }
    
    public static func displayPaymentRequest() {
        ModuleDependencies.shared.displayPaymentRequest()
    }
    
    public static func displayAddressBook() {
        ModuleDependencies.shared.displayAddressBook()
    }
    
    public static func convertMozoXOnchain(isConvertOffchainToOffchain: Bool = false) {
        ModuleDependencies.shared.convertMozoXOnchain(isConvertOffchainToOffchain: isConvertOffchainToOffchain)
    }
    
    public static func displayTransactionDetail(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        ModuleDependencies.shared.displayTransactionDetail(txHistory: txHistory, tokenInfo: tokenInfo)
    }
    
    public static func loadBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (ModuleDependencies.shared.loadBalanceInfo())
    }
    
    public static func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO> {
        return (ModuleDependencies.shared.loadEthAndOnchainBalanceInfo())
    }
    
    public static func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (ModuleDependencies.shared.registerBeacon(parameters: parameters))
    }
    
    public static func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (ModuleDependencies.shared.updateBeaconSettings(parameters: parameters))
    }
    
    public static func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return (ModuleDependencies.shared.deleteBeacon(beaconId: beaconId))
    }
    
    public static func getRetailerInfo() -> Promise<[String : Any]> {
        return (ModuleDependencies.shared.getRetailerInfo())
    }
    
    public static func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (ModuleDependencies.shared.addRetailerSalePerson(parameters:parameters))
    }
    
    public static func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return (ModuleDependencies.shared.getTxHistoryDisplayCollection())
    }
    
    public static func createAirdropEvent(event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        return (ModuleDependencies.shared.createAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func addMoreMozoToAirdropEvent(event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        return (ModuleDependencies.shared.addMoreMozoToAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func withdrawMozoFromAirdropEventId(_ eventId: Int64, delegate: WithdrawAirdropEventDelegate) {
        return (ModuleDependencies.shared.withdrawMozoFromAirdropEventId(eventId, delegate: delegate))
    }
    
    public static func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return ModuleDependencies.shared.getLatestAirdropEvent()
    }
    
    public static func getAirdropEventList(page: Int, branchId: Int64? = nil) -> Promise<[AirdropEventDTO]> {
        return ModuleDependencies.shared.getAirdropEventList(page: page, branchId: branchId)
    }
    
    public static func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return ModuleDependencies.shared.getRetailerAnalyticHome()
    }
    
    public static func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return ModuleDependencies.shared.getRetailerAnalyticList()
    }
    
    public static func getVisitCustomerList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[VisitedCustomerDTO]> {
        return ModuleDependencies.shared.getVisitCustomerList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRetailerAnalyticAmountAirdropList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[AirDropReportDTO]> {
        return ModuleDependencies.shared.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRunningAirdropEvents(page: Int = 0, size: Int = 5) -> Promise<[AirdropEventDTO]> {
        return ModuleDependencies.shared.getRunningAirdropEvents(page: page, size: size)
    }
    
    public static func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return ModuleDependencies.shared.getListSalePerson()
    }
    
    public static func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.removeSalePerson(id: id)
    }
    
    public static func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return ModuleDependencies.shared.getListCountryCode()
    }
    
    public static func getUrlToUploadImage() -> Promise<String> {
        return ModuleDependencies.shared.getUrlToUploadImage()
    }
    
    public static func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]> {
        return ModuleDependencies.shared.uploadImage(images: images, url: url, progressionHandler: progressionHandler)
    }
    
    public static func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return ModuleDependencies.shared.updateUserProfile(userProfile: userProfile)
    }
    
    public static func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return ModuleDependencies.shared.updateAvatarToUserProfile(userProfile: userProfile)
    }
    
    public static func getCommonHashtag() -> Promise<[String]> {
        return ModuleDependencies.shared.getCommonHashtag()
    }
    
    public static func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return ModuleDependencies.shared.deleteRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return ModuleDependencies.shared.updateRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return ModuleDependencies.shared.updateRetailerStoreInfoHashtag(hashTags: hashTags)
    }
    
    public static func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return ModuleDependencies.shared.updateRetailerStoreInfo(storeInfo: storeInfo)
    }
    
    public static func getRecommendationStores(_ storeId: Int64, size: Int = 5, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return ModuleDependencies.shared.getRecommendationStores(storeId, size: size, long: long, lat: lat)
    }
    
    public static func handleAccessRemove() {
        return ModuleDependencies.shared.handleAccessRemove()
    }
    
    public static func handleNotificationAction(
        _ notificationResponse: UNNotificationResponse,
        _ handler: (_ type: NotificationEventType, _ messageId: Int64?) -> Void
    ) -> Bool {
        if let notiContent = notificationResponse.notification.request.content.userInfo["notiContent"] as? String {
            let notiJson = SwiftyJSON.JSON(parseJSON: notiContent)
            let wsMessage = WSMessage(json: notiJson)
            guard let content = wsMessage?.content else { return false }
            let jobj = SwiftyJSON.JSON(parseJSON: content)
            if let balanceNoti = BalanceNotification(json: jobj),
               let event = balanceNoti.event,
               let type = NotificationEventType.init(rawValue: event)
            {
                switch type {
                case .Airdropped, .AirdropInvite, .AirdropSignup, .BalanceChanged:
                    if SessionStoreManager.tokenInfo == nil {
                        _ = ModuleDependencies.shared.coreWireframe.corePresenter?.coreInteractorService?.loadBalanceInfo().done({ _ in
                            if let tokenInfo = SessionStoreManager.tokenInfo {
                                ModuleDependencies.shared.displayTransactionDetail(
                                    txHistory: TxDetailDisplayData(
                                        notify: balanceNoti,
                                        tokenInfo: tokenInfo
                                    ).buildHistoryDisplayItem(wsMessage?.time),
                                    tokenInfo: tokenInfo
                                )
                            }
                        })
                    } else {
                        ModuleDependencies.shared.displayTransactionDetail(
                            txHistory: TxDetailDisplayData(
                                notify: balanceNoti,
                                tokenInfo: SessionStoreManager.tokenInfo!
                            ).buildHistoryDisplayItem(wsMessage?.time),
                            tokenInfo: SessionStoreManager.tokenInfo!
                        )

                    }
                    break
                default:
                    let luckyNotify = LuckyDrawNotification(json: jobj)
                    handler(type, luckyNotify?.messageId)
                    break
                }
            }
            
            return true
        }
        
        return false
    }
    
    public static func requestSupportBeacon(info: SupportRequestDTO) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.requestSupportBeacon(info: info)
    }
    
    public static func getOffchainTokenInfo() -> Promise<OffchainInfoDTO> {
        return ModuleDependencies.shared.getOffchainTokenInfo()
    }
    
    public static func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return ModuleDependencies.shared.getInviteLink(locale: locale, inviteAppType: inviteAppType)
    }
    
    public static func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return ModuleDependencies.shared.getListLanguageInfo()
    }
    
    public static func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return ModuleDependencies.shared.updateCodeLinkInstallApp(codeString: codeString)
    }
    
    public static func processInvitationCode() {
        return ModuleDependencies.shared.processInvitationCode()
    }
    
    public static func getListNotification(page: Int = 0, size: Int = 15) -> Promise<[WSMessage]> {
        return ModuleDependencies.shared.getListNotification(page: page, size: size)
    }
    
    public static func loadUserProfile() -> Promise<UserProfileDTO> {
        return ModuleDependencies.shared.loadUserProfile()
    }
    
    public static func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return ModuleDependencies.shared.getCreateAirdropEventSettings()
    }
    
    public static func requestForChangePin() {
        return ModuleDependencies.shared.requestForChangePin()
    }
    
    public static func requestForBackUpWallet() {
        return ModuleDependencies.shared.requestForBackUpWallet()
    }
    
    public static func getRetailerPromotionList(page: Int = 0, size: Int = 15, statusRequest: PromotionStatusRequestEnum = .RUNNING) -> Promise<[PromotionDTO]> {
        return ModuleDependencies.shared.getRetailerPromotionList(page: page, size: size, statusRequest: statusRequest)
    }
    
    public static func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return ModuleDependencies.shared.processPromotionCode(code: code)
    }
    
    public static func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return ModuleDependencies.shared.usePromotionCode(code: code, billInfo: billInfo)
    }
    
    public static func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.cancelPromotionCode(code: code)
    }
    
    public static func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.updateFavoritePromotion(promotionId, isFavorite: isFavorite)
    }
    
    public static func getShopperPromotionRunning(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0, storeId: Int64) -> Promise<JSON> {
        return ModuleDependencies.shared.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId)
    }
    
    public static func getRetailerPromotionScannedList(page: Int = 0, size: Int = 15) -> Promise<[PromotionCodeInfoDTO]> {
        return ModuleDependencies.shared.getRetailerPromotionScannedList(page: page, size: size)
    }
    
    public static func getRetailerCountPromotion() -> Promise<Int> {
        return ModuleDependencies.shared.getRetailerCountPromotion()
    }
    
    // MARK: TOP UP
    public static func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (ModuleDependencies.shared.loadTopUpBalanceInfo())
    }
    
    public static func loadTopUpHistory(topUpAddress: String? = nil, page: Int = 0, size: Int = 15) -> Promise<TxHistoryDisplayCollection> {
        return (ModuleDependencies.shared.loadTopUpHistory(topUpAddress: topUpAddress, page: page, size: size))
    }
    
    public static func openTopUpTransfer(delegate: TopUpDelegate) {
        ModuleDependencies.shared.openTopUpTransfer(delegate: delegate)
    }
    
    public static func topUpWithdraw(delegate: TopUpWithdrawDelegate) {
        ModuleDependencies.shared.topUpWithdraw(delegate: delegate)
    }
    
    public static func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return ModuleDependencies.shared.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat)
    }
    
    public static func getBranchList(page: Int = 0, forSwitching: Bool) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.getBranchList(page: page, forSwitching: forSwitching)
    }
     
    public static func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.switchBranch(branchId)
    }
    
    public static func getRetailerInfoForLauching() -> Promise<[String: Any]> {
        return ModuleDependencies.shared.getRetailerInfoForLauching()
    }
    
    public static func checkBranchName(_ name: String) -> Promise<Any> {
        return ModuleDependencies.shared.checkBranchName(name)
    }
    
    public static func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO> {
        return ModuleDependencies.shared.updateSalePerson(account: account)
    }
    
    public static func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return ModuleDependencies.shared.registerMoreBeacon(parameters: parameters)
    }
    
    // MARK: Mozo Messages APIs
    public static func getConversationList(text: String?, page: Int) -> Promise<[Conversation]> {
        return ModuleDependencies.shared.getConversationList(text: text, page: page)
    }
    public static func getConversationDetails(id: Int64) -> Promise<Conversation?> {
        return ModuleDependencies.shared.getConversationDetails(id: id)
    }
    public static func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]> {
        return ModuleDependencies.shared.getChatMessages(id: id, page: page)
    }
    public static func responseConversation(conversationId: Int64, status: String) -> Promise<Any> {
        return ModuleDependencies.shared.responseConversation(conversationId: conversationId, status: status)
    }
    public static func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any> {
        return ModuleDependencies.shared.updateReadConversation(conversationId: conversationId, lastMessageId: lastMessageId)
    }
    public static func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any> {
        return ModuleDependencies.shared.sendMessage(id: id, message: message, images: images, userSend: userSend)
    }
}
