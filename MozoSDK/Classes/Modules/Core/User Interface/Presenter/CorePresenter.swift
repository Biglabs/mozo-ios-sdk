//
//  CorePresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import UserNotifications
import Reachability

class CorePresenter : NSObject {
    var coreWireframe : CoreWireframe?
    var coreInteractor : CoreInteractorInput?
    var coreInteractorService : CoreInteractorService?
    var rdnInteractor : RDNInteractorInput?
    weak var authDelegate: AuthenticationDelegate?
    var callBackModule: Module?
    var reachability : Reachability?
    
    var waitingViewInterface: WaitingViewInterface?
    
    var requestingABModule: Module?
    
    var isAuthenticating = false

    override init() {
        super.init()
        initSilentServices()
        addAppObservations()
        initUserNotificationCenter()
        setupReachability()
    }
    
    func readyForGoingLive() {
        coreInteractor?.downloadAndStoreConvenienceData()
        startSlientServices()
    }
    
    // MARK: Reachability
    func setupReachability() {
        let hostName = Configuration.BASE_HOST
        print("Set up Reachability with host name: \(hostName)")
        reachability = Reachability(hostname: hostName)
        reachability?.whenReachable = { reachability in
            print("Reachability when reachable: \(reachability.description) - \(reachability.connection)")
            self.readyForGoingLive()
        }
        reachability?.whenUnreachable = { reachability in
            print("Reachability when unreachable: \(reachability.description) - \(reachability.connection)")
            self.stopSilentServices()
        }
        print("Reachability --- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            
        }
    }
    
    func stopNotifier() {
        print("Reachability --- stop notifier")
        reachability?.stopNotifier()
        reachability = nil
    }
    
    func handleAccessRemoved() {
        print("CorePresenter - Handle processed after account's access removed")
        SessionStoreManager.isAccessDenied = true
    }
    
    func handleInvalidTokenApiResponse() {
        print("CorePresenter - Handle invalid token from api response")
        // TODO: Must check current view controller is kind of UIAlertViewController
        if !isAuthenticating {
            isAuthenticating = true
            coreWireframe?.authWireframe?.clearAllSessionData()
            // MozoX Screens could be contained here.
            if (coreWireframe?.rootWireframe?.mozoNavigationController.viewControllers.count ?? 0) > 0 {
                print("CorePresenter - Handle invalid token from api response when MozoX Screens is displaying.")
                coreWireframe?.requestForCloseAllMozoUIs(completion: {
                    self.authDelegate?.mozoUIDidCloseAll()
                    self.coreInteractor?.notifyDidCloseAllMozoUIForAllObservers()
                    self.coreWireframe?.requestForAuthentication()
                })
                
                removePINDelegate()
            } else {
                print("CorePresenter - Handle invalid token from api response when No MozoX Screens is displaying.")
                coreWireframe?.requestForAuthentication()
            }
            //        coreWireframe?.authWireframe?.presentLogoutInterface()
        } else {
            // Ignore
            print("CorePresenter - Ignore handle invalid token from api response")
        }
    }
    
    deinit {
        stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Silent services methods
private extension CorePresenter {
    private func initUserNotificationCenter() {
        registerForRichNotifications()
    }
    
    private func initSilentServices() {
        
    }
    
    private func addAppObservations() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMaintenanceHealthy), name: .didMaintenanceComplete, object: nil)
    }
    
    private func startSlientServices() {
        // Check walletInfo from UserProfile to start silent services
        if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, profile.walletInfo?.offchainAddress != nil, SafetyDataManager.shared.checkTokenExpiredStatus != .CHECKING,
            AccessTokenManager.getAccessToken() != nil {
            print("CorePresenter - Start silent services, socket service.")
            rdnInteractor?.startService()
            print("CorePresenter - Start silent services, refresh token service.")
            coreWireframe?.authWireframe?.startRefreshTokenTimer()
        }
    }
    
    private func stopSilentServices(shouldReconnect: Bool = true) {
        print("CorePresenter - Stop silent services.")
        // Stop silent services
        rdnInteractor?.stopService(shouldReconnect: shouldReconnect)
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        print("App did enter background.")
        stopSilentServices()
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        print("App will enter foreground.")
        // Check walletInfo from UserProfile to start silent services
        startSlientServices()
    }
    
    @objc func didReceiveMaintenanceHealthy(_ notification: Notification) {
        print("CorePresenter - Did receive maintenance healthy")
        if let topViewController = DisplayUtils.getTopViewController(), topViewController is WaitingViewController {
            retryGetUserProfile()
        }
    }
}
extension CorePresenter : CoreModuleInterface {
    func requestForAuthentication(module: Module) {
        coreInteractor?.checkForAuthentication(module: module)
    }
    
    func requestForLogout() {
        
    }
    
    func requestForCloseAllMozoUIs() {
        coreWireframe?.requestForCloseAllMozoUIs(completion: {
            self.authDelegate?.mozoUIDidCloseAll()
            self.coreInteractor?.notifyDidCloseAllMozoUIForAllObservers()
        })
    
        removePINDelegate()
    }
    
