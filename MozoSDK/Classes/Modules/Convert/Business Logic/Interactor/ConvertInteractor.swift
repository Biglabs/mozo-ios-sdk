//
//  ConvertInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConvertInteractor: NSObject {
    var output: ConvertInteractorOutput?
    let apiManager : ApiManager
    var signManager : TransactionSignManager
    
    var originalTransaction: ConvertTransactionDTO?
    var transactionData : IntermediaryTransactionDTO?
    var tokenInfo: TokenInfoDTO?
    var pinToRetry: String?
    
    init(apiManager: ApiManager, signManager: TransactionSignManager) {
        self.apiManager = apiManager
        self.signManager = signManager
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
    }
    
    @objc func onUserDidCloseAllMozoUI(_ notification: Notification) {
        print("ConvertInteractor - User close Mozo UI, clear pin cache")
        pinToRetry = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
    }
    
    func calculateEthTxFee(gasLimit: NSNumber, gasPrice: NSNumber) -> NSNumber {
        // TxFee = GasLimit * GasPrice * 10^9 (WEI)
        let gasLimitDecimal = NSDecimalNumber(decimal: gasLimit.decimalValue)
        let gasPriceDecimal = NSDecimalNumber(decimal: gasPrice.decimalValue)
        return gasLimitDecimal.multiplying(by: gasPriceDecimal).multiplying(byPowerOf10: 9)
    }
    
    func convertGasPriceToWEI(_ gasPrice: NSNumber) -> NSNumber {
        let gasPriceDecimal = NSDecimalNumber(decimal: gasPrice.decimalValue)
        return gasPriceDecimal.multiplying(byPowerOf10: 9)
    }
    
    func requestForPin() {
        if let encryptedPin = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo?.encryptedPin,
            let pinSecret = AccessTokenManager.getPinSecret() {
            let decryptPin = encryptedPin.decrypt(key: pinSecret)
            pinToRetry = decryptPin
            self.performTransfer(pin: decryptPin)
        } else {
            self.output?.requestPinToSignTransaction()
        }
    }
}
extension ConvertInteractor: ConvertInteractorInput {
    func loadEthAndOffchainInfo() {
        if let user = SessionStoreManager.loadCurrentUser(), let profile = user.profile, let wallet = profile.walletInfo, let address = wallet.offchainAddress {
            _ = apiManager.getOffchainTokenInfo(address).done { (info) in
                self.output?.didReceiveEthAndOffchainInfo(info)
            }.catch({ (error) in
                self.output?.didReceiveErrorWhileLoadingEthAndOffchainInfo(error as? ConnectionError ?? .systemError)
            })
        }
    }
    
    func loadEthAndTranferFee() {
        if let user = SessionStoreManager.loadCurrentUser(), let profile = user.profile, let wallet = profile.walletInfo, let address = wallet.offchainAddress {
            _ = apiManager.getETHAndTransferFee(address).done({ (info) in
                self.output?.didReceiveEthAndTransferFee(info)
            }).catch({ (error) in
                self.output?.didReceiveErrorWhileLoadingEthAndTransferFee(error as? ConnectionError ?? .systemError)
            })
        }
    }
    
    func loadEthAndOnchainInfo() {
        if let user = SessionStoreManager.loadCurrentUser(), let profile = user.profile, let wallet = profile.walletInfo, let onchainAddress = wallet.onchainAddress {
            _ = apiManager.getEthAndOnchainTokenInfoFromAddress(onchainAddress).done({ (onchainInfo) in
                self.output?.didReceiveEthAndOnchainInfo(onchainInfo)
            }).catch({ (error) in
                self.output?.didReceiveErrorWhileLoadingOnchainInfo(error as? ConnectionError ?? .systemError)
            })
        }
    }
    
    func loadGasPrice() {
        _ = apiManager.getGasPrices().done({ (gasPrice) in
            SessionStoreManager.gasPrice = gasPrice
            self.output?.didReceiveGasPrice(gasPrice)
        }).catch({ (error) in
            self.output?.didReceiveErrorWhileLoadingGasPrice(error as? ConnectionError ?? .systemError)
        })
    }
    
