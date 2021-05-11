//
//  CoreInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import PromiseKit
import SwiftyJSON
protocol CoreInteractorInput {
    func checkForAuthentication(module: Module)
    func stopCheckTokenTimer()
    func handleAferAuth(accessToken: String?)
    func handleUserProfileAfterAuth()
    
    func downloadAndStoreConvenienceData()
    func notifyAuthSuccessForAllObservers()
    func notifyLogoutForAllObservers()
    func notifyBalanceChangesForAllObservers(balanceNoti: BalanceNotification)
    func notifyAddressBookChangesForAllObservers()
    func notifyStoreBookChangesForAllObservers()
    func notifyDidCloseAllMozoUIForAllObservers()
    func notifyConvertSuccessOnchainToOffchain(balanceNoti: BalanceNotification)
    func notifyProfileChangesForAllObserver()
    func notifyMaintenance(isComplete: Bool)
    
    func notifyTokenExpired()
}

protocol CoreInteractorOutput {
    func finishedCheckAuthentication(keepGoing: Bool, module: Module)
    func continueWithWallet(_ callbackModule: Module)
    func continueWithSpeedSelection(_ callbackModule: Module)
    func continueWithWalletAuto(_ callbackModule: Module)
    func finishedHandleAferAuth()
    func failToLoadUserInfo(_ error: ConnectionError, for requestingModule: Module?)
    
    func didReceiveInvalidToken()
    func didReceiveAuthorizationRequired()
    
    func didReceiveMaintenance()
    
    func didDetectWalletInAutoMode(module: Module)
    
    func didReceiveDeactivated(error: ErrorApiResponse)
    func didReceiveRequireUpdate(type: ErrorApiResponse)
}

