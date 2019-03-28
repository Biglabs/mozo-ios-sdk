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
}