    func requestCloseToLastMozoUIs() {
        coreWireframe?.requestCloseToLastMozoUIs()
    }
    
    func presentModuleInterface(_ module: Module) {
        // Should continue with any module
        switch module {
        case .Transaction:
            coreWireframe?.prepareForTransferInterface()
        case .TxHistory:
            coreWireframe?.prepareForTxHistoryInterface()
        case .Payment:
            coreWireframe?.prepareForPaymentRequestInterface()
        case .AddressBook:
            coreWireframe?.presentAddressBookInterface(false)
        case .Convert:
            coreWireframe?.presentConvertInterface()
        default: coreWireframe?.prepareForWalletInterface()
        }
    }
}
extension CorePresenter : CoreModuleWaitingInterface {
    func retryGetUserProfile() {
        if let module = callBackModule {
            requestForAuthentication(module: module)
        } else {
            coreInteractor?.handleUserProfileAfterAuth()
        }
    }
    
    func retryAuth() {
        coreWireframe?.authWireframe?.presentInitialAuthInterface()
    }
}
extension CorePresenter : AuthModuleDelegate {
    func didCheckAuthorizationSuccess() {
        print("On Check Authorization Did Success: Download convenience data")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        readyForGoingLive()
    }
    
    func didCheckAuthorizationFailed() {
        print("On Check Authorization Did Failed - No connection")
    }
    
    func didRemoveTokenAndLogout() {
        print("On Check Authorization Did remove token and logout")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidFinishAuthentication(accessToken: String?) {
        isAuthenticating = false
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }

    func authModuleDidFailedToMakeAuthentication(error: ConnectionError) {
        waitingViewInterface?.displayTryAgain(error, forAction: .BuildAuth)
    }
    
    func authModuleDidCancelAuthentication() {
        isAuthenticating = false
        requestForCloseAllMozoUIs()
    }
    
    func authModuleDidFinishLogout() {
        // Send delegate back to the app
        authDelegate?.mozoLogoutDidFinish()
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        requestForCloseAllMozoUIs()
        stopSilentServices(shouldReconnect: false)
    }
    
    func authModuleDidCancelLogout() {
        
    }
}

extension CorePresenter: WalletModuleDelegate {
    func walletModuleDidFinish() {
        print("CorePresenter - Wallet Module Did Finished, callbackModule: \(callBackModule?.value ?? "NO MODULE")")
        // FIX ISSUE: Wallet interface re-display after inputting PIN.
        if callBackModule == .Wallet {
            callBackModule = nil
        }
        if callBackModule != nil {
            // Present call back module interface
            requestCloseToLastMozoUIs()
            presentModuleInterface(callBackModule!)
            callBackModule = nil
        } else {
            // Close all existing Mozo's UIs
            coreWireframe?.requestForCloseAllMozoUIs(completion: {
                // Send delegate back to the app
                self.authDelegate?.mozoAuthenticationDidFinish()
            })
        }
        readyForGoingLive()
    }
}

extension CorePresenter : CoreInteractorOutput {
    func continueWithWallet(_ callbackModule: Module) {
        print("CorePresenter - Continue with Wallet, callbackModule: \(callbackModule.value)")
        // Should display call back module (if any)
        self.callBackModule = callbackModule
        presentModuleInterface(.Wallet)
    }
    
    func finishedCheckAuthentication(keepGoing: Bool, module: Module) {
        if keepGoing {
            // Should display call back module (if any)
            if module != .Wallet {
                self.callBackModule = module
            }
            coreWireframe?.authenticate()
        } else {
            presentModuleInterface(module)
        }
    }
    
    func finishedHandleAferAuth() {
        coreWireframe?.prepareForWalletInterface()
    }
    
    func failToLoadUserInfo(_ error: ConnectionError, for requestingModule: Module?) {
        NSLog("CorePresenter - Failed to load user info")
        if let requestingModule = requestingModule {
            callBackModule = requestingModule
        }
        // Check connection error
        if error == .authenticationRequired {
            // TODO: Display different error for invalid token
            waitingViewInterface?.displayTryAgain(ConnectionError.apiError_INVALID_USER_TOKEN, forAction: nil)
            return
        }
        waitingViewInterface?.displayTryAgain(error, forAction: .LoadUserProfile)
    }
    
    func didReceiveInvalidToken() {
        print("CorePresenter - Did receive invalid user token")
        handleInvalidTokenApiResponse()
    }
    
    func didReceiveAuthorizationRequired() {
        print("CorePresenter - Did receive authorization required")
        if let viewController = DisplayUtils.getTopViewController(), !viewController.isKind(of: WaitingViewController.self) {
            handleInvalidTokenApiResponse()
        } else {
            // Ignore
        }
    }
    
    func didReceiveMaintenance() {
        coreInteractor?.notifyMaintenance(isComplete: false)
    }
}

extension CorePresenter: TransactionModuleDelegate {
    func requestPINInterfaceForTransaction() {
        coreWireframe?.presentPINInterfaceForTransaction()
    }
    
    func removePINDelegate() {
        coreWireframe?.walletWireframe?.walletPresenter?.pinModuleDelegate = nil
    }
    