protocol CoreInteractorService {
    func loadBalanceInfo() -> Promise<DetailInfoDisplayItem>
    func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO>
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]>
    func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]>
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]>
    func deleteBeacon(beaconId: Int64) -> Promise<Bool>
    func getListBeacons() -> Promise<[String : Any]>
    func getRetailerInfo() -> Promise<[String : Any]>
    func addSalePerson(parameters: Any?) -> Promise<[String: Any]>
    
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]>
    
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection>
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO>
    func getAirdropEventList(page: Int, branchId: Int64?) -> Promise<[AirdropEventDTO]>
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?>
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]>
    func getRetailerAnalyticAmountAirdropList(page: Int, size: Int, year: Int, month: Int) -> Promise<[AirDropReportDTO]>
    func getVisitCustomerList(page: Int, size: Int, year: Int, month: Int) -> Promise<[VisitedCustomerDTO]>
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]>
    func getListSalePerson() -> Promise<[SalePersonDTO]>
    func removeSalePerson(id: Int64) -> Promise<[String: Any]>
    func getListCountryCode() -> Promise<[CountryCodeDTO]>
    
    func getAirdropStoreNearby(params: [String: Any]) -> Promise<[AirdropEventDiscoverDTO]>
    func getListEventAirdropOfStore(_ storeId: Int64) -> Promise<[AirdropEventDiscoverDTO]>
    
    func searchStoresWithText(_ text: String, page: Int, long: Double, lat: Double, sort: String) -> Promise<CollectionStoreInfoDTO>
    func getFavoriteStores(page: Int, size: Int) -> Promise<[BranchInfoDTO]>
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]>
    func getUserSummary(startTime: Int, endTime: Int) -> Promise<UserSummary?>
    
    func getUrlToUploadImage() -> Promise<String>
    func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]>
    
    func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO>
    func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO>
    func getCommonHashtag() -> Promise<[String]>
    func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO>
    func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO>
    func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO>
    func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO>
    
    func getStoreDetail(_ storeId: Int64) -> Promise<BranchInfoDTO>
    func getRecommendationStores(_ storeId: Int64, size: Int, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]>
    
    func getDiscoverAirdrops(type: AirdropEventDiscoverType, page: Int, size: Int, long: Double, lat: Double) -> Promise<[String: Any]>
    
    func requestSupportBeacon(info: SupportRequestDTO) -> Promise<[String: Any]>
    
    func getOffchainTokenInfo() -> Promise<OffchainInfoDTO>
    
    func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO>
    
    func getListLanguageInfo() -> Promise<[InviteLanguageDTO]>
    
    func processInvitationCode()
    
    func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO>
    
    func getListNotification(page: Int, size: Int) -> Promise<[WSMessage]>
    
    func getSuggestKeySearch(lat: Double, lon: Double) -> Promise<[String]>
    
    func loadUserProfile() -> Promise<UserProfileDTO>
    
    func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO>
    
    func getPromoCreateSetting() -> Promise<PromotionSettingDTO>
    
    func createPromotion(_ promotion: PromotionDTO) -> Promise<[String: Any]>
    
    func getRetailerPromotionList(page: Int, size: Int, statusRequest: PromotionStatusRequestEnum) -> Promise<[PromotionDTO]>
    
    func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO>
    
    func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO>
    func cancelPromotionCode(code: String) -> Promise<[String: Any]>
    
    func getShopperPromotionListWithType(page: Int, size: Int, long: Double, lat: Double, type: PromotionListTypeEnum) -> Promise<[PromotionStoreDTO]>
    
    func getPromotionRedeemInfo(promotionId: Int64, branchId: Int64) -> Promise<PromotionRedeemInfoDTO>
    
    func getBranchesInChain(promotionId: Int64, lat: Double, lng: Double) -> Promise<[BranchInfoDTO]>
    
    func getPromotionPaidDetail(promotionId: Int64) -> Promise<PromotionPaidDTO>
    
    func getPromotionPaidDetailByCode(_ promotionCode: String) -> Promise<PromotionPaidDTO>
    
    func processPromotionByCustomCode(code: String, branchId: Int64, lat: Double?, lng: Double?) -> Promise<Any>
    
    func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]>
    
    func getPromotionPaidHistoryDetail(_ id: Int64) -> Promise<PromotionPaidDTO>
    
    func getShopperPromotionSaved(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]>
    
    func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON>
    
    func getShopperPromotionPurchased(page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]>
    
    func getShopperPromotionHistory(page: Int, size: Int) -> Promise<[PromotionStoreDTO]>
    
    func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]>
    
    func getRetailerCountPromotion() -> Promise<Int>
    
    func getShopperTodoList(blueToothOff: Bool, long: Double, lat: Double) -> Promise<[TodoDTO]>
    
    func getTodoListSetting() -> Promise<TodoSettingDTO>
    
    func getGPSBeacons(params: [String: Any]) -> Promise<[String]>
    
    func searchPromotionsWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double) -> Promise<CollectionPromotionInfoDTO>
    
    func getSuggestKeySearchForPromotion(lat: Double, lon: Double) -> Promise<[String]>
    
    func getParkingTicketStatus(id: Int64, isIn: Bool) -> Promise<ParkingTicketStatusType>
    
    func getParkingTicketByStoreId(storeId: Int64, isIn: Bool) -> Promise<TicketDTO>
    
    func getParkingTicketByStoreId(storeId: Int64) -> Promise<TicketDTO>
    
    func renewParkingTicket(id: Int64, vehicleTypeKey: String, isIn: Bool) -> Promise<TicketDTO>
    
    func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem>
        
    func loadTopUpHistory(topUpAddress: String?, page: Int, size: Int) -> Promise<TxHistoryDisplayCollection>
    
    func getShopperPromotionInStore(storeId: Int64, type: PromotionListTypeEnum, page: Int, size: Int, long: Double, lat: Double) -> Promise<[PromotionStoreDTO]>
    
    func getAirdropEventFromStore(_ storeId: Int64, type: AirdropEventType, page: Int, size: Int) -> Promise<[AirdropEventDiscoverDTO]>
    
    func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON>
    
    func confirmStoreInfoMerchant(branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO>
    
    func createNewBranch(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO>
    
    func updateBranchInfo(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO>
     
    func switchBranch(_ branchId: Int64) -> Promise<[String: Any]>
    
    func deleteBranchInfoPhotos(_ branchId: Int64, photos: [String]) -> Promise<BranchInfoDTO>
    
    func getBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO>
    
    func getBranchList(page: Int, forSwitching: Bool) -> Promise<[String: Any]>
    
    func getRetailerInfoForLauching() -> Promise<[String: Any]>
    
    func getBranchById(_ branchId: Int64) -> Promise<BranchInfoDTO>
    
    func checkBranchName(_ name: String) -> Promise<Any>
    
    func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO>
    
    func syncAddressFromBranchIntoBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO>
    
    func syncLocationFromBranchIntoBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO>
    
    // MARK: COVID-19 support APIs
    func getCovidZones(params: [String: Any]) -> Promise<[CovidZone]>
    
    // MARK: Mozo Messages APIs
    func getConversationList(text: String?, page: Int) -> Promise<[Conversation]>
    func getConversationDetails(id: Int64) -> Promise<Conversation?>
    func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]>
    func responseConversation(conversationId: Int64, status: String) -> Promise<Any>
    func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any>
    func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any>
}