    func validateTxConvert(onchainInfo: OnchainInfoDTO, amount: String, gasPrice: NSNumber, gasLimit: NSNumber) {
        if let ethInfo = onchainInfo.balanceOfETH, let ethBalance = ethInfo.balance, let tokenInfo = onchainInfo.balanceOfToken, let tokenBalance = tokenInfo.balance {
            let value = amount.toDoubleValue()
            var txValue = NSNumber(value: 0)
            txValue = value > 0.0 ? value.convertTokenValue(decimal: tokenInfo.decimals ?? 0) : 0
            if txValue.compare(tokenBalance) == .orderedDescending {
                output?.didValidateConvertTx("Onchain balance is not enough.")
                return
            }
            let txFee = calculateEthTxFee(gasLimit: gasLimit, gasPrice: gasPrice)
            if txFee.compare(ethBalance) == .orderedDescending {
                output?.didValidateConvertTx("ETH balance is not enough.")
                return
            }
            if let fromAddress = ethInfo.address, let user = SessionStoreManager.loadCurrentUser(), let profile = user.profile, let wallet = profile.walletInfo, let offchainAddress = wallet.offchainAddress {
                let weiGasPrice = convertGasPriceToWEI(gasPrice)
                if let convertTransactionDTO = ConvertTransactionDTO(fromAddress: fromAddress, gasLimit: gasLimit, gasPrice: weiGasPrice, toAddress: offchainAddress, value: txValue) {
                    self.originalTransaction = convertTransactionDTO
                    self.tokenInfo = tokenInfo
                    output?.continueWithTransaction(convertTransactionDTO, tokenInfoFromConverting: tokenInfo, gasPrice: gasPrice, gasLimit: gasLimit)
                    return
                }
            }
        }
        output?.errorOccurred()
    }
    
    func validateTxConvert(ethInfo: EthAndTransferFeeDTO, offchainInfo: OffchainInfoDTO, gasPrice: NSNumber, gasLimit: NSNumber) {
        if let ethBalance = ethInfo.balanceOfETH?.balance, let tokenInfo = offchainInfo.balanceOfTokenOffchain, let amount = offchainInfo.balanceOfTokenOnchain?.balance {
            let txFee = calculateEthTxFee(gasLimit: gasLimit, gasPrice: gasPrice)
            if txFee.compare(ethBalance) == .orderedDescending {
                output?.didValidateConvertTx("ETH balance is not enough.")
                return
            }
            if let fromAddress = ethInfo.balanceOfETH?.address, let user = SessionStoreManager.loadCurrentUser(), let profile = user.profile, let wallet = profile.walletInfo, let offchainAddress = wallet.offchainAddress {
                let weiGasPrice = convertGasPriceToWEI(gasPrice)
                if let convertTransactionDTO = ConvertTransactionDTO(fromAddress: fromAddress, gasLimit: gasLimit, gasPrice: weiGasPrice, toAddress: offchainAddress, value: amount) {
                    self.originalTransaction = convertTransactionDTO
                    self.tokenInfo = tokenInfo
                    output?.continueWithTransaction(convertTransactionDTO, tokenInfoFromConverting: tokenInfo, gasPrice: gasPrice, gasLimit: gasLimit)
                    return
                }
            }
        }
        output?.errorOccurred()
    }
    
    func sendConfirmConvertTx(_ tx: ConvertTransactionDTO) {
        _ = apiManager.sendPrepareConvertTransaction(tx).done { (interTx) in
                self.originalTransaction = tx
                self.transactionData = interTx
                if let pin = self.pinToRetry {
                    self.performTransfer(pin: pin)
                } else {
                    self.requestForPin()
                }
            }.catch({ (error) in
                print("Send create transaction failed, show popup to retry.")
                // Remember original transaction for retrying.
                self.originalTransaction = tx
                self.output?.performTransferWithError(error as? ConnectionError ?? .systemError)
            })
    }
    
    func performTransfer(pin: String) {
        signManager.signTransaction(transactionData!, pin: pin)
            .done { (signedInterTx) in
                self.apiManager.sendSignedConvertTransaction(signedInterTx).done({ (receivedTx) in
                    print("Send successfully with hash: \(receivedTx.tx?.hash ?? "NULL")")
                    // Clear retry PIN
                    self.pinToRetry = nil
                    // Fix issue: Should keep previous value of transaction
                    if let outputValue = self.originalTransaction?.value {
                        receivedTx.tx?.outputs![0].value = outputValue
                    }
                    // Clear original transaction
                    self.originalTransaction = nil
                    print("Original output value: \(receivedTx.tx?.outputs![0].value ?? 0)")
                    // TODO: Avoid depending on received transaction data
                    self.output?.didSendConvertTransactionSuccess(receivedTx)
                }).catch({ (err) in
                    print("Send signed transaction failed, show popup to retry.")
                    self.pinToRetry = pin
                    self.output?.performTransferWithError(err as? ConnectionError ?? .systemError)
                })
            }.catch({ (err) in
                self.output?.errorOccurred()
            })
    }
    
    func requestToRetryTransfer() {
        if let transaction = originalTransaction {
            sendConfirmConvertTx(transaction)
        }
    }
}
