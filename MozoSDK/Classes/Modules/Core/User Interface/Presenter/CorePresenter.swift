//
//  CorePresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import UserNotifications
import Reachability
import UserNotificationsUI
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
    
    internal var isProcessing = false
    internal var alertController: UIAlertController? = nil
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMaintenanceHealthy), name: .didMaintenanceComplete, object: nil)
        
        initSilentServices()
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
        do {
            try reachability = Reachability(hostname: hostName)
            reachability?.whenReachable = { reachability in
                print("Reachability when reachable: \(reachability.description) - \(reachability.connection)")
                self.readyForGoingLive()
            }
            reachability?.whenUnreachable = { reachability in
                print("Reachability when unreachable: \(reachability.description) - \(reachability.connection)")
                self.stopSilentServices()
            }
            print("Reachability --- start notifier")
            
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
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    deinit {
        stopNotifier()
        NotificationCenter.default.removeObserver(self)
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
        case .SpeedSelection:
            coreWireframe?.presentSpeedSelectionInterface()
        case .ChangePIN:
            coreWireframe?.presentChangePINInterface()
        case .BackupWallet:
            coreWireframe?.presentBackupWalletInterface()
        case .TopUp:
            coreWireframe?.presentTopUpTransferInterface()
        default: coreWireframe?.prepareForWalletInterface()
        }
    }
}

// MARK: Silent services methods
private extension CorePresenter {
    private func initUserNotificationCenter() {
        registerForRichNotifications()
    }
    
    private func initSilentServices() {
        
    }
    
    private func startSlientServices() {
        // Check walletInfo from UserProfile to start silent services
        if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, profile.walletInfo?.offchainAddress != nil, SafetyDataManager.shared.checkTokenExpiredStatus != .CHECKING,
           AccessTokenManager.getAccessToken() != nil {
            "CorePresenter - Start silent services, socket service.".log()
            rdnInteractor?.startService()
            "CorePresenter - Start silent services, refresh token service.".log()
            coreWireframe?.authWireframe?.startRefreshTokenTimer()
        }
    }
    
    internal func stopSilentServices(shouldReconnect: Bool = true) {
        "CorePresenter - Stop silent services, socket service".log()
        // Stop silent services
        rdnInteractor?.stopService(shouldReconnect: shouldReconnect)
    }
    
    @objc func didFinishLaunching(_ notification: Notification) {
        startSlientServices()
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        // MARK: willEnterForeground
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        // MARK: didEnterBackground
    }
    
    @objc func willTerminate(_ notification: Notification) {
        stopSilentServices()
    }
    
    @objc func didReceiveMaintenanceHealthy(_ notification: Notification) {
        if let topViewController = DisplayUtils.getTopViewController(), topViewController is WaitingViewController {
            retryGetUserProfile()
        }
    }
}
extension CorePresenter : CoreModuleInterface {
    func requestForAuthentication(module: Module) {
        "Start login: \(!isProcessing)".log()
        if !isProcessing {
            isProcessing = true
            coreInteractor?.checkForAuthentication(module: module)
        }
    }
    
    func requestForLogout() {
        "Start logout: \(!isProcessing)".log()
        if !isProcessing {
            isProcessing = true
            coreWireframe?.authWireframe?.presentLogoutInterface()
        }
    }
    
    func requestForCloseAllMozoUIs(_ callback: (() -> Void)?) {
        if DisplayUtils.isAuthenticationOnTop() {
            "CorePresenter - Request for close all MozoUI, Authentication screen is being displayed.".log()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.requestForCloseAllMozoUIs(callback)
            }
            return
        }
        coreWireframe?.requestForCloseAllMozoUIs(completion: {
            self.authDelegate?.mozoUIDidCloseAll()
            self.coreInteractor?.notifyDidCloseAllMozoUIForAllObservers()
            self.isProcessing = false
            callback?()
        })
        
