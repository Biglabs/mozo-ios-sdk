//
//  PaymentQRViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
import UIKit
class PaymentQRViewController: MozoBasicViewController {
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var qrImg: UIImageView!
    
    @IBOutlet weak var lbAmountToSend: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var lineAddress: UIView!
    @IBOutlet weak var btnScan: UIButton!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var lbAbName: UILabel!
    @IBOutlet weak var lbAbAddress: CopyableLabel!
    @IBOutlet weak var btnClear: UIButton!
    
    @IBOutlet weak var btnAddressBook: UIButton!
    
    @IBOutlet weak var btnSend: UIButton!
    
    var eventHandler: PaymentQRModuleInterface?
    var displayItem: PaymentRequestDisplayItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        commonSetup()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Request MozoX".localized
    }
    
    func bindData() {
        if let displayItem = self.displayItem {
            let content = displayItem.toScheme()
            let img = DisplayUtils.generateQRCode(from: content)
            qrImg.image = img
            
            lbAmountToSend.text = displayItem.amount.roundAndAddCommas()
            
            if let rateInfo = SessionStoreManager.exchangeRateInfo {
                if let type = CurrencyType(rawValue: rateInfo.currency ?? ""), let curSymbol = rateInfo.currencySymbol {
                    let exValue = (displayItem.amount * (rateInfo.rate ?? 0)).rounded(toPlaces: type.decimalRound)
                    let exValueStr = "(\(curSymbol)\(exValue))"
                    lbAmountEx.text = exValueStr
                }
            }
        }
    }
    
    func commonSetup() {
        imgContainerView.roundCorners(cornerRadius: 0.04, borderColor: ThemeManager.shared.borderInside, borderWidth: 0.8)
        btnSend.roundCorners(cornerRadius: 0.02, borderColor: .white, borderWidth: 0.1)
        txtAddress.doneAccessory = true
        txtAddress.addTarget(self, action: #selector(textFieldAddressDidChange), for: UIControlEvents.editingChanged)
        checkDisableButtonSend()
    }
    
    @objc func textFieldAddressDidChange() {
        print("TextFieldAddressDidChange")
        checkDisableButtonSend(txtAddress.text ?? "")
    }
    
    func checkDisableButtonSend(_ text: String = "") {
        if !text.isEmpty || addressContainerView.isHidden {
            btnSend.isUserInteractionEnabled = true
            btnSend.backgroundColor = ThemeManager.shared.main
        } else {
            btnSend.isUserInteractionEnabled = false
            btnSend.backgroundColor = ThemeManager.shared.disable
        }
    }
    
    // MARK: Button tap events
    @IBAction func btnAddressBookTapped(_ sender: Any) {
        eventHandler?.showAddressBookInterface()
    }
    
    @IBAction func btnScanTapped(_ sender: Any) {
        eventHandler?.showScanQRCodeInterface()
    }
    @IBAction func touchedBtnClear(_ sender: Any) {
        clearAndHideAddressBookView()
        txtAddress.text = ""
        checkDisableButtonSend()
    }
    @IBAction func btnSendTapped(_ sender: Any) {
        if let toAddress = addressContainerView.isHidden ? lbAbAddress.text : txtAddress.text {
            if toAddress.isEthAddress() {
                eventHandler?.sendPaymentRequest(self.displayItem!, toAddress: toAddress)
            } else {
                displayMozoError("Invalid address.")
            }
        } else {
            displayMozoError("Please enter address or select from address book.")
        }
    }
    
    func clearAndHideAddressBookView() {
        addressContainerView.isHidden = false
        nameContainerView.isHidden = true
        lbAbName.text = ""
        lbAbAddress.text = ""
    }
}
extension PaymentQRViewController: PaymentQRViewInterface {
    func updateUserInterfaceWithAddress(_ address: String) {
        clearAndHideAddressBookView()
        txtAddress.text = address
        checkDisableButtonSend(address)
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem) {
        nameContainerView.isHidden = false
        addressContainerView.isHidden = true
        lbAbName.text = displayItem.name
        lbAbAddress.text = displayItem.address
        checkDisableButtonSend()
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
    
    func displaySuccess() {
        displayMozoAlertSuccess {
            self.eventHandler?.close()
        }
    }
}
