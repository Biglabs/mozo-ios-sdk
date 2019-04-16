//
//  ConvertViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConvertViewController: MozoBasicViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ethContainerView: UIView!
    @IBOutlet weak var ethBalanceLb: UILabel!
    @IBOutlet weak var ethNeedLb: UILabel!
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var iconMozoOffchain: UIImageView!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var amountBorderView: UIView!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var lbSpendableTitle: UILabel!
    @IBOutlet weak var lbSpendable: UILabel!
    @IBOutlet weak var lbSpendableTrail: UILabel!
    @IBOutlet weak var lbGasLimit: UILabel!
    @IBOutlet weak var lbGasPrice: UILabel!
    @IBOutlet weak var sliderGasPrice: UISlider!
    
    @IBOutlet weak var lbSlow: UILabel!
    @IBOutlet weak var lbNormal: UILabel!
    @IBOutlet weak var lbFast: UILabel!
    @IBOutlet weak var lbExplain: UILabel!
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    
    var infoEthViewBorder: UIView!
    
    @IBOutlet weak var amountTopConstraint: NSLayoutConstraint!
    let amountTopDefault = 20
    let amountTopEthNotEnough = 114
    let amountTopEthEnough = 86
    // Default: 20
    // Convert offchain to offchain, ETH balance is not enough: 114
    // Convert offchain to offchain, ETH balance is enough: 86
    
    @IBOutlet weak var ethBalanceLbTopConstraint: NSLayoutConstraint!
    let ethBalanceTopDefault = 15
    let ethBalanceNotEnough = 12
    // Default: 15
    // Convert offchain to offchain, ETH balance is not enough: 12
    
    @IBOutlet weak var ethContainerViewHeightConstraint: NSLayoutConstraint!
    let ethContainerHeightDefault = 45
    let ethContainerHeightNotEnough = 74
    // Default: 45
    // Convert offchain to offchain, ETH balance is not enough: 74
    
    @IBOutlet weak var spendableTopConstraint: NSLayoutConstraint!
    let spendableTopDefault = 12
    let spendableTopError = 26
    // Default: 12
    // Error: 26
    
    @IBOutlet weak var gasLimitTopConstraint: NSLayoutConstraint!
    let gasLimitTopDefault = 75
    let gasLimitConvertOffToOff = 38
    // Default: 75
    // Convert offchain to offchain: 38
    
    var eventHandler: ConvertModuleInterface?
    
    var isConvertOffchainToOffchain = false
    
    var offchainInfo: OffchainInfoDTO?
    
    var selectedGasPriceInGWEI = NSNumber(value: 3)
    
    var onchainInfo: OnchainInfoDTO?
    
    var ethInfo: EthAndTransferFeeDTO? {
        didSet {
            updateLayoutWithEthInfoAndTransferFee()
        }
    }
    
    var gasPrice: GasPriceDTO?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTarget()
        setupRefreshControl()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Convert To Offchain".localized
    }
    
    func loadInitialData() {
        if isConvertOffchainToOffchain {
            eventHandler?.loadEthAndFeeTransfer()
            eventHandler?.loadEthAndOffchainInfo()
        } else {
            eventHandler?.loadEthAndOnchainInfo()
        }
        eventHandler?.loadGasPrice()
    }
    
    func setupLayout() {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 700)
        
        if isConvertOffchainToOffchain {
            infoEthViewBorder = UIView(frame: CGRect(x: ethContainerView.frame.origin.x - 2, y: ethContainerView.frame.origin.y, width: UIScreen.main.bounds.width - 30 + 4, height: CGFloat(ethContainerHeightDefault)))
            infoEthViewBorder.backgroundColor = .clear
            containerView.insertSubview(infoEthViewBorder, belowSubview: ethContainerView)
            
            infoEthViewBorder.dropShadow()
            infoEthViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            infoEthViewBorder.layer.shadowRadius = 2.0
            infoEthViewBorder.layer.shadowColor = UIColor(hexString: "a8c5ec").cgColor
            
            layoutLoadingStateForEthAndTransferFee()
            
            amountBorderView.isHidden = true
            lbSpendableTitle.isHidden = true
            lbSpendable.isHidden = true
            lbSpendableTrail.isHidden = true
            
            txtAmount.text = "Loading...".localized
            txtAmount.isUserInteractionEnabled = false
        } else {
            ethContainerView.isHidden = true
            amountTopConstraint.constant = CGFloat(amountTopDefault)
        }
        
        btnContinue.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
        
        let string = "Gas Price is the amount you pay per unit of gas. TX fee = Gas Used by Txn * Gas Price & is paid to miners for including your TX in a block. Higher the gas price = faster transaction, but more expensive.".localized as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0)])
        
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "TX fee = gas price * gas limit"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "TX fee = Txn에서 사용하는 가스 * Gas Price 이며"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Tổng chi phí (TX fee) được tính = Số Gas thực dùng * Gas Price"))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "41 GWEI"))
        
        lbExplain.attributedText = attributedString
        
        lbSpendable.text = "Loading...".localized
    }
    
    func layoutLoadingStateForEthAndTransferFee(balanceText: String = "Loading...".localized, isWarning: Bool = false) {
        let string = "Your ETH balance is: %@".localizedFormat(balanceText) as NSString
        let textColorString  = isWarning ? "f05454" : "000000"
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0), NSAttributedStringKey.foregroundColor: UIColor(hexString: textColorString)])
        
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: balanceText))
        
        ethBalanceLb.attributedText = attributedString
        ethBalanceLbTopConstraint.constant = CGFloat(isWarning ? ethBalanceNotEnough : ethBalanceTopDefault)
        
        ethNeedLb.isHidden = isWarning ? false : true
        
        ethContainerViewHeightConstraint.constant = CGFloat(isWarning ? ethContainerHeightNotEnough : ethContainerHeightDefault)
        
        if isWarning {
            ethContainerView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "f05454"), borderWidth: 1)
        } else {
            ethContainerView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "a0afbe"), borderWidth: 0.5)
        }
        ethContainerView.layer.cornerRadius = 5
        ethContainerView.backgroundColor = isWarning ? UIColor(hexString: "ffebe9") : .white
        
        amountTopConstraint.constant = CGFloat(isWarning ? amountTopEthNotEnough : amountTopEthEnough)
        
        gasLimitTopConstraint.constant = CGFloat(gasLimitConvertOffToOff)
        
        infoEthViewBorder.isHidden = isWarning ? true : false
    }
    
    func updateLayoutWithEthInfoAndTransferFee() {
        if let info = self.ethInfo {
            let ethBalanceInDouble = (info.balanceOfETH?.balance ?? 0).convertOutputValue(decimal: info.balanceOfETH?.decimals ?? 18)
            let ethBalanceText = ethBalanceInDouble.removeZerosFromEnd(maximumFractionDigits: 8)
            
            // balance < transfer fee
            if (info.balanceOfETH?.balance ?? 0).compare(info.feeTransferERC20 ?? 0) == .orderedAscending {
                layoutLoadingStateForEthAndTransferFee(balanceText: ethBalanceText, isWarning: true)
                
                let feeDecimalNumber = NSDecimalNumber(decimal: (info.feeTransferERC20 ?? 0).decimalValue)
                let ethBalanceDecimalNumber = NSDecimalNumber(decimal: (info.balanceOfETH?.balance ?? 0).decimalValue)
                let result = feeDecimalNumber.subtracting(ethBalanceDecimalNumber)
                let resultInDoule = result.convertOutputValue(decimal: info.balanceOfETH?.decimals ?? 18)
                let resultText = resultInDoule.removeZerosFromEnd(maximumFractionDigits: 8)
                
                let string = "You need to transfer %@ ETH into this MozoX Offchain Wallet address to pay TX Fee".localizedFormat(resultText) as NSString
                let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0)])
                
                let boldFontAttribute = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)]
                
                // Part of string to be bold
                attributedString.addAttributes(boldFontAttribute, range: string.range(of: resultText))
                attributedString.addAttributes(boldFontAttribute, range: string.range(of: "ETH"))
                ethNeedLb.attributedText = attributedString
            } else {
                layoutLoadingStateForEthAndTransferFee(balanceText: ethBalanceText)
            }
        }
    }
    
    func setupRefreshControl() {
        // Add Refresh Control to Scroll View
        scrollView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        if isConvertOffchainToOffchain {
            eventHandler?.loadEthAndFeeTransfer()
            eventHandler?.loadEthAndOffchainInfo()
        } else {
            eventHandler?.loadEthAndOnchainInfo()
        }
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
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
    
    func setEnableButtonContinue(_ isEnable: Bool = true) {
        btnContinue.isUserInteractionEnabled = isEnable
        btnContinue.backgroundColor = isEnable ? ThemeManager.shared.main : ThemeManager.shared.disable
    }
    
    func checkDisableButtonContinue(_ text: String = "") {
        if !text.isEmpty, let value = Double(text.replace(",", withString: ".")), value > 0 {
            setEnableButtonContinue()
        } else {
            setEnableButtonContinue(false)
        }
    }
    
    func checkDisableButtonContinueForConvertOffToOff() {
        var isEnable = false
        if let ethInfo = self.ethInfo, let offchainInfo = self.offchainInfo, (offchainInfo.balanceOfTokenOnchain?.balance ?? 0).compare(NSNumber(value: 0)) == .orderedDescending {
            // balance < transfer fee
            if (ethInfo.balanceOfETH?.balance ?? 0).compare(ethInfo.feeTransferERC20 ?? 0) == .orderedAscending {
                isEnable = false
            } else {
                isEnable = true
            }
        }
        setEnableButtonContinue(isEnable)
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
        if isConvertOffchainToOffchain {
            if let ethInfo = self.ethInfo, let offchainInfo = self.offchainInfo, let gasPrice = self.gasPrice, let gasLimit = gasPrice.gasLimit, selectedGasPriceInGWEI.compare(NSNumber(value: 0)) == .orderedDescending {
                eventHandler?.validateTxConvert(ethInfo: ethInfo, offchainInfo: offchainInfo, gasPrice: selectedGasPriceInGWEI, gasLimit: gasLimit)
                return
            }
        } else {
            if let onchainInfo = self.onchainInfo, let gasPrice = self.gasPrice, let gasLimit = gasPrice.gasLimit, let amountText = txtAmount.text, selectedGasPriceInGWEI.compare(NSNumber(value: 0)) == .orderedDescending {
                eventHandler?.validateTxConvert(onchainInfo: onchainInfo, amount: amountText, gasPrice: selectedGasPriceInGWEI, gasLimit: gasLimit)
                return
            }
        }
        displayMozoError(ConnectionError.systemError.localizedDescription)
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
    func updateEthAndOffchainInfo(_ offchainInfo: OffchainInfoDTO) {
        self.offchainInfo = offchainInfo
        if let info = offchainInfo.balanceOfTokenOnchain, let balance = info.balance, let decimals = info.decimals {
            txtAmount.text = balance
                .convertOutputValue(decimal: decimals)
                .roundAndAddCommas(toPlaces: decimals)
            checkDisableButtonContinueForConvertOffToOff()
        } else {
            txtAmount.text = "Loading...".localized
            setEnableButtonContinue(false)
        }
    }
    
    func updateLoadingStateForEthAndOffchainInfo() {
        setEnableButtonContinue(false)
    }
    
    func updateEthInfo(_ ethInfo: EthAndTransferFeeDTO) {
        self.ethInfo = ethInfo
        checkDisableButtonContinueForConvertOffToOff()
    }
    
    func updateLoadingStateForEthAndTransferFee() {
        layoutLoadingStateForEthAndTransferFee()
        setEnableButtonContinue(false)
    }
    
    func didReceiveOnchainInfo(_ onchainInfo: OnchainInfoDTO) {
        self.onchainInfo = onchainInfo
        updateOnchainInfoData()
    }
    
    func updateLoadingStateForOnchainInfo() {
        lbSpendable.text = "Loading...".localized
    }
    
    func didReceiceGasPrice(_ gasPrice: GasPriceDTO) {
        self.gasPrice = gasPrice
        updateGasPriceData()
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
}
