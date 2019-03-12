//
//  ConvertCompletionViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class ConvertCompletionViewController: MozoBasicViewController {
    @IBOutlet weak var lbDes: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    @IBOutlet weak var btnHash: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var eventHandler: ConvertCompletionModuleInterface?
    var transaction: IntermediaryTransactionDTO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Convert To Offchain".localized
<<<<<<< HEAD
        navigationItem.rightBarButtonItem = nil
=======
>>>>>>> SDK_Version_1.3
    }
    
    func setupLayout() {
        btnBack.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
    }
    
    func updateData() {
        if let onchainInfo = SessionStoreManager.onchainInfo, let tokenInfo = onchainInfo.balanceOfToken, let tx = transaction {
            btnHash.setTitle(tx.tx?.hash, for: .normal)
            let amount = tx.tx?.outputs![0].value?.convertOutputValue(decimal: tokenInfo.decimals ?? 0) ?? 0
            lbAmount.text = amount.roundAndAddCommas(toPlaces: tokenInfo.decimals ?? 0)
            
            var result = "0.0"
            if let rateInfo = SessionStoreManager.exchangeRateInfo {
                let type = CurrencyType(rawValue: rateInfo.currency?.uppercased() ?? "")
                if let type = type, let rateValue = rateInfo.rate, let curSymbol = rateInfo.currencySymbol {
                    let valueText = (amount * rateValue).roundAndAddCommas(toPlaces: type.decimalRound)
                    result = "\(curSymbol)\(valueText)"
                }
            }
            lbAmountEx.text = result
        }
    }
    
    func handleBackToOnchainWallet() {
        if let navigationController = self.navigationController as? MozoNavigationController, let coreEventHandler = navigationController.coreEventHandler {
            coreEventHandler.requestForCloseAllMozoUIs()
        }
    }
    
    @IBAction func touchHash(_ sender: Any) {
        if let hash = btnHash.titleLabel?.text {
            eventHandler?.handleViewHash(hash)
        }
    }
    
    @IBAction func touchBack(_ sender: Any) {
        handleBackToOnchainWallet()
    }
}
