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
    private static var moduleDependencies = ModuleDependencies()
    
    public static func configure(apiKey: String = Configuration.API_KEY_DEFAULT, network: MozoNetwork = .TestNet) {
        moduleDependencies.apiKey = apiKey
        moduleDependencies.network = network
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
    
    /**
     Display Mozo wallet interface.
     - Author:
     Hoang Nguyen
     
     - Version:
     0.1
     
     Return a view controller.
     */
    public static func getMyWalletViewController() {
        
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
}
