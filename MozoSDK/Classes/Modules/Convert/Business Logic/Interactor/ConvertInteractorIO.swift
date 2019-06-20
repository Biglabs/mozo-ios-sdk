//
//  ConvertInteractorIO.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
protocol ConvertInteractorInput {
    func loadEthAndOnchainInfo()
    func loadGasPrice()
    func validateTxConvert(onchainInfo: OnchainInfoDTO, amount: String, gasPrice: NSNumber, gasLimit: NSNumber)
    func validateTxConvert(ethInfo: EthAndTransferFeeDTO, offchainInfo: OffchainInfoDTO, gasPrice: NSNumber, gasLimit: NSNumber)
    func sendConfirmConvertTx(_ tx: ConvertTransactionDTO)
    
    func performTransfer(pin: String)
    func requestToRetryTransfer()
    
    func loadEthAndTranferFee()
    func loadEthAndOffchainInfo()
}
protocol ConvertInteractorOutput {
    func didReceiveEthAndTransferFee(_ ethInfo: EthAndTransferFeeDTO)
    func didReceiveErrorWhileLoadingEthAndTransferFee(_ error: ConnectionError)
    
    func didReceiveEthAndOffchainInfo(_ offchainInfo: OffchainInfoDTO)
    func didReceiveErrorWhileLoadingEthAndOffchainInfo(_ error: ConnectionError)
    
    func didReceiveEthAndOnchainInfo(_ onchainInfo: OnchainInfoDTO)
    func didReceiveGasPrice(_ gasPrice: GasPriceDTO)
    func didValidateConvertTx(_ error: String)
    func didReceiveErrorWhileLoadingOnchainInfo(_ error: ConnectionError)
    func didReceiveErrorWhileLoadingGasPrice(_ error: ConnectionError)
    
    func continueWithTransaction(_ transaction: ConvertTransactionDTO, tokenInfoFromConverting: TokenInfoDTO, gasPrice: NSNumber, gasLimit: NSNumber)
    
    func errorOccurred()
    
    func requestPinToSignTransaction()
    
    func performTransferWithError(_ error: ConnectionError)
    
    func didSendConvertTransactionSuccess(_ transaction: IntermediaryTransactionDTO)
    
    func requestAutoPINInterface()
}
