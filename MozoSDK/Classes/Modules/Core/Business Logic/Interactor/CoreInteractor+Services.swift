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
    
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]>{
        return apiManager.registerBeacon(parameters: parameters, isCreateNew: true)
    }
    
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]>{
        return apiManager.registerBeacon(parameters: parameters, isCreateNew: false)
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
    
    func getAirdropStoreNearby(params: [String : Any]) -> Promise<[StoreInfoDTO]> {
        return apiManager.getAirdropStoresNearby(params: params)
        //        return Promise { seal in
        //            _ = apiManager.getAirdropStoresNearby(params: params).done({ (stores) in
        //                let resultStores : [StoreInfoDTO] = stores.map {
        //                    $0.customerAirdropAmount = ($0.customerAirdropAmount ?? 0) / 100
        //                    return $0
        //                }
        //                return seal.fulfill(resultStores)
        //            }).catch({ (error) in
        //
        //            })
        //        }
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
    
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        print("😎 Get latest airdrop event.")
        return apiManager.getLatestAirdropEvent()
    }
    
    func getAirdropEventList(page: Int) -> Promise<[AirdropEventDTO]> {
        print("😎 Get airdrop event list by page number \(page).")
        return apiManager.getAirdropEventList(page: page)
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
    
    func getNearestStores() -> Promise<[StoreInfoDTO]> {
        return apiManager.getNearestStores()
    }
    
    func searchStoresWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double, sort: String) -> Promise<CollectionStoreInfoDTO> {
        return apiManager.searchStoresWithText(text, page: page, size: size, long: long, lat: lat, sort: sort)
    }
    
    func getFavoriteStores() -> Promise<[StoreInfoDTO]> {
        return apiManager.getFavoriteStores()
    }
    
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return apiManager.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite)
    }
}
