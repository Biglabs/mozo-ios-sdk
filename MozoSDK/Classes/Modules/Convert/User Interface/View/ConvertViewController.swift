//
//  ConvertViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConvertViewController: MozoBasicViewController {
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var amountBorderView: UIView!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var lbSpendable: UILabel!
    @IBOutlet weak var lbGasLimit: UILabel!
    @IBOutlet weak var lbGasPrice: UILabel!
    @IBOutlet weak var sliderGasPrice: UISlider!
    
    @IBOutlet weak var lbSlow: UILabel!
    @IBOutlet weak var lbNormal: UILabel!
    @IBOutlet weak var lbFast: UILabel!
    @IBOutlet weak var lbExplain: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var spendableTopConstraint: NSLayoutConstraint!
    
    var eventHandler: ConvertModuleInterface?
    
    var selectedGasPriceInGWEI = NSNumber(value: 3)
    
    var onchainInfo: OnchainInfoDTO?
    
    var gasPrice: GasPriceDTO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTarget()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Convert To Offchain".localized
    }
    
    func loadInitialData() {
        eventHandler?.loadEthAndOnchainInfo()
        eventHandler?.loadGasPrice()
    }
    
    func setupLayout() {
        btnContinue.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
        
        let string = "Gas Price is the amount you pay per unit of gas. TX fee = Gas Used by Txn * Gas Price & is paid to miners for including your TX in a block. Higher the gas price = faster transaction, but more expensive. Default is 41 GWEI.".localized as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0)])
        
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "TX fee = gas price * gas limit"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "41 GWEI."))
        
        lbExplain.attributedText = attributedString
    }
    
    func setupTarget() {
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidBeginEditing), for: UIControlEvents.editingDidBegin)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidEndEditing), for: UIControlEvents.editingDidEnd)
        txtAmount.delegate = self
    }
    
    func updateOnchainInfoData() {
        if let onchainInfo = self.onchainInfo, let oTokenInfo = onchainInfo.balanceOfToken, let balance = oTokenInfo.balance {
            let onchainSpendable = balance.convertOutputValue(decimal: oTokenInfo.decimals ?? 0)
            lbSpendable.text = onchainSpendable.roundAndAddCommas(toPlaces: oTokenInfo.decimals ?? 0)
        }
    }
    
    func updateGasPriceData() {
        if let gasPrice = self.gasPrice {
            sliderGasPrice.minimumValue = gasPrice.low?.floatValue ?? 2
            sliderGasPrice.maximumValue = gasPrice.fast?.floatValue ?? 5
            if gasPrice.low == gasPrice.average || gasPrice.average == gasPrice.fast {
                lbNormal.isHidden = true
            }
            lbGasLimit.text = gasPrice.gasLimit?.intValue.addCommas()
            selectedGasPriceInGWEI = gasPrice.average ?? NSNumber(value: 0)
            lbGasPrice.text = selectedGasPriceInGWEI.addCommas()
            sliderGasPrice.value = gasPrice.average?.floatValue ?? 0
            updateLabels()
        }
    }
    
    func updateLabels() {
        if let gasPrice = self.gasPrice {
            // Special case
            if selectedGasPriceInGWEI.compare(gasPrice.low ?? NSNumber(value: 0)) == .orderedSame {
                hightLightLabel(lbSlow)
            } else if selectedGasPriceInGWEI.compare(gasPrice.average ?? NSNumber(value: 0)) == .orderedAscending {
                hightLightLabel(lbSlow)
            } else if selectedGasPriceInGWEI.compare(gasPrice.average ?? NSNumber(value: 0)) == .orderedSame {
                hightLightLabel(lbNormal)
            } else {
                hightLightLabel(lbFast)
            }
        }
    }
    
    func hightLightLabel(_ label: UILabel) {
        let highFont = UIFont.boldSystemFont(ofSize: 13)
        let disableFont = UIFont.systemFont(ofSize: 13)
        if label == lbSlow {
            lbNormal.isHighlighted = false
            lbFast.isHighlighted = false
            lbNormal.font = disableFont
            lbFast.font = disableFont
        } else if label == lbNormal {
            lbSlow.isHighlighted = false
            lbFast.isHighlighted = false
            lbSlow.font = disableFont
            lbFast.font = disableFont
        } else {
            lbNormal.isHighlighted = false
            lbSlow.isHighlighted = false
            lbNormal.font = disableFont
            lbSlow.font = disableFont
        }
        label.isHighlighted = true
        label.font = highFont
    }
    
    @objc func textFieldAmountDidEndEditing() {
        print("TextFieldAddressDidEndEditing")
        setHighlightAmountTextField(isHighlighted: false)
    }
    
    @objc func textFieldAmountDidBeginEditing() {
        print("TextFieldAddressDidBeginEditing")
        setHighlightAmountTextField(isHighlighted: true)
    }
    
    func setHighlightAmountTextField(isHighlighted: Bool) {
        lbAmount.isHighlighted = isHighlighted
        amountBorderView.backgroundColor = isHighlighted ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    func showAmountValidate(errorText: String) {
        print("Show validate error, error text: \(errorText)")
        lbError.isHidden = false
        lbError.text = errorText
        lbAmount.textColor = ThemeManager.shared.error
        amountBorderView.backgroundColor = ThemeManager.shared.error
        spendableTopConstraint.constant = 12 + 14
    }
    
    func hideAmountValidate() {
        lbAmount.textColor = ThemeManager.shared.textContent
        amountBorderView.backgroundColor = ThemeManager.shared.disable
        lbError.isHidden = true
        spendableTopConstraint.constant = 12
    }
    
    func checkDisableButtonContinue(_ text: String = "") {
        if !text.isEmpty, let value = Double(text.replace(",", withString: ".")), value > 0 {
            btnContinue.isUserInteractionEnabled = true
            btnContinue.backgroundColor = ThemeManager.shared.main
        } else {
            btnContinue.isUserInteractionEnabled = false
            btnContinue.backgroundColor = ThemeManager.shared.disable
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        selectedGasPriceInGWEI = NSNumber(value: Int(sliderGasPrice.value))
        lbGasPrice.text = selectedGasPriceInGWEI.addCommas()
        updateLabels()
    }
    
    @IBAction func touchReadMore(_ sender: Any) {
        eventHandler?.openReadMore()
    }
    
    @IBAction func touchContinue(_ sender: Any) {
        if let onchainInfo = self.onchainInfo, let gasPrice = self.gasPrice, let gasLimit = gasPrice.gasLimit, let amountText = txtAmount.text, selectedGasPriceInGWEI.compare(NSNumber(value: 0)) == .orderedDescending {
            eventHandler?.validateTxConvert(onchainInfo: onchainInfo, amount: amountText, gasPrice: selectedGasPriceInGWEI, gasLimit: gasLimit)
        } else {
            displayMozoPopupError(.systemError)
        }
    }
}
extension ConvertViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if newLength > MAXIMUM_MOZOX_AMOUNT_TEXT_LENGTH {
            return false
        }
        // Validate decimal format
        let finalText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if finalText.isEmpty == false {
            if (finalText.isValidDecimalFormat() == false) {
                showAmountValidate(errorText: "Error: Please input value in decimal format.".localized)
                return false
            } else if let value = Decimal(string: finalText), value.significantFractionalDecimalDigits > onchainInfo?.balanceOfToken?.decimals ?? 0 {
                print("Digits: \(value)")
                showAmountValidate(errorText: "Error".localized + ": " + "The length of decimal places must be equal or smaller than %d".localizedFormat(onchainInfo?.balanceOfToken?.decimals ?? 0))
                return false
            }
        }
        hideAmountValidate()
        checkDisableButtonContinue(finalText)
        return true
    }
}
extension ConvertViewController: ConvertViewInterface {
    func didReceiveOnchainInfo(_ onchainInfo: OnchainInfoDTO) {
        self.onchainInfo = onchainInfo
        updateOnchainInfoData()
    }
    
    func didReceiceGasPrice(_ gasPrice: GasPriceDTO) {
        self.gasPrice = gasPrice
        updateGasPriceData()
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
}
