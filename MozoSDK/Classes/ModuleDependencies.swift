//
//  ModuleDependencies.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/27/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import PromiseKit

class ModuleDependencies {
    static var shared = ModuleDependencies()
    
    let rootWireframe = RootWireframe()
    
    let coreWireframe = CoreWireframe()
    let corePresenter = CorePresenter()
    
    let walletWireframe = WalletWireframe()
    let resetPINWireframe = ResetPINWireframe()
    
    let authManager = AuthManager()
    let authPresenter = AuthPresenter()
    
    let txWireframe = TransactionWireframe()
    let txPresenter = TransactionPresenter()
    let txhWireframe = TxHistoryWireframe()
    let txComWireframe = TxCompletionWireframe()
    let txDetailWireframe = TxDetailWireframe()
    let abDetailWireframe = ABDetailWireframe()
    let abWireframe = AddressBookWireframe()
    let adWireframe = AirdropWireframe()
    let addWireframe = AirdropAddWireframe()
    let withdrawWireframe = WithdrawWireframe()
    let paymentWireframe = PaymentWireframe()
    let paymentQRWireframe = PaymentQRWireframe()
    let convertWireframe = ConvertWireframe()
    let txProcessWireframe = TxProcessWireframe()
    let convertCompletionWireframe = ConvertCompletionWireframe()
    let speedSelectionWireframe = SpeedSelectionWireframe()
    let backupWalletWireframe = BackupWalletWireframe()
    let changePINWireframe = ChangePINWireframe()
    let abImportWireframe = ABImportWireframe()
    let topUpWireframe = TopUpWireframe()
    let topUpWithdrawWireframe = TopUpWithdrawWireframe()
    
//    let webSocketManager = WebSocketManager()
    
    // MARK: Initialization
    init() {
        configureDependencies()
    }
    
    func setAuthDelegate(_ delegate: MozoAuthenticationDelegate) {
        corePresenter.authDelegate = delegate
        authManager.checkAuthorization()
    }
    
    func authenticate() {
        coreWireframe.requestForAuthentication()
    }
    
    func logout() {
        coreWireframe.requestForLogout()
    }
    
    func transferMozo() {
        coreWireframe.requestForTransfer()
    }
    
    func displayTransactionHistory() {
        coreWireframe.requestForTxHistory()
    }
    
    func displayPaymentRequest() {
        coreWireframe.requestForPaymentRequest()
    }
    
    func displayAddressBook() {
        coreWireframe.requestForAddressBook()
    }
    
    func convertMozoXOnchain(isConvertOffchainToOffchain: Bool) {
        coreWireframe.requestForConvert(isConvertOffchainToOffchain: isConvertOffchainToOffchain)
    }
    
    func displayTransactionDetail(txHistory: TxHistoryDisplayItem) {
        coreWireframe.requestForTransactionDetail(txHistory: txHistory)
    }
    
