//
//  TopUpTransferViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation
import UIKit

class TopUpTransferViewController: MozoBasicViewController {
    var eventHandler : TopUpModuleInterface?
    @IBOutlet weak var lbReceiverAddress: UILabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lbExchangeAmount: UILabel!
    @IBOutlet weak var amountBorderView: UIView!
    @IBOutlet weak var lbValidateAmountError: UILabel!
    
    @IBOutlet weak var spendableView: UIView!
    
    @IBOutlet weak var lbSpendable: UILabel!
    
    @IBOutlet weak var alertContainerView: UIView!
    @IBOutlet weak var alertImageView: UIImageView!
    
    @IBOutlet weak var containerGetTokenView: UIView!
    @IBOutlet weak var btnGetToken: UIButton!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    private let refreshControl = UIRefreshControl()
    var tokenInfo : TokenInfoDTO?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        updateLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onBalanceDidUpdate(_:)), name: .didChangeBalance, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Deposit".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel".localized,
            style: UIBarButtonItem.Style.plain,
            target: self, action: #selector(self.tapCancelBtn)
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateLayout() {
        addressBookView.btnClear.isHidden = true
        addressBookView.addressBook = AddressBookDisplayItem.TopUpAddressBookDisplayItem
        addDoneButtonOnKeyboard()
        setupTarget()
        containerGetTokenView.isHidden = true
    }
    
    func loadData() {
        eventHandler?.loadTokenInfo()
        eventHandler?.loadTopUpAddress()
    }
    
    func setupTarget() {
        // Add a "textFieldDidChange" notification method to the text field control.
        
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidChange), for: UIControl.Event.editingChanged)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidBeginEditing), for: UIControl.Event.editingDidBegin)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidEndEditing), for: UIControl.Event.editingDidEnd)
        txtAmount.delegate = self
    }
    
    @objc func onBalanceDidUpdate(_ notification: Notification){
        print("TopUpTransferViewController - On Balance Did Update: Update only balance")
        if let data = notification.userInfo as? [String : Any?] {
            let balance = data["balance"] as! Double
            lbSpendable.text = balance.roundAndAddCommas()
            tokenInfo?.balance = balance.convertTokenValue(decimal: tokenInfo?.decimals ?? 0)
            updateAlertView(balance: balance)
        }
    }
    
    func updateAlertView(balance: Double) {
        let notEmpty = balance > 0
        alertContainerView.isHidden = notEmpty
    }
    
    func addDoneButtonOnKeyboard() {
        self.txtAmount.doneAccessory = true
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
    
    func setHighlightAddressTextField(isHighlighted: Bool) {
        lbReceiverAddress.isHighlighted = isHighlighted
    }
    
    func setHighlightAmountTextField(isHighlighted: Bool) {
        lbAmount.isHighlighted = isHighlighted
        amountBorderView.backgroundColor = isHighlighted ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    // MARK: Validation
    
    @objc func textFieldAmountDidChange() {
        print("TopUpTransferViewController - TextFieldAmountDidChange")
        
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
        lbExchangeAmount.text = DisplayUtils.getExchangeTextFromAmount(value)
    }
    
    @objc func textFieldAmountDidEndEditing() {
        print("TopUpTransferViewController - TextFieldAddressDidEndEditing")
        setHighlightAmountTextField(isHighlighted: false)
    }
    
    @objc func textFieldAmountDidBeginEditing() {
        print("TopUpTransferViewController - TextFieldAddressDidBeginEditing")
        setHighlightAmountTextField(isHighlighted: true)
    }
    
    func showValidate(_ error: String) {
        print("TopUpTransferViewController - Show validate error")
        lbValidateAmountError.text = error.localized
        lbAmount.textColor = ThemeManager.shared.error
        amountBorderView.backgroundColor = ThemeManager.shared.error
        lbValidateAmountError.isHidden = false
        spendableView.isHidden = true
    }
    
    func hideValidate() {
        lbAmount.textColor = ThemeManager.shared.textContent
        amountBorderView.backgroundColor = ThemeManager.shared.disable
        lbValidateAmountError.isHidden = true
        spendableView.isHidden = false
    }
    
    @IBAction func btnContinueTapped(_ sender: Any) {
        if let tokenInfo = self.tokenInfo, let clearAmountText = txtAmount.text {
            eventHandler?.validateTopUpTransferTransaction(tokenInfo: tokenInfo, amount: clearAmountText)
        }
    }
    
    @IBAction func btnGetTokenTapped(_ sender: Any) {
        eventHandler?.requestGetToken()
    }
    
    @objc func tapCancelBtn() {
        eventHandler?.dismiss()
    }
}
extension TopUpTransferViewController : TopUpTransferViewInterface {
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
    
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
        let balance = tokenInfo.balance ?? 0
        let displayBalance = balance.convertOutputValue(decimal: tokenInfo.decimals ?? 0)
        
        lbSpendable.text = "\(displayBalance.roundAndAddCommas())"
        updateAlertView(balance: displayBalance)
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func showErrorValidation(_ error: String) {
        showValidate(error)
    }
    
    func hideErrorValidation() {
        hideValidate()
    }
}

extension TopUpTransferViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if newLength > MAXIMUM_MOZOX_AMOUNT_TEXT_LENGTH {
            return false
        }
        // Validate decimal format
        let finalText = (textField.text ?? "") + string
        if (finalText.isValidDecimalFormat() == false) {
            showValidate("Error: Please input value in decimal format.".localized)
            return false
        } else if let value = Decimal(string: finalText.toTextNumberWithoutGrouping()), value.significantFractionalDecimalDigits > tokenInfo?.decimals ?? 0 {
            print("TopUpTransferViewController - Digits: \(value)")
            showValidate("Error".localized + ": " + "The length of decimal places must be equal or smaller than %d".localizedFormat(tokenInfo?.decimals ?? 0))
            return false
        }
        hideValidate()
        return true
    }
}
