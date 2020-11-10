//
//  CoreInteractor+Api.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/16/20.
//

import Foundation
extension CoreInteractor: ApiManagerDelegate {
    func didLoadTokenInfoSuccess(_ tokenInfo: TokenInfoDTO){
        print("CoreInteractor - Did Load Token Info Success")
        let item = DetailInfoDisplayItem(tokenInfo: tokenInfo)
        if SafetyDataManager.shared.offchainDetailDisplayData == nil || SafetyDataManager.shared.offchainDetailDisplayData != item {
            SafetyDataManager.shared.offchainDetailDisplayData = item
            notifyDetailDisplayItemForAllObservers()
        }
    }
    
    func didLoadTokenInfoFailed(){
        print("CoreInteractor - Did Load Token Info Failed")
        notifyLoadTokenInfoFailedForAllObservers()
    }
    
    func didLoadETHOnchainTokenSuccess(_ onchainInfo: OnchainInfoDTO) {
        print("CoreInteractor - Did load ETH and Onchain Token success")
        if let ethItem = onchainInfo.balanceOfETH {
            let item = DetailInfoDisplayItem(tokenInfo: ethItem)
            if SafetyDataManager.shared.ethDetailDisplayData == nil || SafetyDataManager.shared.ethDetailDisplayData != item {
                SafetyDataManager.shared.ethDetailDisplayData = item
                notifyETHDetailDisplayItemForAllObservers()
            }
        }
        if let onchainItem = onchainInfo.balanceOfToken {
            let item = DetailInfoDisplayItem(tokenInfo: onchainItem)
            if SafetyDataManager.shared.onchainDetailDisplayData == nil || SafetyDataManager.shared.onchainDetailDisplayData != item {
                SafetyDataManager.shared.onchainDetailDisplayData = item
                notifyOnchainDetailDisplayItemForAllObservers()
            }
        }
    }
    
    func didLoadOffchainInfoSuccess(_ offchainInfo: OffchainInfoDTO) {
        print("CoreInteractor - Did load offchain info success")
        if let offchainItem = offchainInfo.balanceOfTokenOffchain {
            let item = DetailInfoDisplayItem(tokenInfo: offchainItem)
            if SafetyDataManager.shared.offchainDetailDisplayData == nil || SafetyDataManager.shared.offchainDetailDisplayData != item {
                SafetyDataManager.shared.offchainDetailDisplayData = item
                notifyDetailDisplayItemForAllObservers()
            }
        }
        if let onchainItem = offchainInfo.balanceOfTokenOnchain {
            let item = DetailInfoDisplayItem(tokenInfo: onchainItem)
            if SafetyDataManager.shared.onchainFromOffchainDetailDisplayData == nil || SafetyDataManager.shared.onchainFromOffchainDetailDisplayData != item {
                SafetyDataManager.shared.onchainFromOffchainDetailDisplayData = item
                notifyOnchainDetailDisplayItemForAllObservers()
            }
        }
    }
    
    func didLoadOffchainInfoFailed() {
        print("CoreInteractor - Did load offchain info failed")
        notifyLoadTokenInfoFailedForAllObservers()
    }
    
    func didLoadETHSuccess(_ tokenInfo: TokenInfoDTO) {
        print("CoreInteractor - Did load ETH info success")
        if let user = SessionStoreManager.loadCurrentUser(), let walletInfo = user.profile?.walletInfo {
            if walletInfo.offchainAddress?.lowercased() == tokenInfo.address?.lowercased() {
                let item = DetailInfoDisplayItem(tokenInfo: tokenInfo)
                if SafetyDataManager.shared.ethDetailDisplayData == nil || SafetyDataManager.shared.ethDetailDisplayData != item {
                    SafetyDataManager.shared.ethDetailDisplayData = item
                    notifyETHOffchainDetailDisplayItemForAllObservers()
                }
                return
            }
            if walletInfo.onchainAddress?.lowercased() == tokenInfo.address?.lowercased() {
                let item = DetailInfoDisplayItem(tokenInfo: tokenInfo)
                if SafetyDataManager.shared.ethDetailDisplayData == nil || SafetyDataManager.shared.ethDetailDisplayData != item {
                    SafetyDataManager.shared.ethDetailDisplayData = item
                    notifyETHDetailDisplayItemForAllObservers()
                }
            }
        }
    }
    
    func didLoadETHFailed() {
        print("CoreInteractor - Did load ETH info failed")
        
    }
    
    func didLoadETHOnchainTokenFailed() {
        print("CoreInteractor - Did load ETH and Onchain Token Failed")
        notifyLoadETHOnchainTokenFailedForAllObservers()
    }
    
    func didReceiveInvalidToken() {
        print("CoreInteractor - Did receive invalid user token")
        output?.didReceiveInvalidToken()
    }
    
    func didReceiveAuthorizationRequired() {
        print("CoreInteractor - Did receive authorization required")
        output?.didReceiveAuthorizationRequired()
    }
    
    func didReceiveMaintenance() {
        print("CoreInteractor - Did receive maintenance")
        output?.didReceiveMaintenance()
    }
    
    func didReceiveDeactivated(error: ErrorApiResponse) {
        print("CoreInteractor - Did receive maintenance")
        output?.didReceiveDeactivated(error: error)
    }
    
    func didReceiveRequireUpdate(type: ErrorApiResponse) {
        print("CoreInteractor - Did receive maintenance")
        output?.didReceiveRequireUpdate(type: type)
    }
}