    func loadEthAndOnchainBalanceInfo() -> Promise<OnchainInfoDTO> {
        return (corePresenter.coreInteractorService?.loadEthAndOnchainBalanceInfo())!
    }
    
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.registerBeacon(parameters: parameters))!
    }
    
    func registerMoreBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.registerMoreBeacon(parameters: parameters))!
    }
    
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.updateBeaconSettings(parameters: parameters))!
    }
    
    func deleteBeacon(beaconId: Int64) -> Promise<Bool> {
        return (corePresenter.coreInteractorService?.deleteBeacon(beaconId: beaconId))!
    }
    
    func getRetailerInfo() -> Promise<[String : Any]> {
        return (corePresenter.coreInteractorService?.getRetailerInfo())!
    }
    
    func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.addSalePerson(parameters:parameters))!
    }
    
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return (corePresenter.coreInteractorService?.getTxHistoryDisplayCollection())!
    }
    
    func createAirdropEvent(event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        adWireframe.requestCreateAndSignAirdropEvent(event, delegate: delegate)
    }
    
    func addMoreMozoToAirdropEvent(event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        addWireframe.requestToAddMoreAndSign(event, delegate: delegate)
    }
    
    func withdrawMozoFromAirdropEventId(_ eventId: Int64, delegate: WithdrawAirdropEventDelegate) {
        withdrawWireframe.requestToWithdrawAndSign(eventId, delegate: delegate)
    }
    
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return (corePresenter.coreInteractorService?.getLatestAirdropEvent())!
    }
    
    func getAirdropEventList(page: Int, branchId: Int64? = nil) -> Promise<[AirdropEventDTO]> {
        return (corePresenter.coreInteractorService?.getAirdropEventList(page: page, branchId: branchId))!
    }
    
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return (corePresenter.coreInteractorService?.getRetailerAnalyticHome())!
    }
    
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return (corePresenter.coreInteractorService?.getRetailerAnalyticList())!
    }
    
    func getVisitCustomerList(page: Int, size: Int, year: Int, month: Int) -> Promise<[VisitedCustomerDTO]> {
        return (corePresenter.coreInteractorService?.getVisitCustomerList(page: page, size: size, year: year, month: month))!
    }
    
    func getRetailerAnalyticAmountAirdropList(page: Int, size: Int, year: Int, month: Int) -> Promise<[AirDropReportDTO]> {
        return (corePresenter.coreInteractorService?.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month))!
    }
    
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]> {
        return (corePresenter.coreInteractorService?.getRunningAirdropEvents(page: page, size: size))!
    }
    
    func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return (corePresenter.coreInteractorService?.getListSalePerson())!
    }
    
    func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.removeSalePerson(id: id))!
    }
    
    func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return (corePresenter.coreInteractorService?.getListCountryCode())!
    }
    
    func getUrlToUploadImage() -> Promise<String> {
        return (corePresenter.coreInteractorService?.getUrlToUploadImage())!
    }
    
    func uploadImage(images: [UIImage], url: String, progressionHandler: @escaping (_ fractionCompleted: Double)-> Void) -> Promise<[String]> {
        return (corePresenter.coreInteractorService?.uploadImage(images: images, url: url, progressionHandler: progressionHandler))!
    }
    
    func updateUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return (corePresenter.coreInteractorService?.updateUserProfile(userProfile: userProfile))!
    }
    
    func updateAvatarToUserProfile(userProfile: UserProfileDTO) -> Promise<UserProfileDTO> {
        return (corePresenter.coreInteractorService?.updateAvatarToUserProfile(userProfile: userProfile))!
    }
    
    func getCommonHashtag() -> Promise<[String]> {
        return (corePresenter.coreInteractorService?.getCommonHashtag())!
    }
    
    func deleteRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return (corePresenter.coreInteractorService?.deleteRetailerStoreInfoPhotos(photos: photos))!
    }
    
    func updateRetailerStoreInfoPhotos(photos: [String]) -> Promise<StoreInfoDTO> {
        return (corePresenter.coreInteractorService?.updateRetailerStoreInfoPhotos(photos: photos))!
    }
    
    func updateRetailerStoreInfoHashtag(hashTags: [String]) -> Promise<StoreInfoDTO> {
        return (corePresenter.coreInteractorService?.updateRetailerStoreInfoHashtag(hashTags: hashTags))!
    }
    
    func updateRetailerStoreInfo(storeInfo: StoreInfoDTO) -> Promise<StoreInfoDTO> {
        return (corePresenter.coreInteractorService?.updateRetailerStoreInfo(storeInfo: storeInfo))!
    }
    
    func getRecommendationStores(_ storeId: Int64, size: Int, long: Double?, lat: Double?) -> Promise<[BranchInfoDTO]> {
        return (corePresenter.coreInteractorService?.getRecommendationStores(storeId, size: size, long: long, lat: lat))!
    }
    
    func handleAccessRemove() {
        corePresenter.handleAccessRemoved()
    }
    
    func requestSupportBeacon(info: SupportRequestDTO) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.requestSupportBeacon(info: info))!
    }
    
    func getOffchainTokenInfo() -> Promise<OffchainInfoDTO> {
        return (corePresenter.coreInteractorService?.getOffchainTokenInfo())!
    }
    
    func getInviteLink(locale: String, inviteAppType: AppType) -> Promise<InviteLinkDTO> {
        return (corePresenter.coreInteractorService?.getInviteLink(locale: locale, inviteAppType: inviteAppType))!
    }
    
    func getListLanguageInfo() -> Promise<[InviteLanguageDTO]> {
        return (corePresenter.coreInteractorService?.getListLanguageInfo())!
    }
    
    func updateCodeLinkInstallApp(codeString: String) -> Promise<InviteLinkDTO> {
        return (corePresenter.coreInteractorService?.updateCodeLinkInstallApp(codeString: codeString))!
    }
    
    func processInvitationCode() {
        return (corePresenter.coreInteractorService?.processInvitationCode())!
    }
    
    func getListNotification(page: Int, size: Int) -> Promise<[WSMessage]> {
        return (corePresenter.coreInteractorService?.getListNotification(page: page, size: size))!
    }
    
    func loadUserProfile() -> Promise<UserProfileDTO> {
        return (corePresenter.coreInteractorService?.loadUserProfile())!
    }
    
    func getCreateAirdropEventSettings() -> Promise<AirdropEventSettingDTO> {
        return (corePresenter.coreInteractorService?.getCreateAirdropEventSettings())!
    }
    
    func requestForChangePin() {
        coreWireframe.requestForChangePin()
    }
    
    func requestForBackUpWallet() {
        coreWireframe.requestForBackUpWallet()
    }
    
    func getRetailerPromotionList(page: Int, size: Int, statusRequest: PromotionStatusRequestEnum) -> Promise<[PromotionDTO]> {
        return (corePresenter.coreInteractorService?.getRetailerPromotionList(page: page, size: size, statusRequest: statusRequest))!
    }
    
    func processPromotionCode(code: String) -> Promise<PromotionCodeInfoDTO> {
        return (corePresenter.coreInteractorService?.processPromotionCode(code: code))!
    }
    
    func usePromotionCode(code: String, billInfo: String?) -> Promise<PromotionCodeInfoDTO> {
        return (corePresenter.coreInteractorService?.usePromotionCode(code: code, billInfo: billInfo))!
    }
    
    func cancelPromotionCode(code: String) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.cancelPromotionCode(code: code))!
    }
    
    func updateFavoritePromotion(_ promotionId: Int64, isFavorite: Bool) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.updateFavoritePromotion(promotionId, isFavorite: isFavorite))!
    }
    
    func getShopperPromotionRunning(page: Int, size: Int, long: Double, lat: Double, storeId: Int64) -> Promise<JSON> {
        return (corePresenter.coreInteractorService?.getShopperPromotionRunning(page: page, size: size, long: long, lat: lat, storeId: storeId))!
    }
    
    func getRetailerPromotionScannedList(page: Int, size: Int) -> Promise<[PromotionCodeInfoDTO]> {
        return (corePresenter.coreInteractorService?.getRetailerPromotionScannedList(page: page, size: size))!
    }
    
    func getRetailerCountPromotion() -> Promise<Int> {
        return (corePresenter.coreInteractorService?.getRetailerCountPromotion())!
    }
    
    func loadTopUpBalanceInfo() -> Promise<DetailInfoDisplayItem> {
        return (corePresenter.coreInteractorService?.loadTopUpBalanceInfo())!
    }
    
    func loadTopUpHistory(topUpAddress: String?, page: Int, size: Int) -> Promise<TxHistoryDisplayCollection> {
        return (corePresenter.coreInteractorService?.loadTopUpHistory(topUpAddress: topUpAddress, page: page, size: size))!
    }
    
    func openTopUpTransfer(delegate: TopUpDelegate) {
        topUpWireframe.presentTopUpTransferInterface(delegate: delegate)
    }
    
    func topUpWithdraw(delegate: TopUpWithdrawDelegate) {
        topUpWithdrawWireframe.requestToWithdrawAndSign(delegate: delegate)
    }
    
    func getPromotionStoreGroup(page: Int, size: Int, long: Double, lat: Double) -> Promise<JSON> {
        return (corePresenter.coreInteractorService?.getPromotionStoreGroup(page: page, size: size, long: long, lat: lat))!
    }
    
    func getBranchList(page: Int, forSwitching: Bool) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.getBranchList(page: page, forSwitching: forSwitching))!
    }
     
    func switchBranch(_ branchId: Int64) -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.switchBranch(branchId))!
    }
    
    func getRetailerInfoForLauching() -> Promise<[String: Any]> {
        return (corePresenter.coreInteractorService?.getRetailerInfoForLauching())!
    }

    func checkBranchName(_ name: String) -> Promise<Any> {
        return (corePresenter.coreInteractorService?.checkBranchName(name))!
    }
    
    func updateSalePerson(account: SalePersonDTO) -> Promise<SalePersonDTO> {
        return (corePresenter.coreInteractorService?.updateSalePerson(account: account))!
    }
    
    // MARK: Mozo Messages APIs
    func getConversationList(text: String?, page: Int) -> Promise<[Conversation]> {
        return (corePresenter.coreInteractorService?.getConversationList(text: text, page: page))!
    }
    func getConversationDetails(id: Int64) -> Promise<Conversation?> {
        return (corePresenter.coreInteractorService?.getConversationDetails(id: id))!
    }
    func getChatMessages(id: Int64, page: Int) -> Promise<[ConversationMessage]> {
       return (corePresenter.coreInteractorService?.getChatMessages(id: id, page: page))!
    }
    func responseConversation(conversationId: Int64, status: String) -> Promise<Any> {
        return (corePresenter.coreInteractorService?.responseConversation(conversationId: conversationId, status: status))!
    }
    func updateReadConversation(conversationId: Int64, lastMessageId: Int64) -> Promise<Any> {
        return (corePresenter.coreInteractorService?.updateReadConversation(conversationId: conversationId, lastMessageId: lastMessageId))!
    }
    func sendMessage(id: Int64, message: String?, images: [String]?, userSend: Bool) -> Promise<Any> {
        return (corePresenter.coreInteractorService?.sendMessage(id: id, message: message, images: images, userSend: userSend))!
    }
    func configureDependencies() {
        // MARK: Core
        coreDependencies()
        // MARK: Speed Selection
        speedSelectionDependencies()
        // MARK: Auth
        authDependencies()
        // MARK: Wallet
        walletDependencies()
        // MARK: Transaction
        transactionDependencies()
        transactionCompletionDependencies()
        transactionDetailDependencies()
        transactionHistoryDependencies()
        // MARK: Address book
        addressBookDependencies()
        addressBookDetailDependencies()
        // MARK: Payment Request
        paymentDependencies()
        paymentQRDependencies()
        // MARK: Transaction Process
        txProcessDependencies()
        convertCompletionDependencies()
        // MARK: Backup Wallet
        backupWalletDependencies()
        // MARK: Address Book Import
        abImportDependencies()
    }
    
    func coreDependencies() {
        
        let anonManager = AnonManager()
        anonManager.apiManager = ApiManager.shared
        let userDataManager = UserDataManager()
        userDataManager.coreDataStore = CoreDataStore.shared
        
        let coreInteractor = CoreInteractor(anonManager: anonManager, apiManager: ApiManager.shared, userDataManager: userDataManager)
        coreInteractor.output = corePresenter
        
//        let rdnInteractor = RDNInteractor(webSocketManager: webSocketManager)
//        rdnInteractor.output = corePresenter
        
        corePresenter.coreInteractor = coreInteractor
//        corePresenter.rdnInteractor = rdnInteractor
        corePresenter.coreInteractorService = coreInteractor
         
        coreWireframe.corePresenter = corePresenter
        coreWireframe.walletWireframe = walletWireframe
        coreWireframe.txWireframe = txWireframe
        coreWireframe.txhWireframe = txhWireframe
        coreWireframe.txCompleteWireframe = txComWireframe
        coreWireframe.txDetailWireframe = txDetailWireframe
        coreWireframe.abDetailWireframe = abDetailWireframe
        coreWireframe.abWireframe = abWireframe
        coreWireframe.rootWireframe = rootWireframe
        coreWireframe.paymentWireframe = paymentWireframe
        coreWireframe.paymentQRWireframe = paymentQRWireframe
        coreWireframe.convertWireframe = convertWireframe
        coreWireframe.speedSelectionWireframe = speedSelectionWireframe
        coreWireframe.resetPinWireframe = resetPINWireframe
        coreWireframe.backupWalletWireframe = backupWalletWireframe
        coreWireframe.changePINWireframe = changePINWireframe
    }
    
    func changePINDependencies(walletManager: WalletManager, dataManager: WalletDataManager) {
        let changePINPresenter = ChangePINPresenter()
        
        let changePINInteractor = ChangePINInteractor(walletManager: walletManager, dataManager: dataManager, apiManager: ApiManager.shared)
        changePINInteractor.output = changePINPresenter
        
        changePINPresenter.interactor = changePINInteractor
        changePINPresenter.wireframe = changePINWireframe
        
        changePINWireframe.presenter = changePINPresenter
        changePINWireframe.walletWireframe = walletWireframe
        changePINWireframe.rootWireframe = rootWireframe
        
        walletWireframe.walletPresenter?.changePINModuleDelegate = changePINPresenter 
    }
    
    func backupWalletDependencies() {
        let backupWalletPresenter = BackupWalletPresenter()
        
        backupWalletPresenter.wireframe = backupWalletWireframe
        backupWalletPresenter.delegate = walletWireframe.walletPresenter
        
        backupWalletWireframe.walletWireframe = walletWireframe
        backupWalletWireframe.presenter = backupWalletPresenter
        backupWalletWireframe.rootWireframe = rootWireframe
    }
    
    func speedSelectionDependencies() {
        let speedSelectionPresenter = SpeedSelectionPresenter()
        speedSelectionPresenter.delegate = coreWireframe.corePresenter
        speedSelectionWireframe.presenter = speedSelectionPresenter
        speedSelectionWireframe.rootWireframe = rootWireframe
    }
    
    func convertDependencies(signManager: TransactionSignManager) {
        let cvPresenter = ConvertPresenter()
        
        let cvInteractor = ConvertInteractor(apiManager: ApiManager.shared, signManager: signManager)
        cvInteractor.output = cvPresenter
        
        cvPresenter.interactor = cvInteractor
        cvPresenter.wireframe = convertWireframe
        
        convertWireframe.presenter = cvPresenter
        convertWireframe.txProcessWireframe = txProcessWireframe
        convertWireframe.convertCompletionWireframe = convertCompletionWireframe
        convertWireframe.walletWireframe = walletWireframe
        convertWireframe.rootWireframe = rootWireframe
    }
    
    func txProcessDependencies() {
        let tpPresenter = TxProcessPresenter()
        
        let tpInteractor = TxProcessInteractor(apiManager: ApiManager.shared)
        tpInteractor.output = tpPresenter
        
        tpPresenter.interactor = tpInteractor
        
        txProcessWireframe.presenter = tpPresenter
        txProcessWireframe.rootWireframe = rootWireframe
    }
    
    func convertCompletionDependencies() {
        let cvCplPresenter = ConvertCompletionPresenter()
        
        convertCompletionWireframe.presenter = cvCplPresenter
        convertCompletionWireframe.rootWireframe = rootWireframe
    }
    
    func addressBookDetailDependencies() {
        let abdPresenter = ABDetailPresenter()
        
        let abdInteractor = ABDetailInteractor()
        abdInteractor.apiManager = ApiManager.shared
        abdInteractor.output = abdPresenter
        
        abdPresenter.detailInteractor = abdInteractor
        abdPresenter.detailWireframe = abDetailWireframe
        abdPresenter.detailModuleDelegate = coreWireframe.corePresenter
        
        abDetailWireframe.detailPresenter = abdPresenter
        abDetailWireframe.rootWireframe = rootWireframe
    }
    
    func addressBookDependencies() {
        let abPresenter = AddressBookPresenter()
        
        let abInteractor = AddressBookInteractor()
        abInteractor.output = abPresenter
        
        abPresenter.abInteractor = abInteractor
        abPresenter.abWireframe = abWireframe
        abPresenter.abModuleDelegate = coreWireframe.corePresenter
        
        abWireframe.abPresenter = abPresenter
        abWireframe.rootWireframe = rootWireframe
    }
    
    func transactionDetailDependencies() {
        let txDetailPresenter = TxDetailPresenter()
        
        txDetailPresenter.detailModuleDelegate = coreWireframe.corePresenter
        txDetailPresenter.wireframe = txDetailWireframe
        txDetailWireframe.txDetailPresenter = txDetailPresenter
        txDetailWireframe.rootWireframe = rootWireframe
    }
    
    func transactionCompletionDependencies() {
        let txComPresenter = TxCompletionPresenter()
        
        let txComInteractor = TxCompletionInteractor(apiManager: ApiManager.shared)
        txComInteractor.output = txComPresenter
        
        txComPresenter.completionInteractor = txComInteractor
        txComPresenter.completionModuleDelegate = coreWireframe.corePresenter
        
        txComWireframe.txComPresenter = txComPresenter
        txComWireframe.rootWireframe = rootWireframe
    }
    
    func transactionHistoryDependencies() {
        let txhPresenter = TxHistoryPresenter()
        
        let txhInteractor = TxHistoryInteractor(apiManager: ApiManager.shared)
        txhInteractor.output = txhPresenter
        
        txhPresenter.txhInteractor = txhInteractor
        txhPresenter.txhWireframe = txhWireframe
        txhPresenter.txhModuleDelegate = coreWireframe.corePresenter
        
        txhWireframe.txhPresenter = txhPresenter
        txhWireframe.rootWireframe = rootWireframe
    }
    
    func transactionDependencies() {
        let txInteractor = TransactionInteractor(apiManager: ApiManager.shared)
        txInteractor.output = txPresenter
        
        let signManager = TransactionSignManager.shared
        txInteractor.signManager = signManager
        
        txPresenter.txInteractor = txInteractor
        txPresenter.txWireframe = txWireframe
        txPresenter.transactionModuleDelegate = coreWireframe.corePresenter
        
        txWireframe.rootWireframe = rootWireframe
        
        airdropDependencies(signManager: signManager)
        airdropAddDependencies(signManager: signManager)
        airdropWithdrawDependencies(signManager: signManager)
        convertDependencies(signManager: signManager)
        // MARK: Top Up
        topUpDependencies(signManager: signManager)
        topUpWithdrawDependencies(signManager: signManager)
    }
    
    func authDependencies() {
        let authInteractor = AuthInteractor(authManager: authManager)
        authInteractor.output = authPresenter
        
        authPresenter.authManager = authManager
        authPresenter.authInteractor = authInteractor
        authPresenter.authModuleDelegate = coreWireframe.corePresenter
    }
    
    func walletDependencies() {
        let walletPresenter = WalletPresenter()
        
        let walletManager = WalletManager()
        let walletDataManager = WalletDataManager()
        walletDataManager.coreDataStore = CoreDataStore.shared
        
        let walletInteractor = WalletInteractor(walletManager: walletManager, dataManager: walletDataManager, apiManager: ApiManager.shared)
        walletInteractor.output = walletPresenter
        walletInteractor.autoOutput = walletPresenter
        
        walletPresenter.walletInteractor = walletInteractor
        walletPresenter.walletInteractorAuto = walletInteractor
        walletPresenter.walletWireframe = walletWireframe
        walletPresenter.walletModuleDelegate = coreWireframe.corePresenter
        
        walletWireframe.walletPresenter = walletPresenter
        walletWireframe.rootWireframe = rootWireframe
        walletWireframe.resetPINWireframe = resetPINWireframe
        walletWireframe.backupWalletWireframe = backupWalletWireframe
        
        resetPINDependencies(walletManager: walletManager, dataManager: walletDataManager)
        // MARK: Change PIN
        changePINDependencies(walletManager: walletManager, dataManager: walletDataManager)
    }
    
    func resetPINDependencies(walletManager: WalletManager, dataManager: WalletDataManager) {
        let resetPINPresenter = ResetPINPresenter()
        
        let resetPINInteractor = ResetPINInteractor(walletManager: walletManager, dataManager: dataManager, apiManager: ApiManager.shared)
        resetPINInteractor.output = resetPINPresenter
        
        resetPINPresenter.interactor = resetPINInteractor
        resetPINPresenter.wireframe = resetPINWireframe
        
        resetPINWireframe.presenter = resetPINPresenter
        resetPINWireframe.walletWireframe = walletWireframe
        resetPINWireframe.rootWireframe = rootWireframe
        
        walletWireframe.walletPresenter?.resetPinModuleDelegate = resetPINPresenter
    }
    
    func airdropDependencies(signManager: TransactionSignManager) {
        let adPresenter = AirdropPresenter()
        
        let adInteractor = AirdropInteractor()
        adInteractor.apiManager = ApiManager.shared
        adInteractor.output = adPresenter
        adInteractor.signManager = signManager
        
        adPresenter.interactor = adInteractor
        adPresenter.wireframe = adWireframe
        
        adWireframe.adPresenter = adPresenter
        adWireframe.walletWireframe = walletWireframe
        adWireframe.rootWireframe = rootWireframe
    }
    
    func airdropAddDependencies(signManager: TransactionSignManager) {
        let addPresenter = AirdropAddPresenter()
        
        let addInteractor = AirdropAddInteractor()
        addInteractor.apiManager = ApiManager.shared
        addInteractor.output = addPresenter
        addInteractor.signManager = signManager
        
        addPresenter.interactor = addInteractor
        addPresenter.wireframe = addWireframe
        
        addWireframe.addPresenter = addPresenter
        addWireframe.walletWireframe = walletWireframe
        addWireframe.rootWireframe = rootWireframe
    }
    
    func airdropWithdrawDependencies(signManager: TransactionSignManager) {
        let withdrawPresenter = WithdrawPresenter()
        
        let withdrawInteractor = WithdrawInteractor()
        withdrawInteractor.apiManager = ApiManager.shared
        withdrawInteractor.output = withdrawPresenter
        withdrawInteractor.signManager = signManager
        
        withdrawPresenter.interactor = withdrawInteractor
        withdrawPresenter.wireframe = withdrawWireframe
        
        withdrawWireframe.withdrawPresenter = withdrawPresenter
        withdrawWireframe.walletWireframe = walletWireframe
        withdrawWireframe.rootWireframe = rootWireframe
    }
    
    func paymentDependencies() {
        let paymentPresenter = PaymentPresenter()
        
        let paymentInteractor = PaymentInteractor(apiManager: ApiManager.shared)
        paymentInteractor.output = paymentPresenter
        
        paymentPresenter.interactor = paymentInteractor
        paymentPresenter.wireframe = paymentWireframe
        
        paymentWireframe.presenter = paymentPresenter
        paymentWireframe.txWireframe = txWireframe
        paymentWireframe.paymentQRWireframe = paymentQRWireframe
        paymentWireframe.rootWireframe = rootWireframe
    }
    
    func paymentQRDependencies() {
        let paymentQRPresenter = PaymentQRPresenter()
        
        let paymentQRInteractor = PaymentQRInteractor(apiManager: ApiManager.shared)
        paymentQRInteractor.output = paymentQRPresenter
        
        paymentQRPresenter.interactor = paymentQRInteractor
        paymentQRPresenter.wireframe = paymentQRWireframe
        paymentQRPresenter.delegate = coreWireframe.corePresenter
        
        paymentQRWireframe.presenter = paymentQRPresenter
        paymentQRWireframe.rootWireframe = rootWireframe
    }
    
    func abImportDependencies() {
        let presenter = ABImportPresenter()
        
        let interactor = ABImportInteractor()
        interactor.apiManager = ApiManager.shared
        interactor.output = presenter
        
        presenter.interactor = interactor
        presenter.wireframe = abImportWireframe
        
        abImportWireframe.presenter = presenter
        abImportWireframe.rootWireframe = rootWireframe
        
        abWireframe.abImportWireframe = abImportWireframe
        
        presenter.delegate = abWireframe.abPresenter
    }
    
    func topUpDependencies(signManager: TransactionSignManager) {
        let presenter = TopUpPresenter()
        
        let interactor = TopUpInteractor(apiManager: ApiManager.shared)
        interactor.signManager = signManager
        interactor.output = presenter
        
        presenter.interactor = interactor
        presenter.wireframe = topUpWireframe
        
        topUpWireframe.presenter = presenter
        topUpWireframe.txWireframe = txWireframe
        topUpWireframe.walletWireframe = walletWireframe
        topUpWireframe.txCompletionWireframe = txComWireframe
        topUpWireframe.rootWireframe = rootWireframe
        
        txPresenter.topUpModuleDelegate = presenter
        txComWireframe.txComPresenter?.topUpModuleDelegate = presenter
        
        coreWireframe.topUpWireframe = topUpWireframe
    }
    
    func topUpWithdrawDependencies(signManager: TransactionSignManager) {
        let presenter = TopUpWithdrawPresenter()
        
        let interactor = TopUpWithdrawInteractor()
        interactor.apiManager = ApiManager.shared
        interactor.output = presenter
        interactor.signManager = signManager
        
        presenter.interactor = interactor
        presenter.wireframe = topUpWithdrawWireframe
        
        topUpWithdrawWireframe.presenter = presenter
        topUpWithdrawWireframe.walletWireframe = walletWireframe
        topUpWithdrawWireframe.rootWireframe = rootWireframe
    }
}
