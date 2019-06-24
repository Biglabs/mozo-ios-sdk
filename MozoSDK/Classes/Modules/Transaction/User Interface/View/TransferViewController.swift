//
//  TransferViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation
import UIKit
let MAXIMUM_MOZOX_AMOUNT_TEXT_LENGTH = 12
class TransferViewController: MozoBasicViewController {
    var eventHandler : TransactionModuleInterface?
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbExchange: UILabel!
    @IBOutlet weak var lbReceiverAddress: UILabel!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var lbValidateAddrError: UILabel!
    @IBOutlet weak var btnAddressBook: UIButton!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var addressBorderView: UIView!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lbValidateAmountError: UILabel!
    @IBOutlet weak var lbExchangeAmount: UILabel!
    @IBOutlet weak var amountBorderView: UIView!
    @IBOutlet weak var spendableView: UIView!
    @IBOutlet weak var lbSpendable: UILabel!
    @IBOutlet weak var addressBookView: UIView!
    @IBOutlet weak var lbAbName: UILabel!
    @IBOutlet weak var lbAbAddress: CopyableLabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var constraintTopSpace: NSLayoutConstraint!
    let topSpace : CGFloat = 14.0
    
    private let refreshControl = UIRefreshControl()
    var tokenInfo : TokenInfoDTO?
    var displayContactItem: AddressBookDisplayItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler?.loadTokenInfo()
        addDoneButtonOnKeyboard()
        
