//
//  ConfirmConvertViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
class ConfirmConvertViewController: MozoBasicViewController {
    @IBOutlet weak var convertImageContainerView: UIView!
    @IBOutlet weak var lbOnchainAmount: UILabel!
    @IBOutlet weak var lbOnchainAmountEx: UILabel!
    @IBOutlet weak var lbOffchainAmount: UILabel!
    @IBOutlet weak var lbOffchainAmountEx: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lbGasLimit: UILabel!
    @IBOutlet weak var lbGasPrice: UILabel!
    @IBOutlet weak var lbSpeed: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var lineConvert: UIView!
    @IBOutlet weak var lineFromTo: UIView!
    @IBOutlet weak var lineGasLimit: UIView!
    @IBOutlet weak var lineGasPrice: UIView!
    
    var eventHandler: ConvertModuleInterface?
    
    var transaction: ConvertTransactionDTO?
    var tokenInfoFromConverting: TokenInfoDTO?
    var gasLimit: NSNumber?
    var gasPrice: NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setupLayout()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Convert To Offchain".localized
    }
    
    func setupLayout() {
        convertImageContainerView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
        btnConfirm.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
        
        let img = UIImage(named: "ic_left_arrow_white", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgArrow.image = img
        imgArrow.tintColor = UIColor(hexString: "333333")
        imgArrow.transform = imgArrow.transform.rotated(by: CGFloat.pi)
        
//        setupDashLines()
    }
    
    func setupDashLines() {
        let lines = [lineConvert, lineFromTo, lineGasLimit, lineGasPrice]
        for line in lines {
            let v = line as! UIView
            v.backgroundColor = .clear
            let p0 = CGPoint(x: v.frame.minX, y: v.frame.minY)
            let p1 = CGPoint(x: v.frame.maxX, y: v.frame.minY)
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = UIColor.lightGray.cgColor
            shapeLayer.lineWidth = 1
            shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
            
            let path = CGMutablePath()
            path.addLines(between: [p0, p1])
            shapeLayer.path = path
            v.layer.addSublayer(shapeLayer)
        }
    }
    
    func updateData() {
        if let tx = transaction, let tokenInfo = tokenInfoFromConverting {
            let amount = tx.value?.convertOutputValue(decimal: tokenInfo.decimals ?? 0) ?? 0
            lbOnchainAmount.text = amount.roundAndAddCommas()
            lbOffchainAmount.text = lbOnchainAmount.text
                        
            lbOnchainAmountEx.text = DisplayUtils.getExchangeTextFromAmount(amount)
            lbOffchainAmountEx.text = lbOnchainAmountEx.text
            
            lbGasLimit.text = gasLimit?.addCommas()
            lbGasPrice.text = gasPrice?.addCommas()
            
            var textSpeed = "Fast"
            if let selectedGasPriceInGWEI = self.gasPrice, let gasPrice = SessionStoreManager.gasPrice {
                // Special case
                if selectedGasPriceInGWEI.compare(gasPrice.low ?? NSNumber(value: 0)) == .orderedSame {
                    textSpeed = "Slow"
                } else if selectedGasPriceInGWEI.compare(gasPrice.average ?? NSNumber(value: 0)) == .orderedAscending {
                    textSpeed = "Slow"
                } else if selectedGasPriceInGWEI.compare(gasPrice.average ?? NSNumber(value: 0)) == .orderedSame {
                    textSpeed = "Normal"
                }
            }
            lbSpeed.text = textSpeed.localized
        }
    }
    
    @IBAction func touchBtnConfirm(_ sender: Any) {
        if let tx = transaction {
            eventHandler?.sendConfirmConvertTx(tx)
        }
    }
}
extension ConfirmConvertViewController: ConfirmConvertViewInterface {
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
    }
}
