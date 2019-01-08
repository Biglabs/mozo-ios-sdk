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

public class MozoSDK {
    private static var moduleDependencies: ModuleDependencies!
    
    public static func configure(apiKey: String = Configuration.API_KEY_DEFAULT, network: MozoNetwork = .DevNet, appType: AppType = .Shopper) {
        Configuration.SUB_DOMAIN_ENUM = network.serviceType
        moduleDependencies = ModuleDependencies()
        moduleDependencies.apiKey = apiKey
        moduleDependencies.network = network
        moduleDependencies.appType = appType
    }
    
    public static func setAuthDelegate(_ delegate: AuthenticationDelegate) {
        moduleDependencies.setAuthDelegate(delegate)
    }
    
    public static func authenticate() {
        moduleDependencies.authenticate()
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
    
    public static func loadBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (moduleDependencies.loadBalanceInfo())
    }
    
    public static func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.registerBeacon(parameters:parameters))
    }
    
    public static func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.updateBeaconSettings(parameters:parameters))
    }
    
    public static func getListBeacons() -> Promise<[String : Any]> {
        return (moduleDependencies.getListBeacons())
    }
    
    public static func getRetailerInfo() -> Promise<[String : Any]> {
        return (moduleDependencies.getRetailerInfo())
    }
    
    public static func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (moduleDependencies.addRetailerSalePerson(parameters:parameters))
    }
    
    public static func getAirdropStoreNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]> {
        return (moduleDependencies.getAirdropStoreNearby(params: params))
    }
    
    public static func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String : Any]> {
        return (moduleDependencies.sendRangedBeacons(beacons: beacons, status: status))
    }
    
    public static func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
        return (moduleDependencies.getRangeColorSettings())
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
    
    public static func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return moduleDependencies.getLatestAirdropEvent()
    }
    
    public static func getAirdropEventList(page: Int) -> Promise<[AirdropEventDTO]> {
        return moduleDependencies.getAirdropEventList(page: page)
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
    
    public static func getNearestStores() -> Promise<[StoreInfoDTO]> {
        return moduleDependencies.getNearestStores()
    }
    
    public static func searchStoresWithText(_ text: String, page: Int = 0, size: Int = 15) -> Promise<CollectionStoreInfoDTO> {
        return moduleDependencies.searchStoresWithText(text, page: page, size: size)
    }
    
    public static func getFavoriteStores() -> Promise<[StoreInfoDTO]> {
        return moduleDependencies.getFavoriteStores()
    }
    
    public static func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return moduleDependencies.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite)
    }
}
