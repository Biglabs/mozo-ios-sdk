//
//  CoreInteractor+Services.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/3/18.
//

import Foundation
import PromiseKit

extension CoreInteractor: CoreInteractorService {
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(),
                let address = userObj.profile?.walletInfo?.offchainAddress {
                print("Address used to load tx history: \(address)")
                apiManager.getListTxHistory(address: address, page: 0)
                    .done { (listTxHistory) in
                        let collection = TxHistoryDisplayCollection(items: listTxHistory)
                        seal.fulfill(collection)
                }.catch { (error) in
                    seal.reject(error)
                }
            } else {
                
            }
        }
    }
    
    func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
        return apiManager.getRangeColorSettings()
    }
    
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return apiManager.registerBeacon(parameters: parameters, isCreateNew: true)
    }
    
    func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return apiManager.registerMoreBeacon(parameters: parameters)
    }
    
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]>{
        return apiManager.registerBeacon(parameters: parameters, isCreateNew: false)
    }
    
    func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return apiManager.deleteBeacon(beaconId: beaconId)
    }
    
    func getListBeacons() -> Promise<[String : Any]> {
        return apiManager.getListBeacons()
    }
    
    func getRetailerInfo() -> Promise<[String : Any]> {
        return apiManager.getRetailerInfo()
    }
    
    func addSalePerson(parameters: Any?) -> Promise<[String : Any]> {
        return apiManager.addSalePerson(parameters: parameters)
    }
    
    func getAirdropStoreNearby(params: [String : Any]) -> Promise<[AirdropEventDiscoverDTO]> {
        return apiManager.getAirdropStoresNearby(params: params)
    }
    
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String : Any]> {
        return apiManager.sendRangedBeacons(beacons: beacons, status: status)
    }
    
    func loadBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        print("😎 Load balance info.")
        return Promise { seal in
            // TODO: Check authen and authorization first
            if let userObj = SessionStoreManager.loadCurrentUser() {
                if let address = userObj.profile?.walletInfo?.offchainAddress {
                    print("Address used to load balance: \(address)")
                    _ = apiManager.getTokenInfoFromAddress(address)
                        .done { (tokenInfo) in
                            SessionStoreManager.tokenInfo = tokenInfo
                            let item = DetailInfoDisplayItem(tokenInfo: tokenInfo)
                            seal.fulfill(item)
                    }.catch({ (err) in
                        seal.reject(err)
                    })
                }
            } else {
                seal.reject(SystemError.noAuthen)
            }
        }
    }
    
    func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO> {
        print("😎 Load ETH and onchain balance info.")
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser() {
                if let address = userObj.profile?.walletInfo?.onchainAddress {
                    print("Address used to load ETH and onchain balance: \(address)")
                    _ = apiManager.getEthAndOnchainTokenInfoFromAddress(address)
                        .done { (onchainInfo) in
                            SessionStoreManager.onchainInfo = onchainInfo
                            seal.fulfill(onchainInfo)
                    }.catch({ (err) in
                        seal.reject(err)
                    })
                }
            } else {
                seal.reject(SystemError.noAuthen)
            }
        }
    }
    
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        print("😎 Get latest airdrop event.")
        return apiManager.getLatestAirdropEvent()
    }
    
    func getAirdropEventList(page: Int, branchId: Int64?) -> Promise<[AirdropEventDTO]> {
        print("😎 Get airdrop event list by page number \(page).")
        return apiManager.getAirdropEventList(page: page, branchId: branchId)
    }
    
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        print("😎 Get retailer anylytic home.")
        return apiManager.getRetailerAnalyticHome()
    }
    
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        print("😎 Get retailer anylytic list in 6 months.")
        return apiManager.getRetailerAnalyticList()
    }
    
    func getVisitCustomerList(page: Int, size: Int, year: Int, month: Int) -> Promise<[VisitedCustomerDTO]> {
        print("😎 Get visit customer list.")
        return apiManager.getVisitCustomerList(page: page, size: size, year: year, month: month)
    }
    
    func getRetailerAnalyticAmountAirdropList(page: Int, size: Int, year: Int, month: Int) -> Promise<[AirDropReportDTO]> {
        print("😎 Get amount airdrop list.")
        return apiManager.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month)
    }
    
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]> {
        print("😎 Get running airdrop event list by page number \(page), size \(size).")
        return apiManager.getRunningAirdropEvents(page: page, size: size)
    }
    
    func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return apiManager.getListSalePerson()
    }
    
    func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return apiManager.removeSalePerson(id: id)
    }
    
    func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return apiManager.getListCountryCode()
    }
    
    func getListEventAirdropOfStore(_ storeId: Int64) -> Promise<[AirdropEventDiscoverDTO]> {
        return apiManager.getListEventAirdropOfStore(storeId)
    }
    
    func searchStoresWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double, sort: String) -> Promise<CollectionStoreInfoDTO> {
        return apiManager.searchStoresWithText(text, page: page, size: size, long: long, lat: lat, sort: sort)
    }
    
    func getFavoriteStores(page: Int, size: Int) -> Promise<[BranchInfoDTO]> {
        return apiManager.getFavoriteStores(page: page, size: size)
    }
    
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return apiManager.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite)
    }
    
    func getUserSummary(startTime: Int, endTime: Int) -> Promise<UserSummary?> {
        return apiManager.getUserSummary(startTime: startTime, endTime: endTime)
    }
    
    func getUrlToUploadImage() -> Promise<String> {
        return apiManager.getUrlToUploadImage()
    }
    
    func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]> {
        return apiManager.uploadImage(images: images, url: url, progressionHandler: progressionHandler)
    }
    
    func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return apiManager.updateUserProfile(userProfile: userProfile)
    }
    
    func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return apiManager.updateAvatarToUserProfile(userProfile: userProfile)
    }
    
    func getCommonHashtag() -> Promise<[String]> {
        return apiManager.getCommonHashtag()
    }
    
    func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return apiManager.deleteRetailerStoreInfoPhotos(photos: photos)
    }
    
    func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return apiManager.updateRetailerStoreInfoPhotos(photos: photos)
    }
    
    func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return apiManager.updateRetailerStoreInfoHashtag(hashTags: hashTags)
    }
    
    func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return apiManager.updateRetailerStoreInfo(storeInfo: storeInfo)
    }
    
    func getStoreDetail(_ storeId: Int64) -> Promise<BranchInfoDTO> {
        return apiManager.getStoreDetail(storeId)
    }
    
    func getRecommendationStores(_ storeId: Int64, size: Int, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return apiManager.getRecommendationStores(storeId, size: size, long: long, lat: lat)
    }
    
    func getDiscoverAirdrops(type: AirdropEventDiscoverType, page: Int, size: Int, long: Double, lat: Double) -> Promise<[String: Any]> {
        return apiManager.getDiscoverAirdrops(type: type, page: page, size: size, long: long, lat: lat)
    }
    
    func requestSupportBeacon(info: SupportRequestDTO) -> Promise<[String: Any]> {
        return apiManager.requestSupportBeacon(info: info)
    }
    
    func getOffchainTokenInfo() -> Promise<OffchainInfoDTO> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(), let address = userObj.profile?.walletInfo?.offchainAddress {
                print("Address used to load offchain and onchain balance: \(address)")
                _ = apiManager.getOffchainTokenInfo(address).done({ (offchainInfo) in
                    seal.fulfill(offchainInfo)
                }).catch({ (error) in
                    seal.reject(error)
                })
            }
        }
    }
    
    func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return apiManager.getInviteLink(locale: locale, inviteAppType: inviteAppType)
    }
    
    func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return apiManager.getListLanguageInfo()
    }
    
    func processInvitationCode() {
        self.processInvitation()
    }
    
    func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return apiManager.updateCodeLinkInstallApp(codeString: codeString)
    }
    
    func getListNotification(page: Int, size: Int) -> Promise<[WSMessage]> {
        return apiManager.getListNotification(page: page, size: size)
    }
    
    func getSuggestKeySearch(lat: Double, lon: Double) -> Promise<[String]> {
        return apiManager.getSuggestKeySearch(lat: lat, lon: lon)
    }
    
    func loadUserProfile() -> Promise<UserProfileDTO> {
        return Promise { seal in
            _ = apiManager.getUserProfile().done { (userProfile) in
                let user = UserDTO(id: userProfile.userId, profile: userProfile)
                SessionStoreManager.saveCurrentUser(user: user)
                seal.fulfill(userProfile)
            }.catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return apiManager.getCreateAirdropEventSettings()
    }
    
    func getShopperTodoList(blueToothOff: Bool, long: Double, lat: Double) -> Promise<[TodoDTO]> {
        return apiManager.getShopperTodoList(blueToothOff: blueToothOff, long: long, lat: lat)
    }
    
    func getTodoListSetting() -> Promise<TodoSettingDTO> {
        return apiManager.getTodoListSetting()
    }
    
    func getGPSBeacons(userLat: Double, userLong: Double) -> Promise<[String]> {
        return apiManager.getGPSBeacons(userLat: userLat, userLong: userLong)
    }
    
    func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return Promise { seal in
            _ = apiManager.getTopUpBalance()
                .done { (info) in
                    let item = DetailInfoDisplayItem(tokenInfo: info)
                    seal.fulfill(item)
            }.catch({ (err) in
                seal.reject(err)
            })
        }
    }
    
    func loadTopUpHistory(topUpAddress: String?, page: Int, size: Int) -> Promise<TxHistoryDisplayCollection> {
        return Promise { seal in
            if let userObj = SessionStoreManager.loadCurrentUser(),
                let offChainAddress = userObj.profile?.walletInfo?.offchainAddress {
                apiManager.getTopUpTxHistory(topUpAddress: topUpAddress, offChainAddress: offChainAddress, page: page, size: size)
                    .done { (listTxHistory) in
                        let collection = TxHistoryDisplayCollection(items: listTxHistory)
                        seal.fulfill(collection)
                }.catch { (error) in
                    seal.reject(error)
                }
            } else {
                seal.reject(PMKError.badInput)
            }
        }
    }
    
    func getAirdropEventFromStore(_ storeId: Int64, type: AirdropEventType, page: Int, size: Int) -> Promise<[AirdropEventDiscoverDTO]> {
        return apiManager.getAirdropEventFromStore(storeId, type: type, page: page, size: size)
    }
    
    func confirmStoreInfoMerchant(branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO> {
        return apiManager.confirmStoreInfoMerchant(branchInfo: branchInfo)
    }
    
    func sendRegisterFCMToken(registerDeviceInfo: APNSDeviceRegisterDTO) -> Promise<[String: Any]> {
        return apiManager.sendRegisterFCMToken(registerDeviceInfo: registerDeviceInfo)
    }
    
    func createNewBranch(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO> {
        return apiManager.createNewBranch(branchInfo)
    }
    
    func getBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO> {
        return apiManager.getBeacon(beaconId)
    }
    
    func getBranchList(page: Int, size: Int, forSwitching: Bool) -> Promise<[String: Any]> {
        return apiManager.getBranchList(page: page, size: size, forSwitching: forSwitching)
    }
    
    func updateBranchInfo(_ branchInfo: BranchInfoDTO) -> Promise<BranchInfoDTO> {
        return apiManager.updateBranchInfo(branchInfo)
    }
    
    func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return apiManager.switchBranch(branchId)
    }
    
    func deleteBranchInfoPhotos(_ branchId: Int64, photos: [String]) -> Promise<BranchInfoDTO> {
        return apiManager.deleteBranchInfoPhotos(branchId, photos: photos)
    }
    
    func getRetailerInfoForLauching() -> Promise<[String: Any]> {
        return apiManager.getRetailerInfoForLauching()
    }
    
    func getBranchById(_ branchId: Int64) -> Promise<BranchInfoDTO> {
        return apiManager.getBranchById(branchId)
    }
    
    func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO> {
        return apiManager.updateSalePerson(account: account)
    }
    
    func syncAddressFromBranchIntoBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO> {
        return apiManager.syncAddressFromBranchIntoBeacon(beaconId)
    }
    
    func syncLocationFromBranchIntoBeacon(_ beaconId: Int64) -> Promise<BeaconInfoDTO> {
        return apiManager.syncLocationFromBranchIntoBeacon(beaconId)
    }
    
    // MARK: COVID-19 support APIs
    func getCovidZones(params: [String : Any]) -> Promise<[CovidZone]> {
        return apiManager.getCovidZones(params: params)
    }
}
