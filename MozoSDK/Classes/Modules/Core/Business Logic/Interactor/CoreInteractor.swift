//
//  CoreInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/18.
//

import Foundation
import PromiseKit
import JWTDecode

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
                // Fix issue: User id of profile can be NULL
                if userProfile.id != nil {
                    let user = UserDTO(id: userProfile.userId, profile: userProfile)
                    SessionStoreManager.saveCurrentUser(user: user)
                
                    let userModel = UserModel(id: userProfile.userId, mnemonic: nil, pin: nil, wallets: nil)
                    if self.userDataManager.addNewUser(userModel) == true {
                        seal.resolve(nil)
                    }
                } else {
                    seal.reject(ConnectionError.systemError)
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
        downloadInviteLinks()
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
    
    func downloadInviteLinks() {
        print("😎 Load invitation link for shopper.")
        _ = apiManager.getInviteLink(locale: Configuration.LOCALE, inviteAppType: .Shopper).done({ (inviteLink) in
            SessionStoreManager.inviteLink = inviteLink
        }).catch({ (error) in
            //TODO: Handle case unable to load invitation link
        })
        print("😎 Load invitation link for retailer.")
        _ = apiManager.getInviteLink(locale: Configuration.LOCALE, inviteAppType: .Retailer).done({ (inviteLink) in
            SessionStoreManager.inviteLinkRetailer = inviteLink
        }).catch({ (error) in
            //TODO: Handle case unable to load invitation link
        })
    }
    
    func checkWallet(module: Module) {
        "CoreInteractor - Check wallet".log()
        // Check wallet
        if let wallet = SessionStoreManager.loadCurrentUser()?.profile?.walletInfo, wallet.encryptSeedPhrase != nil, let id = SessionStoreManager.loadCurrentUser()?.id {
            let serverHaveBothOffChainAndOnChain = wallet.offchainAddress != nil && wallet.onchainAddress != nil
            
            // Check local wallet in DB
            _ = userDataManager.getWalletCountOfUser(id).done({ (value) in
                if value > 0 {
                    if value == 2, serverHaveBothOffChainAndOnChain {
                        if wallet.encryptedPin != nil {
                            // No need to do anything
                            self.output?.didDetectWalletInAutoMode(module: module)
                        } else {
                            self.output?.finishedCheckAuthentication(keepGoing: false, module: module)
                        }
                    } else {
                        // Manage wallet with encrypted seed phrase from server: Add missing local wallets
                        self.output?.continueWithWallet(module)
                    }
                } else {
                    // Restore wallet with encrypted seed phrase from server
                    if wallet.encryptedPin != nil {
                        // Restore wallet with encrypted seed phrase and pin from server
                        self.output?.continueWithWalletAuto(module)
                    } else {
                        self.output?.continueWithWallet(module)
                    }
                }
            }).catch({ (err) in
                // TODO: Handle Database Error here
                "Get wallet count of user [\(id)], error: \(err)".log()
            })
        } else {
            // Continue with Speed Selection
            output?.continueWithSpeedSelection(module)
//            self.output?.continueWithWallet(module)
        }
    }
    
    func checkAuthAndWallet(module: Module) {
        if AccessTokenManager.getAccessToken() != nil {
            // TODO: Must load user info here, not use local user
            if SessionStoreManager.loadCurrentUser() != nil {
                self.checkWallet(module: module)
                // TODO: Handle update local user profile data
                
                // Process invitation if any.
                self.processInvitation()
            } else {
                "😎 Load user info.".log()
                _ = getUserProfile().done({ () in
                    self.checkWallet(module: module)
                    // Process invitation if any.
                    self.processInvitation()
                }).catch({ (err) in
                    // No user profile, can not continue with any module
                    self.output?.failToLoadUserInfo((err as? ConnectionError) ?? .systemError, for: module)
                })
            }
        } else {
            output?.finishedCheckAuthentication(keepGoing: true, module: module)
        }
    }
    
    func saveDataFromToken(_ accessToken: String?) {
        if let accessToken = accessToken {
            let jwt = try! decode(jwt: accessToken)
            let pin_secret = jwt.claim(name: Configuration.JWT_TOKEN_CLAIM_PIN_SECRET).string
            AccessTokenManager.savePinSecret(pin_secret)
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
        let status = SafetyDataManager.shared.checkTokenExpiredStatus
        "repeatCheckForAuthentication \(status.rawValue)".log()
        if status != .CHECKING {
            "Continue with checking auth and wallet.".log()
            stopCheckTokenTimer()
            self.checkAuthAndWallet(module: checkTokenExpiredModule!)
        }
    }
    
    func checkForAuthentication(module: Module) {
        "CoreInteractor - Check for authentication. Waiting for check token expired from \(module.key).".log()
        stopCheckTokenTimer()
        checkTokenExpiredModule = module
        checkTokenExpiredTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.repeatCheckForAuthentication), userInfo: nil, repeats: true)
    }
    
    func stopCheckTokenTimer() {
        "CoreInteractor - STOP Check Token Timer".log()
        checkTokenExpiredTimer?.invalidate()
        checkTokenExpiredTimer = nil
        SafetyDataManager.shared.checkTokenExpiredStatus = .IDLE
    }
    
    func handleAferAuth(accessToken: String?) {
        AccessTokenManager.saveToken(accessToken)
        saveDataFromToken(accessToken)
        anonManager.linkCoinFromAnonymousToCurrentUser()
        handleUserProfileAfterAuth()
    }
    
    func handleUserProfileAfterAuth() {
        _ = getUserProfile().done({ () in
            self.downloadData()
            self.checkAuthAndWallet(module: .Wallet)
//            self.output?.finishedHandleAferAuth()
//            self.processInvitation()
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
    
    func notifyETHOffchainDetailDisplayItemForAllObservers() {
        NotificationCenter.default.post(name: .didReceiveETHOffchainDetailDisplayItem, object: nil)
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
    
    func processInvitation(numberOfTimes: Int = 3) {
        NSLog("CoreInteractor - Process invitation, number of times: \(numberOfTimes)")
        if AccessTokenManager.getAccessToken() != nil, let code = SessionStoreManager.getDynamicLink(), !code.isEmpty {
            NSLog("CoreInteractor - Process invitation with code: \(code)")
            SafetyDataManager.shared.checkProcessingInvitation = true
            _ = apiManager.updateCodeLinkInstallApp(codeString: code).done { (inviteInfo) in
                NSLog("Core interactor - Process invitation successfully, clear invitation code.")
                SessionStoreManager.setDynamicLink("")
                SafetyDataManager.shared.checkProcessingInvitation = false
            }.catch({ (error) in
                if let connError = error as? ConnectionError {
                    if connError.isApiError {
                        // Status: 200
                        NSLog("Core interactor - Process invitation failed, clear invitation code.")
                        SessionStoreManager.setDynamicLink("")
                        SafetyDataManager.shared.checkProcessingInvitation = false
                        return
                    }
                }
                NSLog("Core interactor - Process invitation failed, keep invitation code.")
                if numberOfTimes > 1 {
                    self.processInvitation(numberOfTimes: numberOfTimes - 1)
                } else {
                    SafetyDataManager.shared.checkProcessingInvitation = false
                }
            })
        } else {
            NSLog("CoreInteractor - Not enough conditions to process invitation")
            SafetyDataManager.shared.checkProcessingInvitation = false
        }
    }
    
    func notifyProfileChangesForAllObserver() {
        NotificationCenter.default.post(name: .didChangeProfile, object: nil)
    }
    
    func notifyMaintenance(isComplete: Bool) {
        if isComplete {
            NotificationCenter.default.post(name: .didMaintenanceComplete, object: nil)
        } else {
            NotificationCenter.default.post(name: .didMeetMaintenance, object: nil)
        }
    }
    
    func notifyTokenExpired() {
        NotificationCenter.default.post(name: .didExpiredToken, object: nil)
    }
}