        // Add a "textFieldDidChange" notification method to the text field control.
        txtAddress.addTarget(self, action: #selector(textFieldAddressDidChange), for: UIControlEvents.editingChanged)
        txtAddress.addTarget(self, action: #selector(textFieldAddressDidBeginEditing), for: UIControlEvents.editingDidBegin)
        txtAddress.addTarget(self, action: #selector(textFieldAddressDidEndEditing), for: UIControlEvents.editingDidEnd)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidChange), for: UIControlEvents.editingChanged)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidBeginEditing), for: UIControlEvents.editingDidBegin)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidEndEditing), for: UIControlEvents.editingDidEnd)
        txtAmount.delegate = self
        
        if Locale.current.languageCode == "en" {
            let attribute = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]
            txtAddress.placeholder = ""
            txtAddress.attributedPlaceholder = NSAttributedString(string:"Please enter address or select from address book.".localized, attributes: attribute)
        }
        // Observer balance changed notification
        NotificationCenter.default.addObserver(self, selector: #selector(onBalanceDidUpdate(_:)), name: .didChangeBalance, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fix issue: Title is not correct after navigation back from child controller
        navigationItem.title = "Send MozoX".localized
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onBalanceDidUpdate(_ notification: Notification){
        print("Transfer viewcontroller: On Balance Did Update: Update only balance")
        if let data = notification.userInfo as? [String : Any?] {
            let balance = data["balance"] as! Double
            lbSpendable.text = balance.roundAndAddCommas()
            tokenInfo?.balance = balance.convertTokenValue(decimal: tokenInfo?.decimals ?? 0)
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.txtAmount.inputAccessoryView = doneToolbar
        self.txtAddress.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        txtAddress.resignFirstResponder()
        txtAmount.resignFirstResponder()
    }
    
    // MARK: Refresh Control
    func setRefreshControl() {
        view.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        eventHandler?.loadTokenInfo()
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
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
        hideErrorValidation()
    }
    
    @IBAction func btnContinueTapped(_ sender: Any) {
        if let tokenInfo = self.tokenInfo {
            let receiverAddress = txtAddress.isHidden ? lbAbAddress.text : txtAddress.text
            let clearAmountText = txtAmount.text?.toTextNumberWithoutGrouping()
            eventHandler?.validateTransferTransaction(tokenInfo: tokenInfo, toAdress: receiverAddress, amount: clearAmountText, displayContactItem: txtAddress.isHidden ? displayContactItem : nil)
        }
    }
    
    func clearAndHideAddressBookView() {
        txtAddress.isHidden = false
        btnScan.isHidden = false
        addressBorderView.isHidden = false
        addressBorderView.backgroundColor = txtAddress.isEditing ? ThemeManager.shared.main : ThemeManager.shared.disable
        addressBookView.isHidden = true
        lbAbName.text = ""
        lbAbAddress.text = ""
    }
    
    func setHighlightAddressTextField(isHighlighted: Bool) {
        lbReceiverAddress.isHighlighted = isHighlighted
        addressBorderView.backgroundColor = isHighlighted ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    func setHighlightAmountTextField(isHighlighted: Bool) {
        lbAmount.isHighlighted = isHighlighted
        amountBorderView.backgroundColor = isHighlighted ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    // MARK: Validation
    
    @objc func textFieldAddressDidChange() {
        print("TextFieldAddressDidChange")
        hideValidate(isAddress: true)
    }
    
    @objc func textFieldAddressDidEndEditing() {
        print("TextFieldAddressDidEndEditing")
        setHighlightAddressTextField(isHighlighted: false)
    }
    
    @objc func textFieldAddressDidBeginEditing() {
        print("TextFieldAddressDidBeginEditing")
        setHighlightAddressTextField(isHighlighted: true)
    }
    
    @objc func textFieldAmountDidChange() {
        print("TextFieldAmountDidChange")
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? ""), let curSymbol = rateInfo.currencySymbol {
                let originalText = txtAmount.text ?? "0"
                let text = originalText.toTextNumberWithoutGrouping()
                
                let sendAmount = text.isEmpty ? 0 : NSDecimalNumber(string: text)
                txtAmount.text = sendAmount.addCommas()
                if originalText.hasSuffix(NSLocale.current.decimalSeparator ?? ".") {
                    txtAmount.text = sendAmount.addCommas() + String(originalText.last!)
                } else if originalText.hasSuffix("\(NSLocale.current.decimalSeparator ?? ".")0") {
                    txtAmount.text = sendAmount.addCommas() + String(originalText.suffix(2))
                }
                
                let value = sendAmount.doubleValue
                let exValue = (value * (rateInfo.rate ?? 0)).roundAndAddCommas(toPlaces: type.decimalRound)
                let exValueStr = "\(curSymbol)\(exValue)"
                lbExchangeAmount.text = exValueStr
            }
        } else {
            
        }
    }
    
    @objc func textFieldAmountDidEndEditing() {
        print("TextFieldAddressDidEndEditing")
        setHighlightAmountTextField(isHighlighted: false)
    }
    
    @objc func textFieldAmountDidBeginEditing() {
        print("TextFieldAddressDidBeginEditing")
        setHighlightAmountTextField(isHighlighted: true)
    }
    
    func showValidate(_ error: String?, isAddress: Bool) {
        print("Show validate error, isAddress: \(isAddress)")
        if isAddress {
            lbReceiverAddress.textColor = ThemeManager.shared.error
            addressBorderView.backgroundColor = ThemeManager.shared.error
            let errorText = error ?? "Error: The Receiver Address is not valid.".localized
            lbValidateAddrError.text = errorText
            lbValidateAddrError.isHidden = false
            constraintTopSpace.constant = topSpace + lbValidateAddrError.frame.size.height
        } else {
            lbValidateAmountError.text = (error ?? "").localized
            lbAmount.textColor = ThemeManager.shared.error
            amountBorderView.backgroundColor = ThemeManager.shared.error
            lbValidateAmountError.isHidden = false
            spendableView.isHidden = true
        }
    }
    
    func hideValidate(isAddress: Bool) {
        if isAddress {
            lbReceiverAddress.textColor = ThemeManager.shared.textContent
            amountBorderView.backgroundColor = ThemeManager.shared.disable
            lbValidateAddrError.isHidden = true
            constraintTopSpace.constant = topSpace
        } else {
            lbAmount.textColor = ThemeManager.shared.textContent
            amountBorderView.backgroundColor = ThemeManager.shared.disable
            lbValidateAmountError.isHidden = true
            spendableView.isHidden = false
        }
    }
}
extension TransferViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        print("User try reload balance on transfer screen again.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.loadTokenInfo()
        }
    }
}
extension TransferViewController : TransferViewInterface {
    func displayTryAgain(_ error: ConnectionError) {
        DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
    }
    
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        let balance = tokenInfo.balance ?? 0
        let displayBalance = balance.convertOutputValue(decimal: tokenInfo.decimals ?? 0)
        
        lbSpendable.text = "\(displayBalance.roundAndAddCommas())"
    }
    
    func updateUserInterfaceWithAddress(_ address: String) {
        
        clearAndHideAddressBookView()
        txtAddress.text = address
        hideValidate(isAddress: true)
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func updateInterfaceWithDisplayItem(_ displayItem: AddressBookDisplayItem) {
        hideValidate(isAddress: true)
        txtAddress.isHidden = true
        btnScan.isHidden = true
        addressBorderView.isHidden = true
        addressBookView.isHidden = false
        lbAbName.text = displayItem.name
        lbAbAddress.text = displayItem.address
        self.displayContactItem = displayItem
    }
    
    func showErrorValidation(_ error: String?, isAddress: Bool) {
        showValidate(error, isAddress: isAddress)
    }
    
    func hideErrorValidation() {
        hideValidate(isAddress: true)
        hideValidate(isAddress: false)
    }
}

extension TransferViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if newLength > MAXIMUM_MOZOX_AMOUNT_TEXT_LENGTH {
            return false
        }
        // Validate decimal format
        let finalText = (textField.text ?? "") + string
        if (finalText.isValidDecimalFormat() == false) {
            showValidate("Error: Please input value in decimal format.".localized, isAddress: false)
            return false
        } else if let value = Decimal(string: finalText.toTextNumberWithoutGrouping()), value.significantFractionalDecimalDigits > tokenInfo?.decimals ?? 0 {
            print("Digits: \(value)")
            showValidate("Error".localized + ": " + "The length of decimal places must be equal or smaller than %d".localizedFormat(tokenInfo?.decimals ?? 0), isAddress: false)
            return false
        }
        hideValidate(isAddress: false)
        return true
    }
}
