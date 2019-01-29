//
//  CoreInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import PromiseKit

protocol CoreInteractorInput {
    func checkForAuthentication(module: Module)
    func handleAferAuth(accessToken: String?)
    func downloadAndStoreConvenienceData()
    func notifyAuthSuccessForAllObservers()
    func notifyLogoutForAllObservers()
    func notifyBalanceChangesForAllObservers(balanceNoti: BalanceNotification)
    func notifyAddressBookChangesForAllObservers()
    func notifyStoreBookChangesForAllObservers()
}

protocol CoreInteractorOutput {
    func finishedCheckAuthentication(keepGoing: Bool, module: Module)
    func continueWithWallet(_ callbackModule: Module)
    func finishedHandleAferAuth()
    func failToLoadUserInfo(_ error: ConnectionError, for requestingModule: Module?)
}

protocol CoreInteractorService {
    func loadBalanceInfo() -> Promise<DetailInfoDisplayItem>
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]>
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]>
    func getListBeacons() -> Promise<[String : Any]>
    func getRetailerInfo() -> Promise<[String : Any]>
    func addSalePerson(parameters: Any?) -> Promise<[String: Any]>
    
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]>
    
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection>
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO>
    func getAirdropEventList(page: Int) -> Promise<[AirdropEventDTO]>
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?>
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]>
    func getRetailerAnalyticAmountAirdropList(page: Int, size: Int, year: Int, month: Int) -> Promise<[AirDropReportDTO]>
    func getVisitCustomerList(page: Int, size: Int, year: Int, month: Int) -> Promise<[VisitedCustomerDTO]>
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]>
    func getListSalePerson() -> Promise<[SalePersonDTO]>
    func removeSalePerson(id: Int64) -> Promise<[String: Any]>
    func getListCountryCode() -> Promise<[CountryCodeDTO]>
    
    func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]>
    func getAirdropStoreNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]>
    func getListEventAirdropOfStore(_ storeId: Int64) -> Promise<[StoreInfoDTO]>
    func getNearestStores(_ storeId: Int64) -> Promise<[StoreInfoDTO]>
    func searchStoresWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double, sort: String) -> Promise<CollectionStoreInfoDTO>
    func getFavoriteStores(page: Int, size: Int) -> Promise<[StoreInfoDTO]>
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]>
    func getTodayCollectedAmount(startTime: Int, endTime: Int) -> Promise<NSNumber>
    
    func getUrlToUploadImage() -> Promise<String>
    func uploadImage(images: [UIImage], url: String) -> Promise<[String]>
    
    func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO>
    func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO>
}
