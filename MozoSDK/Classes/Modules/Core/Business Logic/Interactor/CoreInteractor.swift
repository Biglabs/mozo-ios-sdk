//
//  CoreInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/18.
//

import Foundation
import PromiseKit

enum CheckTokenExpiredStatus : String {
    case IDLE = "IDLE"
    case CHECKING = "CHECKING"
    case CHECKED = "CHECKED"
}

class CoreInteractor: NSObject {
    var output: CoreInteractorOutput?
    
    let anonManager: AnonManager
    let apiManager: ApiManager
    let userDataManager: UserDataManager
    
    var checkTokenExpiredTimer : Timer?
    var checkTokenExpiredModule : Module?
    
    init(anonManager: AnonManager, apiManager : ApiManager, userDataManager: UserDataManager) {
        self.anonManager = anonManager
        self.apiManager = apiManager
        self.userDataManager = userDataManager
        super.init()
        self.apiManager.delegate = self
    }
    
    // MARK: Dealloccation
    deinit {
        // TODO: Remove observation
        removeAllMozoObserver()
    }
    
    // MARK: Observation - REVOKE
    func removeAllMozoObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func getUserProfile() -> Promise<Void> {
        return Promise { seal in
            _ = apiManager.getUserProfile().done { (userProfile) in
                    let user = UserDTO(id: userProfile.userId, profile: userProfile)
                    SessionStoreManager.saveCurrentUser(user: user)
                
                    let userModel = UserModel(id: userProfile.userId, mnemonic: nil, pin: nil, wallets: nil)
                    if self.userDataManager.addNewUser(userModel) == true {
                        seal.resolve(nil)
                    }
                }.catch({ (err) in
                    seal.reject(err)
                })
        }
    }
    
    // MARK: Prepare data
    func downloadData() {
        downloadAddressBookAndStoreAtLocal()
        downloadStoreBookAndStoreAtLocal()
        _ = loadBalanceInfo()
        _ = loadEthAndOnchainBalanceInfo()
        downloadExchangeRateInfoAndStoreAtLocal()
        downloadCountryListAndStoreAtLocal()
        downloadGasPriceAndStoreAtLocal()
    }
    
    func downloadGasPriceAndStoreAtLocal() {
        print("😎 Load address book list.")
        _ = apiManager.getGasPrices().done({ (gasPrice) in
            SessionStoreManager.gasPrice = gasPrice
        }).catch({ (error) in
            
        })
    }
    
    func downloadAddressBookAndStoreAtLocal() {
        print("😎 Load address book list.")
        _ = apiManager.getListAddressBook().done({ (list) in
            SafetyDataManager.shared.addressBookList = list
        }).catch({ (error) in
            //TODO: Handle case unable to load address book list
        })
    }
    
    func downloadExchangeRateInfoAndStoreAtLocal() {
        print("😎 Load exchange rate data.")
        _ = apiManager.getEthAndOnchainExchangeRateInfo().done({ (data) in
            SessionStoreManager.exchangeRateInfo = data.token
            SessionStoreManager.ethExchangeRateInfo = data.eth
            self.notifyExchangeRateInfoForAllObservers()
        }).catch({ (error) in
            //TODO: Handle case unable to load exchange rate info
        })
    }
    
    func downloadCountryListAndStoreAtLocal() {
        print("😎 Load country code list data.")
        _ = apiManager.getListCountryCode().done({ (data) in
            SessionStoreManager.countryList = data
        }).catch({ (error) in
            //TODO: Handle case unable to load country list
        })
    }
    
    func downloadStoreBookAndStoreAtLocal() {
        print("😎 Load store book list.")
        _ = apiManager.getListStoreBook().done({ (list) in
            SafetyDataManager.shared.storeBookList = list
        }).catch({ (error) in
            //TODO: Handle case unable to load store book list
        })
    }
    
    func checkWallet(module: Module) {
        // Check wallet
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo, wallet.encryptSeedPhrase != nil, let id = SessionStoreManager.loadCurrentUser()?.id {
            let serverHaveBothOffChainAndOnChain = wallet.offchainAddress != nil && wallet.onchainAddress != nil
            
            // Check local wallet in DB
            _ = userDataManager.getWalletCountOfUser(id).done({ (value) in
                if value > 0 {
                    if value == 2, serverHaveBothOffChainAndOnChain {
                        self.output?.finishedCheckAuthentication(keepGoing: false, module: module)
                    } else {
                        self.output?.continueWithWallet(module)
                    }
                } else {
                    // Re-authenicate, manage wallet
                    self.output?.continueWithWallet(module)
                }
            }).catch({ (err) in
                // TODO: Handle Database Error here
                print("Get wallet count of user [\(id)], error: \(err)")
            })
        } else {
            // Re-authenicate, manage wallet
            output?.continueWithWallet(module)
        }
    }
    
    func checkAuthAndWallet(module: Module) {
        if AccessTokenManager.getAccessToken() != nil {
            if SessionStoreManager.loadCurrentUser() != nil {
                self.checkWallet(module: module)
                // TODO: Handle update local user profile data
            } else {
                print("😎 Load user info.")
                _ = getUserProfile().done({ () in
                    self.checkWallet(module: module)
                }).catch({ (err) in
                    // No user profile, can not continue with any module
                    self.output?.failToLoadUserInfo((err as? ConnectionError) ?? .systemError, for: module)
                })
            }
        } else {
            output?.finishedCheckAuthentication(keepGoing: true, module: module)
        }
    }
}

