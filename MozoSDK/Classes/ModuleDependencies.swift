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
    // MARK: - Properties
    
    public var apiKey: String {
        didSet {
            // Call API to check key
            apiManager.apiKey = apiKey
        }
    }
    
    public var network: MozoNetwork = .TestNet {
        didSet {
           
        }
    }
    
    public var appType: AppType = .Shopper {
        didSet {
            webSocketManager.appType = appType
        }
    }
    
    let coreDataStore = CoreDataStore()
    let rootWireframe = RootWireframe()
    
    let coreWireframe = CoreWireframe()
    let walletWireframe = WalletWireframe()
    let authWireframe = AuthWireframe()
    let txWireframe = TransactionWireframe()
    let txhWireframe = TxHistoryWireframe()
    let txComWireframe = TxCompletionWireframe()
    let txDetailWireframe = TxDetailWireframe()
    let abDetailWireframe = ABDetailWireframe()
    let abWireframe = AddressBookWireframe()
    let adWireframe = AirdropWireframe()
    let addWireframe = AirdropAddWireframe()
    let paymentWireframe = PaymentWireframe()
    let paymentQRWireframe = PaymentQRWireframe()
    
    let apiManager = ApiManager()
    let webSocketManager = WebSocketManager()
    
    // MARK: Initialization
    init() {
        apiKey = ""
        configureDependencies()
    }
    
    func setAuthDelegate(_ delegate: AuthenticationDelegate) {
        coreWireframe.corePresenter?.authDelegate = delegate
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
    
    func displayTransactionDetail(txHistory: TxHistoryDisplayItem, tokenInfo: TokenInfoDTO) {
        coreWireframe.requestForTransactionDetail(txHistory: txHistory, tokenInfo: tokenInfo)
    }
    
    func loadBalanceInfo() -> Promise<DetailInfoDisplayItem>{
        return (coreWireframe.corePresenter?.coreInteractorService?.loadBalanceInfo())!
    }
    
    func registerBeacon(parameters: Any?) -> Promise<[String: Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.registerBeacon(parameters:parameters))!
    }
    
    func updateBeaconSettings(parameters: Any?) -> Promise<[String: Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.updateBeaconSettings(parameters:parameters))!
    }
    
    func getListBeacons() -> Promise<[String : Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getListBeacons())!
    }
    
    func getRetailerInfo() -> Promise<[String : Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRetailerInfo())!
    }
    
    func addRetailerSalePerson(parameters: Any?) -> Promise<[String: Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.addSalePerson(parameters:parameters))!
    }
    
    func getAirdropStoreNearby(params: [String: Any]) -> Promise<[StoreInfoDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getAirdropStoreNearby(params: params))!
    }
    
    func sendRangedBeacons(beacons: [BeaconInfoDTO], status: Bool) -> Promise<[String : Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.sendRangedBeacons(beacons: beacons, status: status))!
    }
    
    func getRangeColorSettings() -> Promise<[AirdropColorRangeDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRangeColorSettings())!
    }
    
    func getTxHistoryDisplayCollection() -> Promise<TxHistoryDisplayCollection> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getTxHistoryDisplayCollection())!
    }
    
    func createAirdropEvent(event: AirdropEventDTO, delegate: AirdropEventDelegate) {
        adWireframe.requestCreateAndSignAirdropEvent(event, delegate: delegate)
    }
    
    func addMoreMozoToAirdropEvent(event: AirdropEventDTO, delegate: AirdropAddEventDelegate) {
        addWireframe.requestToAddMoreAndSign(event, delegate: delegate)
    }
    
    func getLatestAirdropEvent() -> Promise<AirdropEventDTO> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getLatestAirdropEvent())!
    }
    
    func getAirdropEventList(page: Int) -> Promise<[AirdropEventDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getAirdropEventList(page: page))!
    }
    
    func getRetailerAnalyticHome() -> Promise<RetailerAnalyticsHomeDTO?> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRetailerAnalyticHome())!
    }
    
    func getRetailerAnalyticList() -> Promise<[RetailerCustomerAnalyticDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRetailerAnalyticList())!
    }
    
    func getVisitCustomerList(page: Int, size: Int, year: Int, month: Int) -> Promise<[VisitedCustomerDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getVisitCustomerList(page: page, size: size, year: year, month: month))!
    }
    
    func getRetailerAnalyticAmountAirdropList(page: Int, size: Int, year: Int, month: Int) -> Promise<[AirDropReportDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRetailerAnalyticAmountAirdropList(page: page, size: size, year: year, month: month))!
    }
    
    func getRunningAirdropEvents(page: Int, size: Int) -> Promise<[AirdropEventDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getRunningAirdropEvents(page: page, size: size))!
    }
    
    func getListSalePerson() -> Promise<[SalePersonDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getListSalePerson())!
    }
    
    func removeSalePerson(id: Int64) -> Promise<[String: Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.removeSalePerson(id: id))!
    }
    
    func getListCountryCode() -> Promise<[CountryCodeDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getListCountryCode())!
    }
    
    func getNearestStores(_ storeId: Int64) -> Promise<[StoreInfoDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getNearestStores(storeId))!
    }
    
    func getListEventAirdropOfStore(_ storeId: Int64) -> Promise<[StoreInfoDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getListEventAirdropOfStore(storeId))!
    }
    
    func searchStoresWithText(_ text: String, page: Int, size: Int, long: Double, lat: Double, sort: String) -> Promise<CollectionStoreInfoDTO> {
        return (coreWireframe.corePresenter?.coreInteractorService?.searchStoresWithText(text, page: page, size: size, long: long, lat: lat, sort: sort))!
    }
    
    func getFavoriteStores() -> Promise<[StoreInfoDTO]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getFavoriteStores())!
    }
    
    func updateFavoriteStore(_ storeId: Int64, isMarkFavorite: Bool) -> Promise<[String: Any]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.updateFavoriteStore(storeId, isMarkFavorite: isMarkFavorite))!
    }
    
    func getTodayCollectedAmount(startTime: Int, endTime: Int) -> Promise<NSNumber> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getTodayCollectedAmount(startTime: startTime, endTime: endTime))!
    }
    
    func getUrlToUploadImage() -> Promise<String> {
        return (coreWireframe.corePresenter?.coreInteractorService?.getUrlToUploadImage())!
    }
    
    func uploadImage(images: [UIImage], url: String) -> Promise<[String]> {
        return (coreWireframe.corePresenter?.coreInteractorService?.uploadImage(images: images, url: url))!
    }
    
    func configureDependencies() {
        // MARK: Core
        coreDependencies()
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
    }
    
    func coreDependencies() {
        let corePresenter = CorePresenter()
        
        let anonManager = AnonManager()
        anonManager.apiManager = apiManager
        let userDataManager = UserDataManager()
        userDataManager.coreDataStore = coreDataStore
        
        let coreInteractor = CoreInteractor(anonManager: anonManager, apiManager: apiManager, userDataManager: userDataManager)
        coreInteractor.output = corePresenter
        
        let rdnInteractor = RDNInteractor(webSocketManager: webSocketManager)
        rdnInteractor.output = corePresenter
        
        corePresenter.coreInteractor = coreInteractor
        corePresenter.rdnInteractor = rdnInteractor
        corePresenter.coreInteractorService = coreInteractor
        corePresenter.coreWireframe = coreWireframe
        
        rootWireframe.mozoNavigationController.coreEventHandler = corePresenter
        
        coreWireframe.corePresenter = corePresenter
        coreWireframe.authWireframe = authWireframe
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
    }
    
    func addressBookDetailDependencies() {
        let abdPresenter = ABDetailPresenter()
        
        let abdInteractor = ABDetailInteractor()
        abdInteractor.apiManager = apiManager
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
        
        txDetailWireframe.txDetailPresenter = txDetailPresenter
        txDetailWireframe.rootWireframe = rootWireframe
    }
    
    func transactionCompletionDependencies() {
        let txComPresenter = TxCompletionPresenter()
        
        let txComInteractor = TxCompletionInteractor(apiManager: apiManager)
        txComInteractor.output = txComPresenter
        
        txComPresenter.completionInteractor = txComInteractor
        txComPresenter.completionModuleDelegate = coreWireframe.corePresenter
        
        txComWireframe.txComPresenter = txComPresenter
        txComWireframe.rootWireframe = rootWireframe
    }
    
    func transactionHistoryDependencies() {
        let txhPresenter = TxHistoryPresenter()
        
        let txhInteractor = TxHistoryInteractor(apiManager: apiManager)
        txhInteractor.output = txhPresenter
        
        txhPresenter.txhInteractor = txhInteractor
        txhPresenter.txhWireframe = txhWireframe
        txhPresenter.txhModuleDelegate = coreWireframe.corePresenter
        
        txhWireframe.txhPresenter = txhPresenter
        txhWireframe.rootWireframe = rootWireframe
    }
    
    func transactionDependencies() {
        let txPresenter = TransactionPresenter()
        
        let txInteractor = TransactionInteractor(apiManager: apiManager)
        txInteractor.output = txPresenter
        
        let txDataManager = TransactionDataManager()
        txDataManager.coreDataStore = coreDataStore
        let signManager = TransactionSignManager(dataManager: txDataManager)
        txInteractor.signManager = signManager
        
        txPresenter.txInteractor = txInteractor
        txPresenter.txWireframe = txWireframe
        txPresenter.transactionModuleDelegate = coreWireframe.corePresenter
        
        txWireframe.txPresenter = txPresenter
        txWireframe.rootWireframe = rootWireframe
        
        airdropDependencies(signManager: signManager)
        airdropAddDependencies(signManager: signManager)
    }
    
    func authDependencies() {
        let authPresenter = AuthPresenter()
        
        let authManager = AuthManager()
        authManager.apiManager = apiManager
        let authInteractor = AuthInteractor(authManager: authManager)
        authInteractor.output = authPresenter
        
        authPresenter.authInteractor = authInteractor
        authPresenter.authWireframe = authWireframe
        authPresenter.authModuleDelegate = coreWireframe.corePresenter
        
        authWireframe.authPresenter = authPresenter
        authWireframe.rootWireframe = rootWireframe
    }
    
    func walletDependencies() {
        let walletPresenter = WalletPresenter()
        
        let walletManager = WalletManager()
        let walletDataManager = WalletDataManager()
        walletDataManager.coreDataStore = coreDataStore
        
        let walletInteractor = WalletInteractor(walletManager: walletManager, dataManager: walletDataManager, apiManager: apiManager)
        walletInteractor.output = walletPresenter
        
        walletPresenter.walletInteractor = walletInteractor
        walletPresenter.walletWireframe = walletWireframe
        walletPresenter.walletModuleDelegate = coreWireframe.corePresenter
        
        walletWireframe.walletPresenter = walletPresenter
        walletWireframe.rootWireframe = rootWireframe
    }
    
    func airdropDependencies(signManager: TransactionSignManager) {
        let adPresenter = AirdropPresenter()
        
        let adInteractor = AirdropInteractor()
        adInteractor.apiManager = apiManager
        adInteractor.output = adPresenter
        adInteractor.signManager = signManager
        
        adPresenter.interactor = adInteractor
        adPresenter.wireframe = adWireframe
        
        adWireframe.adPresenter = adPresenter
        adWireframe.walletWireframe = walletWireframe
    }
    
    func airdropAddDependencies(signManager: TransactionSignManager) {
        let addPresenter = AirdropAddPresenter()
        
        let addInteractor = AirdropAddInteractor()
        addInteractor.apiManager = apiManager
        addInteractor.output = addPresenter
        addInteractor.signManager = signManager
        
        addPresenter.interactor = addInteractor
        addPresenter.wireframe = addWireframe
        
        addWireframe.addPresenter = addPresenter
        addWireframe.walletWireframe = walletWireframe
    }
    
    func paymentDependencies() {
        let paymentPresenter = PaymentPresenter()
        
        let paymentInteractor = PaymentInteractor(apiManager: apiManager)
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
        
        let paymentQRInteractor = PaymentQRInteractor(apiManager: apiManager)
        paymentQRInteractor.output = paymentQRPresenter
        
        paymentQRPresenter.interactor = paymentQRInteractor
        paymentQRPresenter.wireframe = paymentQRWireframe
        paymentQRPresenter.delegate = coreWireframe.corePresenter
        
        paymentQRWireframe.presenter = paymentQRPresenter
        paymentQRWireframe.rootWireframe = rootWireframe
    }
    
    
    
    
    
    // MARK: TEST
    func testSign() {
        let tosign = "3e7c8671c98af65e4f957d0843a15ce0616a0624cc5fbc3e6f72b7871f118ac1"
        let privatekey = "b7643ad0c07b2f2a1232fc4d276c5554e05fa1c8fddb2aed738c7ae0526f5350"
        let result = "30440220742c8b23491f5560804bcb884cf1866a14598562819afe5fadd8c56a50c26fe5022030d2a9fe32c7f99a4f4adeb62442a360cdc2178f49f7f2907325c470a1d14d59"
        
        let signR : String? = tosign.ethSign(privateKey: privatekey)
        print("Sign result: \(signR)")
        
        let ts = "52204d20fd0131ae1afd173fd80a3a746d2dcc0cddced8c9dc3d61cc7ab6e966"
        let pk = "16f243e962c59e71e54189e67e66cf2440a1334514c09c00ddcc21632bac9808"
        let rs = "304402204019e4c591580b2a626beef77f92f21fb30e9c201c6a01ed6e7e6dcbf788ff56022074ae76e4f47a3c23dbaa930994a4f98c2cc1e03cb39c73fd8a246c16e2f3d1a8"
        
        let sr : String? = ts.ethSign(privateKey: pk)
        print("Sign result: \(sr)")
    }
    
    func testUpdateProfile() {
        let testStr = "{\"id\":1251,\"userId\":\"bbf400f4-cae1-40fa-88d1-a0faafaf12c9\",\"status\" : \"CONFIRMED\",\"exchangeInfo\" : null,\"walletInfo\" : null,\"settings\" : null}"
        let json = SwiftyJSON.JSON(testStr)
        let profile = UserProfileDTO(json: json)
        let walletInfo = WalletInfoDTO(encryptSeedPhrase: "", offchainAddress: "")
        profile?.walletInfo = walletInfo
        
        _ = apiManager.updateUserProfile(userProfile: profile!)
            .done { uProfile -> Void in
                print("Update Wallet To User Profile result: [\(uProfile)]")
        }
    }
    
    func testSeedAndEncryption(manager: WalletManager) {
        for i in stride(from: 1, to: 11, by: 1) {
            print("\(i)-seed:")
            let mnemonic = manager.generateMnemonics()
            print(mnemonic ?? "")
            print("\(i)-seed encrypted:")
            print(mnemonic?.encrypt(key: "000000") ?? "")
            let wallet = manager.createNewWallet(mnemonics: mnemonic!)
            print("\(i)-privateKey:")
            print(wallet.privateKey)
            print("\(i)-privateKey encrypted:")
            print(wallet.privateKey.encrypt(key: "000000"))
        }
    }
    
    func testLocalData() {
        coreDataStore.getAllUsers()
    }
    
    func testEthAddress() {
        let result = "0x011df24265841dCdbf2e60984BB94007b0C1d76A".isEthAddress()
        print(result)
    }
    
    func testAssests() {
        let img = UIImage(named: "ic_send", in: BundleManager.mozoBundle(), compatibleWith: nil)
        if img != nil {
            print("MOZO - TEST ASSESTS - CAN LOAD IMAGE")
        } else {
            print("MOZO - TEST ASSESTS - CAN NOT LOAD IMAGE")
        }
    }
    
    func testLocalization() {
        print("MozoSDK Localization: \(Locale.current.languageCode ?? "NULL")")
    }
}
