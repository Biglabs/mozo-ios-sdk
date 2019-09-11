//
//  PaymentQRViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/6/18.
//

import Foundation
import UIKit
import libPhoneNumber_iOS
class PaymentQRViewController: MozoBasicViewController {
    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var qrImg: UIImageView!
    
    @IBOutlet weak var lbAmountToSend: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var txtAddressOrPhoneNo: UITextField!
    @IBOutlet weak var addressLine: UIView!
    @IBOutlet weak var btnScan: UIButton!
    
    @IBOutlet weak var addressBookView: AddressBookView!
    @IBOutlet weak var abEmptyDropDownView: ABEmptyDropDownView!
    
    @IBOutlet weak var btnAddressBook: UIButton!
    @IBOutlet weak var btnAddressBookTopConstraint: NSLayoutConstraint!
    let topSpace : CGFloat = 51.0
    let topSpaceWithAB: CGFloat = 89
    
    @IBOutlet weak var btnSend: UIButton!
    
    var dropdown = DropDown()
    var filteredCollection = AddressBookDisplayCollection(items: [AddressBookDTO]())
    var countryData = CountryDisplayData(collection: CountryDisplayCollection(items: SessionStoreManager.countryList))
    
    let nbPhoneNumberUtil = NBPhoneNumberUtil()
    
    var displayContactItem: AddressBookDisplayItem? {
        didSet {
            updateAddressBookOnUI()
        }
    }
    
    var eventHandler: PaymentQRModuleInterface?
    var displayItem: PaymentRequestDisplayItem?
    
    override func viewDidLoad() {
        print("PaymentQRViewController - View did load")
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        imgContainerView.roundCorners(cornerRadius: 0.04, borderColor: ThemeManager.shared.borderInside, borderWidth: 0.8)
        btnSend.roundCorners(cornerRadius: 0.02, borderColor: .white, borderWidth: 0.1)
        
        txtAddressOrPhoneNo.addDoneButtonOnKeyboard()
        txtAddressOrPhoneNo.addTarget(self, action: #selector(textFieldAddressDidChange), for: .editingChanged)
        txtAddressOrPhoneNo.addTarget(self, action: #selector(textFieldAddressDidBeginEditing), for: .editingDidBegin)
        txtAddressOrPhoneNo.addTarget(self, action: #selector(textFieldAddressDidEndEditing), for: .editingDidEnd)
        
        checkDisableButtonSend()
        setupDropdown()
        setupAddressBook()
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonActionForAddressOrPhone))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.txtAddressOrPhoneNo.doneAccessory = true
    }
    
    @objc func doneButtonActionForAddressOrPhone() {
        txtAddressOrPhoneNo.resignFirstResponder()
        
        // Auto check input. If input is phone number, auto find contact in MozoX
        validatePhoneNoAfterFinding()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func textFieldAddressDidChange() {
        print("PaymentQRViewController - TextFieldAddressDidChange")
        checkDisableButtonSend(txtAddressOrPhoneNo.text ?? "")
        updateDropDownDataSource()
    }
    
    @objc func textFieldAddressDidEndEditing() {
        print("PaymentQRViewController - TextFieldAddressDidEndEditing")
        // Hide dropdown and abDropDownEmptyView (if any)
        abEmptyDropDownView.isHidden = true
        dropdown.hide()
    }
    
    @objc func textFieldAddressDidBeginEditing() {
        print("PaymentQRViewController - TextFieldAddressDidBeginEditing")
        updateDropDownDataSource()
    }
    
    func checkDisableButtonSend(_ text: String = "") {
        if !text.isEmpty || displayContactItem != nil {
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
    
    @IBAction func btnSendTapped(_ sender: Any) {
        abEmptyDropDownView.isHidden = true
        dropdown.hide()
        if let toAddress = displayContactItem?.address ?? txtAddressOrPhoneNo.text {
            if toAddress.isEthAddress() {
                eventHandler?.sendPaymentRequest(self.displayItem!, toAddress: toAddress)
            } else {
                displayMozoError("The Receiver Address is not valid.")
            }
        } else {
            displayMozoError("Please enter address or select from address book.")
        }
    }
}
extension PaymentQRViewController: PaymentQRViewInterface {
    func updateUserInterfaceWithAddress(_ address: String) {
        addressContainerView.isHidden = false
        addressBookView.isHidden = true
        abEmptyDropDownView.isHidden = true
        txtAddressOrPhoneNo.text = address
        
        displayContactItem = nil
        // Fix issue: Enable button Send after filling in address text field
        checkDisableButtonSend(address)
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem) {
        self.displayContactItem = displayItem
        if abEmptyDropDownView.isHidden == false {
            abEmptyDropDownView.isHidden = true
        }
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
