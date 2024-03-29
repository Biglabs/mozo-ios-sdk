//
//  CoreWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/12/18.
//

import Foundation

class CoreWireframe : MozoWireframe {
    var walletWireframe: WalletWireframe?
    var txWireframe: TransactionWireframe?
    var txhWireframe: TxHistoryWireframe?
    var txCompleteWireframe: TxCompletionWireframe?
    var txDetailWireframe: TxDetailWireframe?
    var abWireframe: AddressBookWireframe?
    var abDetailWireframe: ABDetailWireframe?
    var paymentWireframe: PaymentWireframe?
    var paymentQRWireframe: PaymentQRWireframe?
    var convertWireframe: ConvertWireframe?
    var speedSelectionWireframe: SpeedSelectionWireframe?
    var resetPinWireframe: ResetPINWireframe?
    var backupWalletWireframe: BackupWalletWireframe?
    var changePINWireframe: ChangePINWireframe?
    var topUpWireframe: TopUpWireframe?
    var corePresenter: CorePresenter?
    
    // MARK: Request
    func requestForAuthentication() {
        corePresenter?.requestForAuthentication(module: Module.Wallet)
    }
    
    func requestForLogout() {
        corePresenter?.requestForLogout()
    }
    
    func requestForTransfer() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.Transaction)
    }
    
    func requestForTxHistory() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.TxHistory)
    }
    
    func requestForPaymentRequest() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.Payment)
    }
    
    func requestForAddressBook() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.AddressBook)
    }
    
    func requestForTransactionDetail(txHistory: TxHistoryDisplayItem) {
        presentWaitingInterface()
        corePresenter?.txHistoryModuleDidChooseItemOnUI(txHistory: txHistory, type: .All)
    }
    
    func requestForConvert(isConvertOffchainToOffchain: Bool) {
        convertWireframe?.isConvertOffchainToOffchain = isConvertOffchainToOffchain
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.Convert)
    }
    
    func requestForChangePin() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.ChangePIN)
    }
    
    func requestForBackUpWallet() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: Module.BackupWallet)
    }
    
    func requestForCloseAllMozoUIs(completion: @escaping (() -> Swift.Void)) {
        rootWireframe?.closeAllMozoUIs(completion: completion)
    }
    
    func requestCloseToLastMozoUIs() {
        rootWireframe?.closeToLastMozoUIs()
    }
    
    func requestForTopUpTransfer() {
        presentWaitingInterface()
        corePresenter?.requestForAuthentication(module: .TopUp)
    }
    
    func prepareForTransferInterface() {
        txWireframe?.presentTransferInterface()
    }
    
    func prepareForTxHistoryInterface() {
        txhWireframe?.presentTxHistoryInterface()
    }
    
    func prepareForWalletInterface() {
        walletWireframe?.presentInitialWalletInterface()
    }
    
    func prepareForPaymentRequestInterface() {
        paymentWireframe?.presentPaymentRequestInterface()
    }
    
    func presentPINInterfaceForTransaction() {
        walletWireframe?.walletPresenter?.pinModuleDelegate = ModuleDependencies.shared.txPresenter
        walletWireframe?.presentPINInterface(passPharse: nil, requestFrom: Module.Transaction)
    }
    
    func presentPINInterface() {
        walletWireframe?.presentPINInterface(passPharse: nil)
    }
    
    func presentTransactionCompleteInterface(_ detail: TxDetailDisplayItem) {
        txCompleteWireframe?.presentTransactionCompleteInterface(detail)
    }
    
    func presentTransactionDetailInterface(_ detail: TxDetailDisplayItem) {
        txDetailWireframe?.presentTransactionDetailInterface(detail)
    }
    
    func presentAddressBookDetailInterface(address: String) {
        abDetailWireframe?.presentAddressBookDetailInterfaceWithAddress(address: address)
    }
    
    func dismissAddressBookDetailInterface() {
        abDetailWireframe?.dismissAddressBookDetailInterface()
    }
    
    func presentAddressBookInterface(_ forSelecting: Bool = true) {
        abWireframe?.presentAddressBookInterface(isDisplayForSelect: forSelecting)
    }
    
    func presentConvertInterface() {
        convertWireframe?.presentConvertInterface()
    }
    
    func updateAddressBookInterfaceForTransaction(displayItem: AddressBookDisplayItem) {
        ModuleDependencies.shared.txPresenter.updateInterfaceWithDisplayItem(displayItem)
    }
    
    func updateAddressBookInterfaceForPaymentRequest(displayItem: AddressBookDisplayItem) {
        paymentQRWireframe?.updateInterfaceWithAddressBook(displayItem)
    }
    
    func dismissAddressBookInterface() {
        abWireframe?.dismissAddressBookInterface()
    }
    
    func presentSpeedSelectionInterface() {
        speedSelectionWireframe?.presentSpeedSelectionInterface()
    }
    
    func processWalletAuto(isCreateNew: Bool = false) {
        walletWireframe?.processInitialWallet(isCreateNew: isCreateNew)
    }
    
    func presentResetPinInterface() {
        resetPinWireframe?.presentResetPINInterface(requestFrom: .Settings)
    }
    
    func presentChangePINInterface() {
        changePINWireframe?.processChangePIN()
    }
    
    func presentBackupWalletInterface() {
        backupWalletWireframe?.processBackup()
    }
    
    func presentTopUpTransferInterface() {
        
    }
}
