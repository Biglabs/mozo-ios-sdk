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
    // MARK: - Properties
    private static var moduleDependencies: ModuleDependencies!

    private(set) static var network: MozoNetwork = .TestNet {
        didSet {
            moduleDependencies.authWireframe.authPresenter?.authInteractor?.updateNetwork(network)
        }
    }
    
    private(set) static var appType: AppType = .Shopper {
        didSet {
            moduleDependencies.webSocketManager.appType = appType
            moduleDependencies.authWireframe.authPresenter?.authInteractor?.updateClientId(appType)
        }
    }
    
    public private(set) static var homePage: String = "https://\(Configuration.BASE_DOMAIN.landingPage)"
    
    public static func configure(network: MozoNetwork = .TestNet, appType: AppType = .Shopper) {
        switch network {
            case .DevNet: Configuration.BASE_DOMAIN = .DEVELOP
            case .TestNet: Configuration.BASE_DOMAIN = .STAGING
            case .MainNet: Configuration.BASE_DOMAIN = .PRODUCTION
        }
        moduleDependencies = ModuleDependencies()
        self.network = network
        self.appType = appType
    }
    
    public static func setAuthDelegate(_ delegate: AuthenticationDelegate) {
        moduleDependencies.setAuthDelegate(delegate)
    }
    
    public static func isNetworkReachable() -> Bool {
        return moduleDependencies.isNetworkReachable()
    }
    
    public static func authenticate() {
        moduleDependencies.authenticate()
    }
    
    public static func processAuthorizationCallBackUrl(_ url: URL) {
        moduleDependencies.processAuthorizationCallBackUrl(url)
    }
    
    public static func logout() {
        moduleDependencies.logout()
    }
    
    public static func transferMozo() {
        moduleDependencies.transferMozo()
    }
    
    public static func displayTransactionHistory() {
        moduleDependencies.displayTransactionHistory()
    }
    
    public static func displayPaymentRequest() {
        moduleDependencies.displayPaymentRequest()
    }
    
    public static func displayAddressBook() {
        moduleDependencies.displayAddressBook()
    }
    
    public static func convertMozoXOnchain(isConvertOffchainToOffchain: Bool = false) {
        moduleDependencies.convertMozoXOnchain(isConvertOffchainToOffchain: isConvertOffchainToOffchain)
    }
    
    public static func displayTransactionDetail(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        moduleDependencies.displayTransactionDetail(txHistory: txHistory, tokenInfo: tokenInfo)
    }
    
    public static func loadBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (moduleDependencies.loadBalanceInfo())
    }
    
    public static func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO> {
        return (moduleDependencies.loadEthAndOnchainBalanceInfo())
    }
    
    public static func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.registerBeacon(parameters: parameters))
    }
    
    public static func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.updateBeaconSettings(parameters: parameters))
    }
    
    public static func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return (moduleDependencies.deleteBeacon(beaconId: beaconId))
    }
    
    public static func getRetailerInfo() -> Promise<[String : Any]> {
        return (moduleDependencies.getRetailerInfo())
    }
    
    public static func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.addRetailerSalePerson(parameters:parameters))
    }
    
    public static func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return (moduleDependencies.getTxHistoryDisplayCollection())
    }
    
    public static func createAirdropEvent(event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        return (moduleDependencies.createAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func addMoreMozoToAirdropEvent(event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        return (moduleDependencies.addMoreMozoToAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func withdrawMozoFromAirdropEventId(_ eventId: Int64, delegate: WithdrawAirdropEventDelegate) {
        return (moduleDependencies.withdrawMozoFromAirdropEventId(eventId, delegate: delegate))
    }
    
    public static func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return moduleDependencies.getLatestAirdropEvent()
    }
    
    public static func getAirdropEventList(page: Int, branchId: Int64? = nil) -> Promise<[AirdropEventDTO]> {
        return moduleDependencies.getAirdropEventList(page: page, branchId: branchId)
    }
    
    public static func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return moduleDependencies.getRetailerAnalyticHome()
    }
    
    public static func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return moduleDependencies.getRetailerAnalyticList()
    }
    
    public static func getVisitCustomerList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[VisitedCustomerDTO]> {
        return moduleDependencies.getVisitCustomerList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRetailerAnalyticAmountAirdropList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[AirDropReportDTO]> {
        return moduleDependencies.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRunningAirdropEvents(page: Int = 0, size: Int = 5) -> Promise<[AirdropEventDTO]> {
        return moduleDependencies.getRunningAirdropEvents(page: page, size: size)
    }
    
    public static func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return moduleDependencies.getListSalePerson()
    }
    
    public static func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return moduleDependencies.removeSalePerson(id: id)
    }
    
    public static func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return moduleDependencies.getListCountryCode()
    }
    
    public static func searchStoresWithText(_ text: String, page: Int = 0, long: Double, lat: Double, sort: String = "distance") -> Promise<CollectionStoreInfoDTO> {
        return moduleDependencies.searchStoresWithText(text, page: page, long: long, lat: lat, sort: sort)
    }
    
    public static func getFavoriteStores(page: Int = 0, size: Int = 15) -> Promise<[BranchInfoDTO]> {
        return moduleDependencies.getFavoriteStores(page: page, size: size)
    }
    
    public static func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return moduleDependencies.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite)
    }
    
    public static func getUserSummary(startTime: Int = 0, endTime: Int = 86400) -> Promise<UserSummary?> {
        return moduleDependencies.getUserSummary(startTime: startTime, endTime: endTime)
    }
    
    public static func getUrlToUploadImage() -> Promise<String> {
        return moduleDependencies.getUrlToUploadImage()
    }
    
    public static func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]> {
        return moduleDependencies.uploadImage(images: images, url: url, progressionHandler: progressionHandler)
    }
    
    public static func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return moduleDependencies.updateUserProfile(userProfile: userProfile)
    }
    
    public static func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return moduleDependencies.updateAvatarToUserProfile(userProfile: userProfile)
    }
    
    public static func getCommonHashtag() -> Promise<[String]> {
        return moduleDependencies.getCommonHashtag()
    }
    
    public static func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return moduleDependencies.deleteRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return moduleDependencies.updateRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return moduleDependencies.updateRetailerStoreInfoHashtag(hashTags: hashTags)
    }
    
    public static func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return moduleDependencies.updateRetailerStoreInfo(storeInfo: storeInfo)
    }
    
    public static func getStoreDetail(_ storeId: Int64) -> Promise<BranchInfoDTO> {
        return moduleDependencies.getStoreDetail(storeId)
    }
    
    public static func getRecommendationStores(_ storeId: Int64, size: Int = 5, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return moduleDependencies.getRecommendationStores(storeId, size: size, long: long, lat: lat)
    }
    
    public static func handleAccessRemove() {
        return moduleDependencies.handleAccessRemove()
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
                        _ = moduleDependencies.coreWireframe.corePresenter?.coreInteractorService?.loadBalanceInfo().done({ _ in
                            if let tokenInfo = SessionStoreManager.tokenInfo {
                                moduleDependencies.displayTransactionDetail(
                                    txHistory: TxDetailDisplayData(
                                        notify: balanceNoti,
                                        tokenInfo: tokenInfo
                                    ).buildHistoryDisplayItem(wsMessage?.time),
                                    tokenInfo: tokenInfo
                                )
                            }
                        })
                    } else {
                        moduleDependencies.displayTransactionDetail(
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
        return moduleDependencies.requestSupportBeacon(info: info)
    }
    
    public static func getOffchainTokenInfo() -> Promise<OffchainInfoDTO> {
        return moduleDependencies.getOffchainTokenInfo()
    }
    
    public static func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return moduleDependencies.getInviteLink(locale: locale, inviteAppType: inviteAppType)
    }
    
    public static func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return moduleDependencies.getListLanguageInfo()
    }
    
    public static func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return moduleDependencies.updateCodeLinkInstallApp(codeString: codeString)
    }
    
    public static func processInvitationCode() {
        return moduleDependencies.processInvitationCode()
    }
    
    public static func getListNotification(page: Int = 0, size: Int = 15) -> Promise<[WSMessage]> {
        return moduleDependencies.getListNotification(page: page, size: size)
    }
    
    public static func getSuggestKeySearch(lat: Double = 0, lon: Double = 0) -> Promise<[String]> {
        return moduleDependencies.getSuggestKeySearch(lat: lat, lon: lon)
    }
    
    public static func loadUserProfile() -> Promise<UserProfileDTO> {
        return moduleDependencies.loadUserProfile()
    }
    
    public static func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return moduleDependencies.getCreateAirdropEventSettings()
    }
    
    public static func requestForChangePin() {
        return moduleDependencies.requestForChangePin()
    }
    
    public static func requestForBackUpWallet() {
        return moduleDependencies.requestForBackUpWallet()
    }
    
    public static func getRetailerPromotionList(page: Int = 0, size: Int = 15, statusRequest: PromotionStatusRequestEnum = .RUNNING) -> Promise<[PromotionDTO]> {
        return moduleDependencies.getRetailerPromotionList(page: page, size: size, statusRequest: statusRequest)
    }
    
    public static func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return moduleDependencies.processPromotionCode(code: code)
    }
    
    public static func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return moduleDependencies.usePromotionCode(code: code, billInfo: billInfo)
    }
    
    public static func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return moduleDependencies.cancelPromotionCode(code: code)
    }
    
    public static func getShopperPromotionListWithType(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0, type: PromotionListTypeEnum = .TOP) -> Promise<[PromotionStoreDTO]> {
        return moduleDependencies.getShopperPromotionListWithType(page: page, size: size, long: long, lat: lat, type: type)
    }
    
    public static func getPromotionRedeemInfo(promotionId: Int64, branchId: Int64) -> Promise<PromotionRedeemInfoDTO> {
        return moduleDependencies.getPromotionRedeemInfo(promotionId: promotionId, branchId: branchId)
    }
    
    public static func redeemPromotion(_ promotionId: Int64, delegate: RedeemPromotionDelegate) {
        return moduleDependencies.redeemPromotion(promotionId, delegate: delegate)
    }
    
    public static func getPromotionPaidDetail(promotionId: Int64) -> Promise<PromotionPaidDTO> {
        return moduleDependencies.getPromotionPaidDetail(promotionId: promotionId)
    }
    
    public static func getPromotionPaidDetailByCode(_ promotionCode: String) -> Promise<PromotionPaidDTO> {
        return moduleDependencies.getPromotionPaidDetailByCode(promotionCode)
    }
    
    public static func processPromotionByCustomCode(code: String, branchId: Int64, lat: Double? = nil, lng: Double? = nil) -> Promise<Any> {
        return moduleDependencies.processPromotionByCustomCode(code: code, branchId: branchId, lat: lat, lng: lng)
    }
    
    public static func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return moduleDependencies.updateFavoritePromotion(promotionId, isFavorite: isFavorite)
    }
    
    public static func getPromotionPaidHistoryDetail(_ id: Int64) -> Promise<PromotionPaidDTO> {
        return moduleDependencies.getPromotionPaidHistoryDetail(id)
    }
    
    public static func getShopperPromotionRunning(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0, storeId: Int64) -> Promise<JSON> {
        return moduleDependencies.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId)
    }
    
    public static func getRetailerPromotionScannedList(page: Int = 0, size: Int = 15) -> Promise<[PromotionCodeInfoDTO]> {
        return moduleDependencies.getRetailerPromotionScannedList(page: page, size: size)
    }
    
    public static func getRetailerCountPromotion() -> Promise<Int> {
        return moduleDependencies.getRetailerCountPromotion()
    }
    
    public static func getGPSBeacons(params: [String: Any]) -> Promise<[String]> {
        return moduleDependencies.getGPSBeacons(params: params)
    }
    
    public static func searchPromotionsWithText(_ text: String, page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0) -> Promise<CollectionPromotionInfoDTO> {
        return moduleDependencies.searchPromotionsWithText(text, page: page, size: size, long: long, lat: lat)
    }
    
    public static func getSuggestKeySearchForPromotion(lat: Double = 0, lon: Double = 0) -> Promise<[String]> {
        return moduleDependencies.getSuggestKeySearchForPromotion(lat: lat, lon: lon)
    }
    
    // MARK: TOP UP
    public static func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (moduleDependencies.loadTopUpBalanceInfo())
    }
    
    public static func loadTopUpHistory(topUpAddress: String? = nil, page: Int = 0, size: Int = 15) -> Promise<TxHistoryDisplayCollection> {
        return (moduleDependencies.loadTopUpHistory(topUpAddress: topUpAddress, page: page, size: size))
    }
    
    public static func openTopUpTransfer(delegate: TopUpDelegate) {
        moduleDependencies.openTopUpTransfer(delegate: delegate)
    }
    
    public static func topUpWithdraw(delegate: TopUpWithdrawDelegate) {
        moduleDependencies.topUpWithdraw(delegate: delegate)
    }
    
    public static func getShopperPromotionInStore(storeId: Int64, type: PromotionListTypeEnum, page: Int = 0, size: Int = 5, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        moduleDependencies.getShopperPromotionInStore(storeId: storeId, type: type, page: page, size: size, long: long, lat: lat)
    }
    
    public static func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return moduleDependencies.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat)
    }
    
    public static func getBranchList(page: Int = 0, forSwitching: Bool) -> Promise<[String: Any]> {
        return moduleDependencies.getBranchList(page: page, forSwitching: forSwitching)
    }
     
    public static func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return moduleDependencies.switchBranch(branchId)
    }
    
    public static func getRetailerInfoForLauching() -> Promise<[String: Any]> {
        return moduleDependencies.getRetailerInfoForLauching()
    }
    
    public static func checkBranchName(_ name: String) -> Promise<Any> {
        return moduleDependencies.checkBranchName(name)
    }
    
    public static func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO> {
        return moduleDependencies.updateSalePerson(account: account)
    }
    
    public static func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return moduleDependencies.registerMoreBeacon(parameters: parameters)
    }
    
    // MARK: Mozo Messages APIs
    public static func getConversationList(text: String?, page: Int) -> Promise<[Conversation]> {
        return moduleDependencies.getConversationList(text: text, page: page)
    }
    public static func getConversationDetails(id: Int64) -> Promise<Conversation?> {
        return moduleDependencies.getConversationDetails(id: id)
    }
    public static func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]> {
        return moduleDependencies.getChatMessages(id: id, page: page)
    }
    public static func responseConversation(conversationId: Int64, status: String) -> Promise<Any> {
        return moduleDependencies.responseConversation(conversationId: conversationId, status: status)
    }
    public static func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any> {
        return moduleDependencies.updateReadConversation(conversationId: conversationId, lastMessageId: lastMessageId)
    }
    public static func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any> {
        return moduleDependencies.sendMessage(id: id, message: message, images: images, userSend: userSend)
    }
}