extension CoreInteractor: CoreInteractorInput {
    func downloadAndStoreConvenienceData() {
        print("Download convenience data and store at local.")
        if AccessTokenManager.getAccessToken() != nil, SafetyDataManager.shared.checkTokenExpiredStatus != .CHECKING {
            // Check User info here
            _ = getUserProfile().done {
                self.downloadData()
            }.catch({ (error) in
                self.output?.failToLoadUserInfo(error as! ConnectionError, for: nil)
            })
        }
    }
    
    @objc func repeatCheckForAuthentication() {
        if SafetyDataManager.shared.checkTokenExpiredStatus != .CHECKING {
            print("Continue with checking auth and wallet.")
            checkTokenExpiredTimer?.invalidate()
            self.checkAuthAndWallet(module: checkTokenExpiredModule!)
        }
    }
    
    func checkForAuthentication(module: Module) {
        // FIX ISSUE: Request for authentication must wait for checking token expired DONE.
        print("CoreInteractor - Check for authentication. Waiting for check token expired.")
        checkTokenExpiredModule = module
        checkTokenExpiredTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.repeatCheckForAuthentication), userInfo: nil, repeats: true)
    }
    
    func handleAferAuth(accessToken: String?) {
        AccessTokenManager.saveToken(accessToken)
        anonManager.linkCoinFromAnonymousToCurrentUser()
        _ = getUserProfile().done({ () in
            self.downloadData()
            self.output?.finishedHandleAferAuth()
        }).catch({ (err) in
            // Handle case unable to load user profile
            self.output?.failToLoadUserInfo(err as! ConnectionError, for: nil)
        })
    }
    
    func notifyAuthSuccessForAllObservers() {
        NotificationCenter.default.post(name: .didAuthenticationSuccessWithMozo, object: nil)
    }
    
    func notifyLogoutForAllObservers() {
        NotificationCenter.default.post(name: .didLogoutFromMozo, object: nil)
    }
    
    func notifyDidCloseAllMozoUIForAllObservers() {
        NotificationCenter.default.post(name: .didCloseAllMozoUI, object: nil)
    }
    
    func notifyBalanceChangesForAllObservers(balanceNoti: BalanceNotification) {
        if let amount = balanceNoti.amount?.convertOutputValue(decimal: balanceNoti.decimal!), amount > 0.00 {
            loadBalanceInfo().done { (displayItem) in
                NotificationCenter.default.post(name: .didChangeBalance, object: nil, userInfo: ["balance" : displayItem.balance])
            }.catch { (error) in
                    
            }
        }
    }
    
    func notifyConvertSuccessOnchainToOffchain(balanceNoti: BalanceNotification) {
        NotificationCenter.default.post(name: .didConvertSuccessOnchainToOffchain, object: nil, userInfo: nil)
    }
    
    func notifyDetailDisplayItemForAllObservers() {
        NotificationCenter.default.post(name: .didReceiveDetailDisplayItem, object: nil)
    }
    
    func notifyETHDetailDisplayItemForAllObservers() {
        NotificationCenter.default.post(name: .didReceiveETHDetailDisplayItem, object: nil)
    }
    
    func notifyOnchainDetailDisplayItemForAllObservers() {
        NotificationCenter.default.post(name: .didReceiveOnchainDetailDisplayItem, object: nil)
    }
    
    func notifyExchangeRateInfoForAllObservers() {
        NotificationCenter.default.post(name: .didReceiveExchangeInfo, object: nil)
    }
    
    func notifyAddressBookChangesForAllObservers() {
        NotificationCenter.default.post(name: .didChangeAddressBook, object: nil)
    }
    
    func notifyStoreBookChangesForAllObservers() {
        NotificationCenter.default.post(name: .didChangeStoreBook, object: nil)
    }
    
    func notifyLoadTokenInfoFailedForAllObservers() {
        NotificationCenter.default.post(name: .didLoadTokenInfoFailed, object: nil)
    }
    
    func notifyLoadETHOnchainTokenFailedForAllObservers() {
        NotificationCenter.default.post(name: .didLoadETHOnchainTokenInfoFailed, object: nil)
    }
}

extension CoreInteractor: ApiManagerDelegate {
    func didLoadTokenInfoSuccess(_ tokenInfo: TokenInfoDTO){
        print("Did Load Token Info Success")
        let item = DetailInfoDisplayItem(tokenInfo: tokenInfo)
        if SafetyDataManager.shared.offchainDetailDisplayData == nil || SafetyDataManager.shared.offchainDetailDisplayData != item {
            SafetyDataManager.shared.offchainDetailDisplayData = item
            notifyDetailDisplayItemForAllObservers()
        }
    }
    
    func didLoadTokenInfoFailed(){
        print("Did Load Token Info Failed")
        notifyLoadTokenInfoFailedForAllObservers()
    }
    
    func didLoadETHOnchainTokenSuccess(_ onchainInfo: OnchainInfoDTO) {
        print("Did load ETH and Onchain Token success")
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
    
    func didLoadETHOnchainTokenFailed() {
        print("Did load ETH and Onchain Token Failed")
        notifyLoadETHOnchainTokenFailedForAllObservers()
    }
}
