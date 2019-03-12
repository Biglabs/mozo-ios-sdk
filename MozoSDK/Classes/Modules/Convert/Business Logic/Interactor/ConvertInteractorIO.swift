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
    func sendConfirmConvertTx(_ tx: ConvertTransactionDTO, onchainInfo: OnchainInfoDTO)
    
    func performTransfer(pin: String)
    func requestToRetryTransfer()
}
protocol ConvertInteractorOutput {
    func didReceiveEthAndOnchainInfo(_ onchainInfo: OnchainInfoDTO)
    func didReceiveGasPrice(_ gasPrice: GasPriceDTO)
    func didValidateConvertTx(_ error: String)
    func didReceiveErrorWhileLoadingOnchainInfo(_ error: ConnectionError)
    func didReceiveErrorWhileLoadingGasPrice(_ error: ConnectionError)
    
    func continueWithTransaction(_ transaction: ConvertTransactionDTO, onchainInfo: OnchainInfoDTO, gasPrice: NSNumber, gasLimit: NSNumber)
    
    func errorOccurred()
    
    func requestPinToSignTransaction()
    
    func performTransferWithError(_ error: ConnectionError)
    
    func didSendConvertTransactionSuccess(_ transaction: IntermediaryTransactionDTO, onchainInfo: OnchainInfoDTO)
}
