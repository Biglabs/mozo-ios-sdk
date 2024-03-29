//
//  OnchainWalletView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/8/19.
//

import Foundation
import MBProgressHUD
class MozoOnchainWalletView: MozoView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var howToView: UIView!
    @IBOutlet weak var lbHowTo: UILabel!
    @IBOutlet weak var imgHowTo: UIImageView!
    
    @IBOutlet weak var infoEthView: UIView!
    @IBOutlet weak var imgEth: UIImageView!
    @IBOutlet weak var lbEthBalance: UILabel!
    @IBOutlet weak var lbEthBalanceExchange: UILabel!
    @IBOutlet weak var imgQR: UIImageView!
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet weak var btnTransfer: UIButton!
    
    @IBOutlet weak var infoOnchainView: UIView!
    @IBOutlet weak var imgOnchain: UIImageView!
    @IBOutlet weak var lbOnchainBalance: UILabel!
    @IBOutlet weak var lbOnchainBalanceExchange: UILabel!
    @IBOutlet weak var btnConvert: UIButton!
    
    @IBOutlet weak var etherscanView: UIView!
    @IBOutlet weak var etherscanLabel: UILabel!
    @IBOutlet weak var imgEtherscan: UIImageView!
    
    var infoEthViewBorder: UIView!
    var infoEthShadowLayer: CAShapeLayer!
    
    var infoOnchainViewBorder: UIView!
    var infoOnchainShadowLayer: CAShapeLayer!
    
    var hud: MBProgressHUD?
    var onchainDisplayItem : DetailInfoDisplayItem?
    var ethDisplayItem : DetailInfoDisplayItem?
    
    private let refreshControl = UIRefreshControl()
    var isLoading = false
    
    override func identifier() -> String {
        return "MozoOnchainWalletView"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        lbEthBalanceExchange.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        lbOnchainBalanceExchange.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        loadDisplayData()
        setupButtonBorder()
        setupLayout()
        setupTarget()
        setupRefreshControl()
        addEthAndOnchainObserver()
    }
    
    override func updateView() {
        // No need to use this method from super class because it will reload all UI components.
        loadDisplayData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
            print("MozoOnchainWalletView - Update scroll view content size")
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 720)
        }
    }
    
    func setupRefreshControl() {
        // Add Refresh Control to Scroll View
        scrollView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadEthOnchainBalanceInfo()
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func loadEthOnchainBalanceInfo() {
        print("Load ETH and Onchain balance info")
        if !isLoading {
            isLoading = true
            MozoSDK.loadEthAndOnchainBalanceInfo().done({ (onchainInfo) in
                self.checkDisableButtonConvert(isPending: !(onchainInfo.convertToMozoXOnchain ?? false))
            }).catch({ (error) in
                self.checkDisableButtonConvert(isPending: true)
            }).finally {
                self.isLoading = false
            }
        }
    }
    
    func setupLayout() {
        imgHowTo.transform = imgHowTo.transform.rotated(by: CGFloat.pi)
        let imgArrow = UIImage(named: "ic_left_arrow", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgEtherscan.image = imgArrow
        imgEtherscan.tintColor = UIColor(hexString: "4e94f3")
        imgEtherscan.transform = imgEtherscan.transform.rotated(by: CGFloat.pi)
        
        let string = "Go to Etherscan.io".localized as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0)])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: "Etherscan.io"))
        
        etherscanLabel.attributedText = attributedString
    }
    
    func setupTarget() {
        let tapHowTo = UITapGestureRecognizer(target: self, action: #selector(openHowTo))
        howToView.isUserInteractionEnabled = true
        howToView.addGestureRecognizer(tapHowTo)
        
        let tapQR = UITapGestureRecognizer(target: self, action: #selector(showQRCode))
        imgQR.isUserInteractionEnabled = true
        imgQR.addGestureRecognizer(tapQR)
        
        let tapEtherscan = UITapGestureRecognizer(target: self, action: #selector(openEtherscan))
        etherscanView.isUserInteractionEnabled = true
        etherscanView.addGestureRecognizer(tapEtherscan)
    }
    
    @objc func openHowTo() {
        guard var url = URL(string: "https://\(MozoSDK.network.landingPage)/help-center?section=faq-contributer#home-faq-how-to-buy-mozox-onchain-on-exchange") else { return }
        url.appendQueryItem(name: "language", value: Configuration.LOCALE)
        UIApplication.shared.open(url)
    }
    
    @objc func openEtherscan() {
        guard let url = URL(string: "https://etherscan.io/address/\(btnAddress.titleLabel?.text ?? "")") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func showQRCode() {
        if let address = self.ethDisplayItem?.address {
            DisplayUtils.displayQRView(address: address)
        }
    }
    
    func setupButtonBorder() {
        btnConvert.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 1)
        btnConvert.layer.cornerRadius = 18
        btnTransfer.roundCorners(cornerRadius: 0.149, borderColor: .white, borderWidth: 1)
        btnTransfer.layer.cornerRadius = 18
        btnRequest.roundCorners(cornerRadius: 0.149, borderColor: .white, borderWidth: 1)
        btnRequest.layer.cornerRadius = 18
        
        howToView.roundCorners(cornerRadius: 0.015, borderColor: ThemeManager.shared.textSection, borderWidth: 0.5)
        
        if infoEthViewBorder == nil {
            infoEthViewBorder = UIView(frame: CGRect(x: infoEthView.frame.origin.x - 2, y: infoEthView.frame.origin.y, width: UIScreen.main.bounds.width - 30 + 4, height: 190))
            infoEthViewBorder.backgroundColor = .clear
            infoEthView.superview?.insertSubview(infoEthViewBorder, belowSubview: infoEthView)
        }
        
        infoEthViewBorder.dropShadow()
        infoEthViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        infoEthViewBorder.layer.shadowRadius = 2.0
        infoEthViewBorder.layer.shadowColor = UIColor(hexString: "a8c5ec").cgColor
        
        infoEthView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "a0afbe"), borderWidth: 0.5)
        
        if infoOnchainViewBorder == nil {
            infoOnchainViewBorder = UIView(frame: CGRect(x: infoOnchainView.frame.origin.x - 2, y: infoOnchainView.frame.origin.y, width: UIScreen.main.bounds.width - 30 + 4, height: 134))
            infoOnchainViewBorder.backgroundColor = .clear
            infoOnchainView.superview?.insertSubview(infoOnchainViewBorder, belowSubview: infoOnchainView)
        }
        
        infoOnchainViewBorder.dropShadow()
        infoOnchainViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        infoOnchainViewBorder.layer.shadowRadius = 2.0
        infoOnchainViewBorder.layer.shadowColor = UIColor(hexString: "a8c5ec").cgColor
        
        infoOnchainView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "a0afbe"), borderWidth: 0.5)
        
        checkDisableButtonConvert(isPending: !(SessionStoreManager.onchainInfo?.convertToMozoXOnchain ?? false))
    }
    
    func clearValueOnUI() {
        if lbEthBalance != nil {
            lbEthBalance.text = "Loading...".localized
            lbEthBalanceExchange.text = "Loading...".localized
            
            lbOnchainBalance.text = "Loading...".localized
            lbOnchainBalanceExchange.text = "Loading...".localized
        }
    }
    
    func updateEthData(displayItem: DetailInfoDisplayItem) {
        if imgQR != nil {
            if !displayItem.address.isEmpty {
                let qrImg = DisplayUtils.generateQRCode(from: displayItem.address)
                imgQR.image = qrImg
                
                btnAddress.setTitle(displayItem.address, for: .normal)
            }
            let balance = displayItem.balance
            if balance >= 0 {
                let number = NSNumber(value: balance)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                numberFormatter.multiplier = 1
                numberFormatter.minimumFractionDigits = 1
                numberFormatter.maximumFractionDigits = 5
                numberFormatter.roundingMode = .down
                let formattedNumber = numberFormatter.string(from: number)
                
                lbEthBalance.text = formattedNumber
                lbEthBalanceExchange.text = DisplayUtils.getExchangeTextFromAmount(balance)
            } else {
                lbEthBalance.text = "Loading...".localized
                lbEthBalanceExchange.text = "Loading...".localized
            }
        }
        print("Save display item for later usage.")
        self.ethDisplayItem = displayItem
    }
    
    func updateOnchainData(displayItem: DetailInfoDisplayItem) {
        if lbOnchainBalanceExchange != nil {
            let balance = displayItem.balance
            if balance >= 0 {
                let balanceText = balance.roundAndAddCommas()
                lbOnchainBalance.text = balanceText
                lbOnchainBalanceExchange.text = DisplayUtils.getExchangeTextFromAmount(balance)
            } else {
                lbOnchainBalance.text = "Loading...".localized
                lbOnchainBalanceExchange.text = "Loading...".localized
            }
        }
        self.ethDisplayItem = displayItem
    }
    
    func loadDisplayData() {
        // Clear all data
        clearValueOnUI()
        print("\(String(describing: self)) - Load display data.")
        if let ethItem = SafetyDataManager.shared.ethDetailDisplayData, ethItem.balance >= 0 {
            print("\(String(describing: self)) - Receive ETH display data: \(ethItem)")
            self.updateEthData(displayItem: ethItem)
        } else {
            clearValueOnUI()
        }
        if let onchainItem = SafetyDataManager.shared.onchainDetailDisplayData, onchainItem.balance >= 0 {
            print("\(String(describing: self)) - Receive onchain display data: \(onchainItem)")
            self.updateOnchainData(displayItem: onchainItem)
        } else {
            clearValueOnUI()
        }
    }
    
    func copyAddressAndShowHud() {
        UIPasteboard.general.string = btnAddress.titleLabel?.text ?? ""
        showHud()
    }
    
    func showHud() {
        if let view = self.superview {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = .text
            hud?.label.text = "Copied to clipboard".localized
            hud?.label.textColor = .white
            hud?.label.numberOfLines = 2
            hud?.offset = CGPoint(x: 0, y: -300)
            hud?.bezelView.color = UIColor(hexString: "333333")
            hud?.isUserInteractionEnabled = false
            hud?.hide(animated: true, afterDelay: 1.5)
        }
    }
    
    func checkDisableButtonConvert(isPending: Bool) {
        if !isPending {
            btnConvert.setTitle("btn_convert_to_mozo".localized, for: .normal)
            btnConvert.isUserInteractionEnabled = true
            btnConvert.backgroundColor = ThemeManager.shared.main
        } else {
            btnConvert.setTitle("Pending transaction...".localized, for: .normal)
            btnConvert.isUserInteractionEnabled = false
            btnConvert.backgroundColor = ThemeManager.shared.disable
        }
    }
    
    @IBAction func touchAddress(_ sender: Any) {
        copyAddressAndShowHud()
    }
    
    @IBAction func touchCopyButton(_ sender: Any) {
        copyAddressAndShowHud()
    }
    
    @IBAction func touchConvertButton(_ sender: Any) {
        MozoSDK.convertMozoXOnchain()
    }
    
    @IBAction func touchRequestButton(_ sender: Any) {
        
    }
    
    @IBAction func touchTransferButton(_ sender: Any) {
        
    }
    
    // MARK: NOTIFICATION - OBSERVATION
    @objc func onLoadETHOnchainTokenInfoFailed(_ notification: Notification) {
        clearValueOnUI()
    }
    
    @objc func onEthDetailDisplayDataDidReceive(_ notification: Notification) {
        loadDisplayData()
    }
    
    @objc func onOnchainDetailDisplayDataDidReceive(_ notification: Notification) {
        loadDisplayData()
    }
    
    @objc func onDidCloseAllMozoUI(_ notification: Notification) {
        // Reload onchain info when view appear
        loadEthOnchainBalanceInfo()
    }
    
    @objc func onDidConvertSuccessOnchainToOffchain(_ notification: Notification) {
        loadEthOnchainBalanceInfo()
    }
    
    func removeAllObservers() {
        NotificationCenter.default.removeObserver(self, name: .didLogoutFromMozo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveOnchainDetailDisplayItem, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didReceiveETHDetailDisplayItem, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didLoadETHOnchainTokenInfoFailed, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didConvertSuccessOnchainToOffchain, object: nil)
    }
    
    func addEthAndOnchainObserver() {
        removeAllObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserDidLogout(_:)), name: .didLogoutFromMozo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onOnchainDetailDisplayDataDidReceive(_:)), name: .didReceiveOnchainDetailDisplayItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onEthDetailDisplayDataDidReceive(_:)), name: .didReceiveETHDetailDisplayItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadTokenInfoFailed(_:)), name: .didLoadETHOnchainTokenInfoFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidConvertSuccessOnchainToOffchain(_:)), name: .didConvertSuccessOnchainToOffchain, object: nil)
    }
    
    override func removeObserverAfterLogout() {
        print("Remove observer after logout")
        removeAllObservers()
    }
}
