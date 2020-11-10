//
//  ApiManagerDelegate.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/25/18.
//

import Foundation

protocol ApiManagerDelegate {
    func didLoadTokenInfoSuccess(_ tokenInfo: TokenInfoDTO)
    func didLoadTokenInfoFailed()
    func didLoadETHOnchainTokenSuccess(_ onchainInfo: OnchainInfoDTO)
    func didLoadETHOnchainTokenFailed()
    
    func didReceiveInvalidToken()
    func didReceiveAuthorizationRequired()
    
    func didLoadOffchainInfoSuccess(_ offchainInfo: OffchainInfoDTO)
    func didLoadOffchainInfoFailed()
    func didLoadETHSuccess(_ tokenInfo: TokenInfoDTO)
    func didLoadETHFailed()
    
    func didReceiveMaintenance()
    
    func didReceiveDeactivated(error: ErrorApiResponse)
    func didReceiveRequireUpdate(type: ErrorApiResponse)
}
