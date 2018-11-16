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
    func downloadConvenienceDataAndStoreAtLocal()
    func notifyAuthSuccessForAllObservers()
    func notifyLogoutForAllObservers()
    func notifyBalanceChangesForAllObservers(balanceNoti: BalanceNotification)
    func notifyAddressBookChangesForAllObservers()
}

protocol CoreInteractorOutput {
    func finishedCheckAuthentication(keepGoing: Bool, module: Module)
    func continueWithWallet(_ callbackModule: Module)
    func finishedHandleAferAuth()
}

protocol CoreInteractorService {
    func loadBalanceInfo() -> Promise<DetailInfoDisplayItem>
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]>
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]>
    func getListBeacons() -> Promise<[String : Any]>
    func getRetailerInfo() -> Promise<[String : Any]>
    func addSalePerson(parameters: Any?) -> Promise<[String: Any]>
    func getAirdropStoreNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]>
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String: Any]>
    func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]>
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection>
}
