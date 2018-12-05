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
}