        removePINDelegate()
    }
    
    func requestCloseToLastMozoUIs() {
        coreWireframe?.requestCloseToLastMozoUIs()
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
extension CorePresenter: WalletModuleDelegate {
    func walletModuleDidFinish() {
        print("CorePresenter - Wallet Module Did Finished, callbackModule: \(callBackModule?.value ?? "NO MODULE")")
        if let topViewController = DisplayUtils.getTopViewController(), topViewController is MaintenanceViewController {
            print("CorePresenter - Wallet Module Did Finished but top view controller is MaintenanceViewController - Must wait until maintenance mode back to healthy mode")
            return
        }
        if callBackModule == .Wallet {
            callBackModule = nil
        }
        if callBackModule != nil {
            // Present call back module interface
            requestCloseToLastMozoUIs()
            presentModuleInterface(callBackModule!)
            callBackModule = nil
        } else {
            if coreWireframe?.rootWireframe?.mozoNavigationController.viewControllers.count ?? 0 > 0 {
                // Close all existing Mozo's UIs
                coreWireframe?.requestForCloseAllMozoUIs(completion: {
                    self.isProcessing = false
                    // Send delegate back to the app
                    self.authDelegate?.mozoAuthenticationDidFinish()
                })
            } else {
                self.isProcessing = false
                // Send delegate back to the app
                self.authDelegate?.mozoAuthenticationDidFinish()
            }
        }
        readyForGoingLive()
    }
    
    func cancelFlow() {
        requestForCloseAllMozoUIs(nil)
    }
}

extension CorePresenter : CoreInteractorOutput {
    func continueWithSpeedSelection(_ callbackModule: Module) {
        print("CorePresenter - Continue with Speed Selection, callbackModule: \(callbackModule.value)")
        // Should display call back module (if any)
        self.callBackModule = callbackModule
        presentModuleInterface(.SpeedSelection)
    }
    
    func continueWithWalletAuto(_ callbackModule: Module) {
        "CorePresenter - Continue with Wallet Auto, callbackModule: \(callbackModule.value)".log()
        // Should display call back module (if any)
        self.callBackModule = callbackModule
        coreWireframe?.processWalletAuto()
    }
    
    func continueWithWallet(_ callbackModule: Module) {
        "CorePresenter - Continue with Wallet, callbackModule: \(callbackModule.value)".log()
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
    
    func didDetectWalletInAutoMode(module: Module) {
        callBackModule = module
        walletModuleDidFinish()
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
        self.authDelegate?.mozoDidExpiredToken()
    }
    
    func didReceiveAuthorizationRequired() {
        print("CorePresenter - Did receive authorization required")
        if let viewController = DisplayUtils.getTopViewController(), !viewController.isKind(of: WaitingViewController.self) {
            self.authDelegate?.mozoDidExpiredToken()
        } else {
            // Ignore
        }
    }
    
    func didReceiveMaintenance() {
        coreInteractor?.notifyMaintenance(isComplete: false)
    }
    
    func didReceiveDeactivated(error: ErrorApiResponse) {
        DisplayUtils.displayAccessDeniedScreen()
    }
    
    func didReceiveRequireUpdate(type: ErrorApiResponse) {
        if type == .UPDATE_VERSION_REQUIREMENT {
            DisplayUtils.displayUpdateRequireScreen()
            
        } else if alertController == nil, let viewController = DisplayUtils.getTopViewController() {
            alertController = UIAlertController(title: "Info".localized, message: type.description.localized, preferredStyle: UIAlertController.Style.alert)
            alertController!.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.cancel, handler: { action in
                self.alertController = nil
            }))
            viewController.present(alertController!, animated: true, completion: nil)
        }
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
        // TODO: Should download address book here
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
        "CorePresenter - Did receive invalid token from Notification Module".log()
        requestForLogout()
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
    
    func didReceivedPromotionUsed(eventType: NotificationEventType, usedNoti: PromotionUsedNotification, rawMessage: String) {
        performNotifications(noti: usedNoti, rawMessage: rawMessage)
    }
    
    func didReceivedPromotionPurchased(eventType: NotificationEventType, purchasedNoti: PromotionPurchasedNotification, rawMessage: String) {
        performNotifications(noti: purchasedNoti, rawMessage: rawMessage)
    }
    
    func didReceivedCovidWarning(eventType: NotificationEventType, warningNoti: CovidWarningNotification, rawMessage: String) {
        performNotifications(noti: warningNoti, rawMessage: rawMessage)
    }
    
    func didReceivedLuckyDraw(noti: LuckyDrawNotification, rawMessage: String) {
        performNotifications(noti: noti, rawMessage: rawMessage)
    }
}

extension CorePresenter: PaymentQRModuleDelegate {
    func requestAddressBookInterfaceForPaymentRequest() {
        requestingABModule = .Payment
        coreWireframe?.presentAddressBookInterface()
    }
}
