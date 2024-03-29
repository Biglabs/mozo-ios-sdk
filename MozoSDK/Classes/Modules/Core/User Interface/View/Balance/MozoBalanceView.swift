//
//  MozoBalanceView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/18/18.
//

import Foundation

@IBDesignable class MozoBalanceView : MozoView {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var lbBalanceExchange: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var imgQR: UIImageView!
    @IBOutlet weak var btnShowQR: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    //MARK: Customizable from Interface Builder
    @IBInspectable public var showFullBalanceAndAddressDetail: Bool = true {
        didSet {
            displayType = showFullBalanceAndAddressDetail ? .Full : .DetailBalance
            updateView()
        }
    }
    
    @IBInspectable public var showOnlyBalanceDetail: Bool = false {
        didSet {
            displayType = showOnlyBalanceDetail ? .DetailBalance : .NormalBalance
            updateView()
        }
    }
    
    @IBInspectable public var showOnlyAddressDetail: Bool = false {
        didSet {
            displayType = showOnlyAddressDetail ? .DetailAddress : .NormalAddress
            updateView()
        }
    }
    var displayType: BalanceDisplayType = BalanceDisplayType.Full
    var isAnonymous: Bool = false
    
    override func identifier() -> String {
        return isAnonymous ? displayType.anonymousId : displayType.id
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setBorder()
    }
    
    func setBorder() {
        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.borderInside.cgColor
    }
    
    override func loadViewFromNib() {
        isAnonymous = !SessionStoreManager.isWalletSafe()
        super.loadViewFromNib()
        loadDisplayData()
        setupButtonBorder()
        addOriginalObserver()
        addUniqueAuthObserver()
        
        lbBalanceExchange?.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
    }
    
    func loadDisplayData() {
        // Clear all data
        clearValueOnUI()
        if !isAnonymous {
            print("\(String(describing: self)) - Load display data.")
            if let item = SafetyDataManager.shared.offchainDetailDisplayData {
                print("\(String(describing: self)) - Receive display data: \(item)")
                self.updateData(displayItem: item)
                hideRefreshState()
            } else {
                print("\(String(describing: self)) - No data for displaying")
                let itemNoData = DetailInfoDisplayItem(balance: 0.0, address: "")
                self.updateData(displayItem: itemNoData)
                displayRefreshState()
            }
        } else {
            switch displayType {
            case .DetailAddress:
                lbTitle.text = "text_your_mozo_wallet_address".localized
            default: break
            }
        }
    }
    
    func setupButtonBorder() {
        if displayType == .NormalAddress {
            let color = !isAnonymous ? ThemeManager.shared.main : ThemeManager.shared.disable
            btnShowQR.layer.borderWidth = 1
            btnShowQR.layer.borderColor = color.cgColor
            btnCopy.layer.borderWidth = 1
            btnCopy.layer.borderColor = color.cgColor
        }
    }
    
    override func updateOnlyBalance(_ balance : Double) {
        print("Update balance on Mozo UI Components")
        if lbBalance != nil {
            let balanceText = balance.roundAndAddCommas()
            lbBalance.text = balanceText
            
            lbBalanceExchange.text = DisplayUtils.getExchangeTextFromAmount(balance)
        }
    }
    
    func clearValueOnUI() {
        if lbBalance != nil {
            lbBalance.text = "0.0"
            lbBalanceExchange.text = "0.0"
        }
        if lbAddress != nil {
            lbAddress.text = ""
        }
    }
    
    func updateData(displayItem: DetailInfoDisplayItem) {
        if lbBalance != nil {
            addUniqueBalanceChangeObserver()
            updateOnlyBalance(displayItem.balance)
        }
        if lbAddress != nil {
            lbAddress.text = displayItem.address
        }
        if imgQR != nil && (displayType == .Full || displayType == .DetailAddress) {
            if !displayItem.address.isEmpty {
                let qrImg = DisplayUtils.generateQRCode(from: displayItem.address)
                imgQR.image = qrImg
            }
        }
    }
    
    @IBAction func touchCopy(_ sender: Any) {
        UIPasteboard.general.string = lbAddress.text ?? ""
    }
    
    @IBAction func touchedShowQR(_ sender: Any) {
        print("Touch Show QR code button")
        if let address = lbAddress.text {
            DisplayUtils.displayQRView(address: address)
        }
    }
    @IBAction func touchedLogin(_ sender: Any) {
        print("Touch login button")
        MozoSDK.authenticate()
    }
    
    // MARK: Refresh state
    var refreshView : MozoRefreshView?
    
    func displayRefreshState() {
        print("Display refresh state")
        if refreshView == nil {
            refreshView = MozoRefreshView(frame: containerView.frame)
            if refreshView != nil {
                addSubview(refreshView!)
            }
        } else {
            refreshView?.isHidden = false
            bringSubviewToFront(refreshView!)
        }
        refreshView?.isRefreshing = false
    }
    
    func hideRefreshState() {
        if refreshView != nil {
            print("Hide refresh state.")
            refreshView?.isHidden = true
            refreshView?.isRefreshing = false
        }
    }
    
    override func onLoadTokenInfoFailed(_ notification: Notification) {
        print("On Load Token Info Failed: Display refresh state")
        displayRefreshState()
    }
}
