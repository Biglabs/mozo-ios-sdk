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
    static var modules: ModuleDependencies!

    private(set) static var network: MozoNetwork = .TestNet {
        didSet {
            modules.authWireframe.authPresenter?.authInteractor?.updateNetwork(network)
        }
    }
    
    private(set) static var appType: AppType = .Shopper {
        didSet {
            modules.webSocketManager.appType = appType
            modules.authWireframe.authPresenter?.authInteractor?.updateClientId(appType)
        }
    }
    
    public private(set) static var homePage: String = "https://\(Configuration.BASE_DOMAIN.landingPage)"
    
    public static func configure(network: MozoNetwork = .TestNet, appType: AppType = .Shopper) {
        switch network {
            case .DevNet: Configuration.BASE_DOMAIN = .DEVELOP
            case .TestNet: Configuration.BASE_DOMAIN = .STAGING
            case .MainNet: Configuration.BASE_DOMAIN = .PRODUCTION
        }
        modules = ModuleDependencies()
        self.network = network
        self.appType = appType
    }
    
    public static func setAuthDelegate(_ delegate: AuthenticationDelegate) {
        modules.setAuthDelegate(delegate)
    }
    
    public static func isNetworkReachable() -> Bool {
        return modules.isNetworkReachable()
    }
    
    public static func authenticate() {
        modules.authenticate()
    }
    
    public static func processAuthorizationCallBackUrl(_ url: URL) {
        modules.processAuthorizationCallBackUrl(url)
    }
    
    public static func logout() {
        modules.logout()
    }
    
    public static func transferMozo() {
        modules.transferMozo()
    }
    
    public static func displayTransactionHistory() {
        modules.displayTransactionHistory()
    }
    
    public static func displayPaymentRequest() {
        modules.displayPaymentRequest()
    }
    
    public static func displayAddressBook() {
        modules.displayAddressBook()
    }
    
    public static func displayTransactionDetail(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        modules.displayTransactionDetail(txHistory: txHistory, tokenInfo: tokenInfo)
    }
    
    public static func loadBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (modules.loadBalanceInfo())
    }
    
    public static func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO> {
        return (modules.loadEthAndOnchainBalanceInfo())
    }
    
    public static func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (modules.registerBeacon(parameters: parameters))
    }
    
    public static func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (modules.updateBeaconSettings(parameters: parameters))
    }
    
    public static func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return (modules.deleteBeacon(beaconId: beaconId))
    }
    
    public static func getRetailerInfo() -> Promise<[String : Any]> {
        return (modules.getRetailerInfo())
    }
    
    public static func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (modules.addRetailerSalePerson(parameters:parameters))
    }
    
    public static func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String : Any]> {
        return (modules.sendRangedBeacons(beacons: beacons, status: status))
    }
    
    public static func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return (modules.getTxHistoryDisplayCollection())
    }
    
    public static func createAirdropEvent(event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        return (modules.createAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func addMoreMozoToAirdropEvent(event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        return (modules.addMoreMozoToAirdropEvent(event: event, delegate: delegate))
    }
    
    public static func withdrawMozoFromAirdropEventId(_ eventId: Int64, delegate: WithdrawAirdropEventDelegate) {
        return (modules.withdrawMozoFromAirdropEventId(eventId, delegate: delegate))
    }
    
    public static func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return modules.getLatestAirdropEvent()
    }
    
    public static func getAirdropEventList(page: Int, branchId: Int64? = nil) -> Promise<[AirdropEventDTO]> {
        return modules.getAirdropEventList(page: page, branchId: branchId)
    }
    
    public static func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return modules.getRetailerAnalyticHome()
    }
    
    public static func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return modules.getRetailerAnalyticList()
    }
    
    public static func getVisitCustomerList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[VisitedCustomerDTO]> {
        return modules.getVisitCustomerList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRetailerAnalyticAmountAirdropList(page: Int, size: Int = 15, year: Int = 0, month: Int = 0) -> Promise<[AirDropReportDTO]> {
        return modules.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month)
    }
    
    public static func getRunningAirdropEvents(page: Int = 0, size: Int = 5) -> Promise<[AirdropEventDTO]> {
        return modules.getRunningAirdropEvents(page: page, size: size)
    }
    
    public static func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return modules.getListSalePerson()
    }
    
    public static func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return modules.removeSalePerson(id: id)
    }
    
    public static func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return modules.getListCountryCode()
    }
    
    public static func searchStoresWithText(_ text: String, page: Int = 0, long: Double, lat: Double, sort: String = "distance") -> Promise<CollectionStoreInfoDTO> {
        return modules.searchStoresWithText(text, page: page, long: long, lat: lat, sort: sort)
    }
    
    public static func getFavoriteStores(page: Int = 0, size: Int = 15) -> Promise<[BranchInfoDTO]> {
        return modules.getFavoriteStores(page: page, size: size)
    }
    
    public static func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return modules.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite)
    }
    
    public static func getUserSummary(startTime: Int = 0, endTime: Int = 86400) -> Promise<UserSummary?> {
        return modules.getUserSummary(startTime: startTime, endTime: endTime)
    }
    
    public static func getUrlToUploadImage() -> Promise<String> {
        return modules.getUrlToUploadImage()
    }
    
    public static func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]> {
        return modules.uploadImage(images: images, url: url, progressionHandler: progressionHandler)
    }
    
    public static func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return modules.updateUserProfile(userProfile: userProfile)
    }
    
    public static func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return modules.updateAvatarToUserProfile(userProfile: userProfile)
    }
    
    public static func getCommonHashtag() -> Promise<[String]> {
        return modules.getCommonHashtag()
    }
    
    public static func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return modules.deleteRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return modules.updateRetailerStoreInfoPhotos(photos: photos)
    }
    
    public static func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return modules.updateRetailerStoreInfoHashtag(hashTags: hashTags)
    }
    
    public static func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return modules.updateRetailerStoreInfo(storeInfo: storeInfo)
    }
    
    public static func getStoreDetail(_ storeId: Int64) -> Promise<BranchInfoDTO> {
        return modules.getStoreDetail(storeId)
    }
    
    public static func getRecommendationStores(_ storeId: Int64, size: Int = 5, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return modules.getRecommendationStores(storeId, size: size, long: long, lat: lat)
    }
    
    public static func handleAccessRemove() {
        return modules.handleAccessRemove()
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
                        _ = modules.coreWF.corePresenter?.coreInteractorService?.loadBalanceInfo().done({ _ in
                            if let tokenInfo = SessionStoreManager.tokenInfo {
                                modules.displayTransactionDetail(
                                    txHistory: TxDetailDisplayData(
                                        notify: balanceNoti,
                                        tokenInfo: tokenInfo
                                    ).buildHistoryDisplayItem(wsMessage?.time),
                                    tokenInfo: tokenInfo
                                )
                            }
                        })
                    } else {
                        modules.displayTransactionDetail(
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
        return modules.requestSupportBeacon(info: info)
    }
    
    public static func getOffchainTokenInfo() -> Promise<OffchainInfoDTO> {
        return modules.getOffchainTokenInfo()
    }
    
    public static func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return modules.getInviteLink(locale: locale, inviteAppType: inviteAppType)
    }
    
    public static func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return modules.getListLanguageInfo()
    }
    
    public static func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return modules.updateCodeLinkInstallApp(codeString: codeString)
    }
    
    public static func processInvitationCode() {
        return modules.processInvitationCode()
    }
    
    public static func getListNotification(page: Int = 0, size: Int = 15) -> Promise<[WSMessage]> {
        return modules.getListNotification(page: page, size: size)
    }
    
    public static func getSuggestKeySearch(lat: Double = 0, lon: Double = 0) -> Promise<[String]> {
        return modules.getSuggestKeySearch(lat: lat, lon: lon)
    }
    
    public static func loadUserProfile() -> Promise<UserProfileDTO> {
        return modules.loadUserProfile()
    }
    
    public static func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return modules.getCreateAirdropEventSettings()
    }
    
    public static func requestForChangePin() {
        return modules.requestForChangePin()
    }
    
    public static func requestForBackUpWallet() {
        return modules.requestForBackUpWallet()
    }
    
    public static func getRetailerPromotionList(page: Int = 0, size: Int = 15, statusRequest: PromotionStatusRequestEnum = .RUNNING) -> Promise<[PromotionDTO]> {
        return modules.getRetailerPromotionList(page: page, size: size, statusRequest: statusRequest)
    }
    
    public static func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return modules.processPromotionCode(code: code)
    }
    
    public static func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return modules.usePromotionCode(code: code, billInfo: billInfo)
    }
    
    public static func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return modules.cancelPromotionCode(code: code)
    }
    
    public static func getShopperPromotionListWithType(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0, type: PromotionListTypeEnum = .TOP) -> Promise<[PromotionStoreDTO]> {
        return modules.getShopperPromotionListWithType(page: page, size: size, long: long, lat: lat, type: type)
    }
    
    public static func getPromotionRedeemInfo(promotionId: Int64, branchId: Int64) -> Promise<PromotionRedeemInfoDTO> {
        return modules.getPromotionRedeemInfo(promotionId: promotionId, branchId: branchId)
    }
    
    public static func getBranchesInChain(promotionId: Int64, lat: Double, lng: Double) -> Promise<[BranchInfoDTO]> {
        return modules.getBranchesInChain(promotionId: promotionId, lat: lat, lng: lng)
    }
    
    public static func redeemPromotion(_ promotionId: Int64, delegate: RedeemPromotionDelegate) {
        return modules.redeemPromotion(promotionId, delegate: delegate)
    }
    
    public static func getPromotionPaidDetail(promotionId: Int64) -> Promise<PromotionPaidDTO> {
        return modules.getPromotionPaidDetail(promotionId: promotionId)
    }
    
    public static func getPromotionPaidDetailByCode(_ promotionCode: String) -> Promise<PromotionPaidDTO> {
        return modules.getPromotionPaidDetailByCode(promotionCode)
    }
    
    public static func processPromotionByCustomCode(code: String, branchId: Int64, lat: Double? = nil, lng: Double? = nil) -> Promise<Any> {
        return modules.processPromotionByCustomCode(code: code, branchId: branchId, lat: lat, lng: lng)
    }
    
    public static func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return modules.updateFavoritePromotion(promotionId, isFavorite: isFavorite)
    }
    
    public static func getPromotionPaidHistoryDetail(_ id: Int64) -> Promise<PromotionPaidDTO> {
        return modules.getPromotionPaidHistoryDetail(id)
    }
    
    public static func getShopperPromotionSaved(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0) -> Promise<[PromotionStoreDTO]> {
        return modules.getShopperPromotionSaved(page: page, size: size, long: long, lat: lat)
    }
    
    public static func getShopperPromotionRunning(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0, storeId: Int64) -> Promise<JSON> {
        return modules.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId)
    }
    
    public static func getShopperPromotionPurchased(page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0) -> Promise<[PromotionStoreDTO]> {
        return modules.getShopperPromotionPurchased(page: page, size: size, long: long, lat: lat)
    }
    
    public static func getShopperPromotionHistory(page: Int = 0, size: Int = 15) -> Promise<[PromotionStoreDTO]> {
        return modules.getShopperPromotionHistory(page: page, size: size)
    }
    
    public static func getRetailerPromotionScannedList(page: Int = 0, size: Int = 15) -> Promise<[PromotionCodeInfoDTO]> {
        return modules.getRetailerPromotionScannedList(page: page, size: size)
    }
    
    public static func getRetailerCountPromotion() -> Promise<Int> {
        return modules.getRetailerCountPromotion()
    }
    
    public static func getShopperTodoList(blueToothOff: Bool, long: Double, lat: Double) -> Promise<[TodoDTO]> {
        return modules.getShopperTodoList(blueToothOff: blueToothOff, long: long, lat: lat)
    }
    
    public static func getTodoListSetting() -> Promise<TodoSettingDTO> {
        return modules.getTodoListSetting()
    }
    
    public static func getGPSBeacons(params: [String: Any]) -> Promise<[String]> {
        return modules.getGPSBeacons(params: params)
    }
    
    public static func searchPromotionsWithText(_ text: String, page: Int = 0, size: Int = 15, long: Double = 0, lat: Double = 0) -> Promise<CollectionPromotionInfoDTO> {
        return modules.searchPromotionsWithText(text, page: page, size: size, long: long, lat: lat)
    }
    
    public static func getSuggestKeySearchForPromotion(lat: Double = 0, lon: Double = 0) -> Promise<[String]> {
        return modules.getSuggestKeySearchForPromotion(lat: lat, lon: lon)
    }
    
    // MARK: PARKING TICKET
    
    public static func getParkingTicketStatus(id: Int64, isIn: Bool) -> Promise<ParkingTicketStatusType> {
        return modules.getParkingTicketStatus(id: id, isIn: isIn)
    }
    
    public static func getParkingTicketByStoreId(storeId: Int64, isIn: Bool) -> Promise<TicketDTO> {
        return modules.getParkingTicketByStoreId(storeId: storeId, isIn: isIn)
    }
    
    public static func getParkingTicketByStoreId(storeId: Int64) -> Promise<TicketDTO> {
        return modules.getParkingTicketByStoreId(storeId: storeId)
    }
        
    public static func renewParkingTicket(id: Int64, vehicleTypeKey: String, isIn: Bool) -> Promise<TicketDTO> {
        return modules.renewParkingTicket(id: id, vehicleTypeKey: vehicleTypeKey, isIn: isIn)
    }
    
    // MARK: TOP UP
    public static func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (modules.loadTopUpBalanceInfo())
    }
    
    public static func loadTopUpHistory(topUpAddress: String? = nil, page: Int = 0, size: Int = 15) -> Promise<TxHistoryDisplayCollection> {
        return (modules.loadTopUpHistory(topUpAddress: topUpAddress, page: page, size: size))
    }
    
    public static func openTopUpTransfer(delegate: TopUpDelegate) {
        modules.openTopUpTransfer(delegate: delegate)
    }
    
    public static func topUpWithdraw(delegate: TopUpWithdrawDelegate) {
        modules.topUpWithdraw(delegate: delegate)
    }
    
    public static func getShopperPromotionInStore(storeId: Int64, type: PromotionListTypeEnum, page: Int = 0, size: Int = 5, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]> {
        modules.getShopperPromotionInStore(storeId: storeId, type: type, page: page, size: size, long: long, lat: lat)
    }
    
    public static func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return modules.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat)
    }
    
    public static func getBranchList(page: Int = 0, forSwitching: Bool) -> Promise<[String: Any]> {
        return modules.getBranchList(page: page, forSwitching: forSwitching)
    }
     
    public static func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return modules.switchBranch(branchId)
    }
    
    public static func getRetailerInfoForLauching() -> Promise<[String: Any]> {
        return modules.getRetailerInfoForLauching()
    }
    
    public static func checkBranchName(_ name: String) -> Promise<Any> {
        return modules.checkBranchName(name)
    }
    
    public static func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO> {
        return modules.updateSalePerson(account: account)
    }
    
    public static func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return modules.registerMoreBeacon(parameters: parameters)
    }
    
    // MARK: COVID-19 support APIs
    public static func getCovidZones(params: [String: Any]) -> Promise<[CovidZone]> {
        return modules.getCovidZones(params: params)
    }
    
    // MARK: Mozo Messages APIs
    public static func getConversationList(text: String?, page: Int) -> Promise<[Conversation]> {
        return modules.getConversationList(text: text, page: page)
    }
    public static func getConversationDetails(id: Int64) -> Promise<Conversation?> {
        return modules.getConversationDetails(id: id)
    }
    public static func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]> {
        return modules.getChatMessages(id: id, page: page)
    }
    public static func responseConversation(conversationId: Int64, status: String) -> Promise<Any> {
        return modules.responseConversation(conversationId: conversationId, status: status)
    }
    public static func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any> {
        return modules.updateReadConversation(conversationId: conversationId, lastMessageId: lastMessageId)
    }
    public static func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any> {
        return modules.sendMessage(id: id, message: message, images: images, userSend: userSend)
    }
}
