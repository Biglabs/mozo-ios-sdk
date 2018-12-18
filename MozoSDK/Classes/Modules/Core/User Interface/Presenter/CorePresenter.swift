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

    override init() {
        super.init()
        initSilentServices()
        addAppObservations()
        initUserNotificationCenter()
        setupReachability()
    }
    
    // MARK: Reachability
    func setupReachability() {
        let hostName = Configuration.BASE_HOST
        print("Set up Reachability with host name: \(hostName)")
        reachability = Reachability(hostname: hostName)
        reachability?.whenReachable = { reachability in
            print("Reachability when reachable: \(reachability.description) - \(reachability.connection)")
            self.startSlientServices()
            self.coreInteractor?.downloadConvenienceDataAndStoreAtLocal()
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
    
    deinit {
        stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Silent services methods
private extension CorePresenter {
    private func initUserNotificationCenter() {
        registerForRichNotifications()
        // set UNUserNotificationCenter delegate
        if UNUserNotificationCenter.current().delegate == nil {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    private func initSilentServices() {
        
    }
    
    private func addAppObservations() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    private func startSlientServices() {
        // Check walletInfo from UserProfile to start silent services
        if let userObj = SessionStoreManager.loadCurrentUser(), let profile = userObj.profile, profile.walletInfo?.offchainAddress != nil {
            print("CorePresenter - Start silent services.")
            rdnInteractor?.startService()
        }
    }
    
    private func stopSilentServices() {
        print("CorePresenter - Stop silent services.")
        // Stop silent services
        rdnInteractor?.stopService()
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
        })
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
        default: coreWireframe?.prepareForWalletInterface()
        }
    }
}
extension CorePresenter : CoreModuleWaitingInterface {
    func retryGetUserProfile() {
        if let module = callBackModule {
            requestForAuthentication(module: module)
        }
    }
}
extension CorePresenter : AuthModuleDelegate {
    func didCheckAuthorizationSuccess() {
        print("On Check Authorization Did Success: Download convenience data")
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        coreInteractor?.downloadConvenienceDataAndStoreAtLocal()
    }
    
    func didCheckAuthorizationFailed() {
        print("On Check Authorization Did Failed - No connection")
    }
    
    func didRemoveTokenAndLogout() {
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKED
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
    }
    
    func authModuleDidFinishAuthentication(accessToken: String?) {
        coreInteractor?.handleAferAuth(accessToken: accessToken)
        // Notify for all observing objects
        self.coreInteractor?.notifyAuthSuccessForAllObservers()
    }
    
    func authModuleDidCancelAuthentication() {
        requestForCloseAllMozoUIs()
    }
    
    func authModuleDidFinishLogout() {
        // Send delegate back to the app
        authDelegate?.mozoLogoutDidFinish()
        // Notify for all observing objects
        coreInteractor?.notifyLogoutForAllObservers()
        requestForCloseAllMozoUIs()
        stopSilentServices()
    }
    
    func authModuleDidCancelLogout() {
        
    }
}

extension CorePresenter: WalletModuleDelegate {
    func walletModuleDidFinish() {
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
        coreInteractor?.downloadConvenienceDataAndStoreAtLocal()
        startSlientServices()
    }
}

extension CorePresenter : CoreInteractorOutput {
    func continueWithWallet(_ callbackModule: Module) {
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
        if let requestingModule = requestingModule {
            callBackModule = requestingModule
        }
        waitingViewInterface?.displayTryAgain(error)
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
        coreWireframe?.presentAddressBookInterfaceForSelecting()
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
    func didCustomerCame(ccNoti: CustomerComeNotification) {
        performNotifications(noti: ccNoti)
    }
    
    func balanceDidChange(balanceNoti: BalanceNotification) {
        coreInteractor?.notifyBalanceChangesForAllObservers(balanceNoti: balanceNoti)
        performNotifications(noti: balanceNoti)
    }
    
    func addressBookDidChange(addressBookList: [AddressBookDTO]) {
        SafetyDataManager.shared.addressBookList = addressBookList
        coreInteractor?.notifyAddressBookChangesForAllObservers()
    }
    
    func didAirdropped(airdropNoti: BalanceNotification) {
        performNotifications(noti: airdropNoti)
    }
}

extension CorePresenter: PaymentQRModuleDelegate {
    func requestAddressBookInterfaceForPaymentRequest() {
        requestingABModule = .Payment
        coreWireframe?.presentAddressBookInterfaceForSelecting()
    }
}
