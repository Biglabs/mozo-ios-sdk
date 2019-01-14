//
//  TxDetailViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation
import UIKit

class TxDetailViewController: MozoBasicViewController {
    var eventHandler : TxDetailModuleInterface?
    var displayItem: TxDetailDisplayItem!
    
    //Outlets
    @IBOutlet weak var actionImg: UIImageView!
    @IBOutlet weak var lbTxType: UILabel!
    @IBOutlet weak var lbDateTime: UILabel!
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbBalanceExchange: UILabel!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var lbActionDetailView: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var lbNameDetailView: UILabel!
    @IBOutlet weak var lbAddressDetailView: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbAmountValue: UILabel!
    @IBOutlet weak var lbAmountValueExchange: UILabel!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    
    //Constraints
    @IBOutlet weak var userImgWidthCstr: NSLayoutConstraint!
    @IBOutlet weak var walletAddressTopCstr: NSLayoutConstraint!
    
    let defaultHeight : CGFloat = 28
    let addressBookDetailHeight: CGFloat = 96
    let storeBookDetailHeight: CGFloat = 117
    
    let addressBookImgWidth : CGFloat = 14
    let storeBookImgWidth : CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setBtnBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }
    
    func setBtnBorder() {
        saveBtn.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
    }
    
    func updateView() {
        let imageName = displayItem.action == TransactionType.Sent.value ? "ic_sent_circle" : "ic_received_circle"
        actionImg.image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        lbTxType.text = displayItem.action
        lbDateTime.text = displayItem.dateTime
        
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        
        var displayEnum = TransactionDisplayContactEnum.NoDetail
        if let contactItem = DisplayUtils.buildContactDisplayItem(address: address) {
            let name = contactItem.name
            displayEnum = contactItem.isStoreBook ? .StoreBookDetail : .AddressBookDetail
            if contactItem.isStoreBook {
                lbAddressDetailView.text = contactItem.physicalAddress
            }
            detailView.isHidden = false
            lbActionDetailView.text = displayItem.action == TransactionType.Sent.value ? "To" : "From"
            
            // Change userImg in case the address coming from <Store Book>, including image width and image
            userImg.image = UIImage(named: displayEnum.icon, in: BundleManager.mozoBundle(), compatibleWith: nil)
            userImgWidthCstr.constant = displayEnum == .StoreBookDetail ? storeBookImgWidth : addressBookImgWidth
            
            lbNameDetailView.text = name
            // Set hidden false and set physical address in case the address coming from <Store Book>
            if displayEnum == .StoreBookDetail {
                lbAddressDetailView.isHidden = false
            } else {
                lbAddressDetailView.isHidden = true
            }
        } else {
            detailView.isHidden = true
        }
        
        switch displayEnum {
        case .AddressBookDetail:
            walletAddressTopCstr.constant = addressBookDetailHeight
        case .StoreBookDetail:
            walletAddressTopCstr.constant = storeBookDetailHeight
        default:
            walletAddressTopCstr.constant = defaultHeight
        }
        
        lbAddress.text = address
        let amount = displayItem.amount
        lbAmountValue.text = "\(amount.roundAndAddCommas())"
        var exAmount = "0.0"
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? "") {
                let amountValue = displayItem.exAmount.roundAndAddCommas(toPlaces: type.decimalRound)
                exAmount = "\(type.unit)\(amountValue)"
            }
        }
        lbAmountValueExchange.text = exAmount
        
        saveView.isHidden = displayEnum != .NoDetail
    }
    
    @IBAction func touchedBtnSave(_ sender: Any) {
        let address = displayItem.action == TransactionType.Sent.value ? displayItem.addressTo : displayItem.addressFrom
        eventHandler?.requestAddToAddressBook(address)
    }
}
