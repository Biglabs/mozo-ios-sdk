//
//  CorePresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/13/18.
//

import Foundation
import UserNotifications

class CorePresenter : NSObject {
    var coreWireframe : CoreWireframe?
    var coreInteractor : CoreInteractorInput?
    var coreInteractorService : CoreInteractorService?
    var rdnInteractor : RDNInteractorInput?
    weak var authDelegate: AuthenticationDelegate?
    var callBackModule: Module?
    
    override init() {
        super.init()
        initSilentServices()
        addAppObservations()
        initUserNotificationCenter()
    }
    
    deinit {
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
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
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
    
    @objc func didBecomeActive(_ notification: Notification) {
        print("App did become active.")
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
        default: coreWireframe?.prepareForWalletInterface()
        }
    }
}

extension CorePresenter : AuthModuleDelegate {
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
        coreWireframe?.presentAddressBookInterfaceForTransaction()
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
            coreWireframe?.updateAddressBookInterfaceForTransaction(displayItem: addressBook)
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
    func balanceDidChange(balanceNoti: BalanceNotification) {
        coreInteractor?.notifyBalanceChangesForAllObservers(balanceNoti: balanceNoti)
        performNotifications(noti: balanceNoti)
    }
    
    func addressBookDidChange(addressBookList: [AddressBookDTO]) {
        SafetyDataManager.shared.addressBookList = addressBookList
        coreInteractor?.notifyAddressBookChangesForAllObservers()
    }
}
