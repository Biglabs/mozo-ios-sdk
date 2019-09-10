//
//  PaymentSendSuccessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/7/18.
//

import Foundation
import UIKit
class PaymentSendSuccessViewController: MozoBasicViewController {
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    @IBOutlet weak var lbAddressOrName: CopyableLabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    
    var displayItem: PaymentRequestDisplayItem?
    var toAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Request MozoX".localized
    }
    
    func bindData() {
        if let displayItem = self.displayItem {
            lbAmount.text = displayItem.amount.roundAndAddCommas()
            
            if let rateInfo = SessionStoreManager.exchangeRateInfo {
                if let type = CurrencyType(rawValue: rateInfo.currency ?? ""), let curSymbol = rateInfo.currencySymbol {
                    let exValue = (displayItem.amount * (rateInfo.rate ?? 0)).rounded(toPlaces: type.decimalRound)
                    let exValueStr = "(\(curSymbol)\(exValue))"
                    lbAmountEx.text = exValueStr
                }
            }
            
            if let toAddress = toAddress, let addressBook = DisplayUtils.buildContactDisplayItem(address: toAddress) {
                addressBookView.isHidden = false
                lbAddressOrName.isHidden = true
                addressBookView.addressBook = addressBook
                addressBookView.btnClear.isHidden = true
            } else {
                addressBookView.isHidden = true
                lbAddressOrName.isHidden = false
                lbAddressOrName.text = toAddress
            }
        }
    }
}
