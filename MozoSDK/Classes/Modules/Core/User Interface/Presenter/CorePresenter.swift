//
//  CorePresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import Alamofire

class CorePresenter : NSObject {
    var coreWireframe : CoreWireframe?
    var coreInteractor : CoreInteractorInput?
    var coreInteractorService : CoreInteractorService?
    var rdnInteractor : RDNInteractorInput?
    weak var authDelegate: MozoAuthenticationDelegate?
    var callBackModule: Module?
    
    var requestingABModule: Module?
    var isNetworkAvailable = false
    internal var alertController: UIAlertController? = nil
    private var retryAction: WaitingRetryAction?
    private var networkManager: NetworkReachabilityManager?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMaintenanceHealthy), name: .didMaintenanceComplete, object: nil)
        
        initSilentServices()
        initUserNotificationCenter()
        
        networkManager = NetworkReachabilityManager()!
        networkManager?.startListening(onQueue: DispatchQueue.main) { (status) in
            switch(status) {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self.isNetworkAvailable = true
                self.readyForGoingLive()
                break
            default:
                self.isNetworkAvailable = false
                self.stopSilentServices()
                break
            }
        }
    }
    
    func readyForGoingLive() {
        coreInteractor?.downloadAndStoreConvenienceData()
        startSlientServices()
    }
    
    func stopNotifier() {
        networkManager?.stopListening()
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
    
    func displayTryAgain(_ error: ConnectionError, forAction: WaitingRetryAction?) {
        self.retryAction = forAction
        if error == .apiError_INVALID_USER_TOKEN {
            DisplayUtils.displayTokenExpired()
            
        } else if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            
        } else {
            if let topViewController = DisplayUtils.getTopViewController(), topViewController is WaitingViewController {
                DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
            }
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
            ModuleDependencies.shared.authPresenter.startRefreshTokenTimer()
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
        if ModuleDependencies.shared.isNetworkReachable() {
            coreInteractor?.checkForAuthentication(module: module)
        } else {
            if let vc = DisplayUtils.getTopViewController() {
                self.callBackModule = module
                self.retryAction = .PerformSignIn
                DisplayUtils.displayTryAgainPopupInParentView(
                    parentView: vc.view,
                    delegate: self
                )
            }
        }
    }
    
    func requestForLogout() {
        if ModuleDependencies.shared.isNetworkReachable() {
            ModuleDependencies.shared.authPresenter.performLogout()
        } else {
            if let vc = DisplayUtils.getTopViewController() {
                self.retryAction = .PerformSignOut
                DisplayUtils.displayTryAgainPopupInParentView(
                    parentView: vc.view,
                    delegate: self
                )
            }
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
        requestForAuthentication(module: callBackModule ?? .Wallet)
    }
    
    func retryAuth() {
        ModuleDependencies.shared.authPresenter.performAuthentication()
    }
}
extension CorePresenter: WalletModuleDelegate {
    func walletModuleDidFinish() {
        if let topVc = DisplayUtils.getTopViewController(), topVc is MaintenanceViewController {
            "CorePresenter - Maintenance mode".log()
            return
        }
        if callBackModule != nil, callBackModule != .Wallet {
            // Present call back module interface
            requestCloseToLastMozoUIs()
            presentModuleInterface(callBackModule!)
        } else {
            coreWireframe?.requestForCloseAllMozoUIs(completion: {
                // Send delegate back to the app
                self.authDelegate?.didSignInSuccess()
            })
        }
        callBackModule = nil
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
            ModuleDependencies.shared.authPresenter.performAuthentication()
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
        callBackModule = requestingModule
        // Check connection error
        if error == .authenticationRequired {
            self.displayTryAgain(ConnectionError.apiError_INVALID_USER_TOKEN, forAction: nil)
            return
        }
        self.displayTryAgain(error, forAction: .LoadUserProfile)
    }
    
    func didReceiveInvalidToken() {
        self.authDelegate?.mozoDidExpiredToken()
    }
    
    func didReceiveAuthorizationRequired() {
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
    func txHistoryModuleDidChooseItemOnUI(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO, type: TransactionType) {
        let data = TxDetailDisplayData(txHistory: txHistory, tokenInfo: tokenInfo)
        data.type = type
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
extension CorePresenter : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        if let action = self.retryAction {
            switch action {
            case .PerformSignIn, .PerformSignOut:
                self.callBackModule = nil
                self.authModuleDidCancelAuthentication()
                break
            default:
                break
            }
        }
        self.retryAction = nil
    }
    
    func didTouchTryAgainButton() {
        if let retryAction = self.retryAction {
            switch retryAction {
            case .LoadUserProfile:
                self.retryGetUserProfile()
                break
            case .BuildAuth:
                self.retryAuth()
                break
            case .PerformSignIn:
                if let module = self.callBackModule {
                    self.requestForAuthentication(module: module)
                } else {
                    self.authModuleDidCancelAuthentication()
                }
                break
            case .PerformSignOut:
                self.requestForLogout()
                break
            }
        }
        self.retryAction = nil
    }
}