    func didSendTxSuccess(_ tx: IntermediaryTransactionDTO, tokenInfo: TokenInfoDTO) {
        // Build transaction detail item
        let data = TxDetailDisplayData(transaction: tx, tokenInfo: tokenInfo)
        let detailItem = data.collectDisplayItem()
        // Display transaction completion interface
        coreWireframe?.presentTransactionCompleteInterface(detailItem)
    }
    
    func requestAddressBookInterfaceForTransaction() {
        requestingABModule = Module.Transaction
        coreWireframe?.presentAddressBookInterface()
    }
}

extension CorePresenter: TxCompletionModuleDelegate {
    func requestAddToAddressBook(_ address: String) {
        // Verify address is existing in address book list or not
        let list = SafetyDataManager.shared.addressBookList
        let contain = AddressBookDTO.arrayContainsItem(address, array: list)
        if contain {
            // TODO: Show message address is existing in address book list
        } else {
            coreWireframe?.presentAddressBookDetailInterface(address: address)
        }
    }
    
    func requestShowDetail(_ detail: TxDetailDisplayItem) {
        coreWireframe?.presentTransactionDetailInterface(detail)
    }
}

extension CorePresenter: TxDetailModuleDelegate {
    func detailModuleRequestAddToAddressBook(_ address: String) {
        requestAddToAddressBook(address)
    }
}

extension CorePresenter: AddressBookModuleDelegate {
    func addressBookModuleDidChooseItemOnUI(addressBook: AddressBookDisplayItem, isDisplayForSelect: Bool) {
        if isDisplayForSelect {
            if let module = requestingABModule {
                switch module {
                case .Transaction:
                    coreWireframe?.updateAddressBookInterfaceForTransaction(displayItem: addressBook)
                case .Payment:
                    coreWireframe?.updateAddressBookInterfaceForPaymentRequest(displayItem: addressBook)
                default: break
                }
                requestingABModule = nil
            }
            coreWireframe?.dismissAddressBookInterface()
        } else {
            
        }
    }
}

extension CorePresenter: ABDetailModuleDelegate {
    func detailModuleDidCancelSaveAction() {
        
    }
    
    func detailModuleDidSaveAddressBook() {
        coreWireframe?.dismissAddressBookDetailInterface()
    }
}

extension CorePresenter: TxHistoryModuleDelegate {
    func txHistoryModuleDidChooseItemOnUI(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        let data = TxDetailDisplayData(txHistory: txHistory, tokenInfo: tokenInfo)
        let detailItem = data.collectDisplayItem()
        // Display transaction completion interface
        coreWireframe?.presentTransactionDetailInterface(detailItem)
    }
}

extension CorePresenter : RDNInteractorOutput {
    func didCustomerCame(ccNoti: CustomerComeNotification, rawMessage: String) {
        performNotifications(noti: ccNoti, rawMessage: rawMessage)
    }
    
    func balanceDidChange(balanceNoti: BalanceNotification, rawMessage: String) {
        coreInteractor?.notifyBalanceChangesForAllObservers(balanceNoti: balanceNoti)
        performNotifications(noti: balanceNoti, rawMessage: rawMessage)
    }
    
    func didConvertOnchainToOffchainSuccess(balanceNoti: BalanceNotification, rawMessage: String) {
        coreInteractor?.notifyConvertSuccessOnchainToOffchain(balanceNoti: balanceNoti)
    }
    
    func addressBookDidChange(addressBookList: [AddressBookDTO], rawMessage: String) {
        SafetyDataManager.shared.addressBookList = addressBookList
        coreInteractor?.notifyAddressBookChangesForAllObservers()
    }
    
    func storeBookDidChange(storeBook: StoreBookDTO, rawMessage: String) {
        if let address = storeBook.offchainAddress {
            if StoreBookDTO.arrayContainsItem(address, array: SafetyDataManager.shared.storeBookList) == false {
                SafetyDataManager.shared.storeBookList.append(storeBook)
                coreInteractor?.notifyStoreBookChangesForAllObservers()
            }
        }
    }
    
    func didAirdropped(airdropNoti: BalanceNotification, rawMessage: String) {
        performNotifications(noti: airdropNoti, rawMessage: rawMessage)
    }
    
    func didInvalidToken(tokenNoti: InvalidTokenNotification) {
        print("CorePresenter - Did receive invalid token from Notification Module")
        handleInvalidTokenApiResponse()
    }
    
    func didInvitedSuccess(inviteNoti: InviteNotification, rawMessage: String) {
        performNotifications(noti: inviteNoti, rawMessage: rawMessage)
    }
    
    func profileDidChange() {
        coreInteractor?.notifyProfileChangesForAllObserver()
    }
    
    func didReceivedAirdrop(eventType: NotificationEventType, balanceNoti: BalanceNotification, rawMessage: String) {
        performNotifications(noti: balanceNoti, rawMessage: rawMessage)
    }
}

extension CorePresenter: PaymentQRModuleDelegate {
    func requestAddressBookInterfaceForPaymentRequest() {
        requestingABModule = .Payment
        coreWireframe?.presentAddressBookInterface()
    }
}
