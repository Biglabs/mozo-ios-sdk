//
//  ConvertViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
protocol ConvertViewInterface {
    func didReceiveOnchainInfo(_ onchainInfo: OnchainInfoDTO)
    func didReceiceGasPrice(_ gasPrice: GasPriceDTO)
    
    func displayError(_ error: String)
    
    func updateEthInfo(_ ethInfo: EthAndTransferFeeDTO)
    func updateLoadingStateForEthAndTransferFee()
    
    func updateEthAndOffchainInfo(_ offchainInfo: OffchainInfoDTO)
    func updateLoadingStateForEthAndOffchainInfo()
}
