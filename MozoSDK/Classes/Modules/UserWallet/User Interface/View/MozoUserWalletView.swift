//
//  MozoUserWalletView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/15/18.
//

import Foundation
import MBProgressHUD
let TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER = "TxHistoryTableViewCell"

@IBDesignable class MozoUserWalletView: MozoView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewBorder: UIView!
    @IBOutlet weak var btnReload: UIButton!
    @IBOutlet weak var lbBalance: UILabel!
    @IBOutlet weak var imgMozo: UIImageView!
    @IBOutlet weak var lbBalanceExchange: UILabel!
    @IBOutlet weak var imgQR: UIImageView!
    @IBOutlet weak var btnShowQR: UIButton!
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var sendMozoView: MozoSendView!
    @IBOutlet weak var paymentRequestView: MozoPaymentRequestView!
    
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var infoViewBorderWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var onchainDetectedView: UIView!
    @IBOutlet weak var onchainDetectedViewHeightConstraint: NSLayoutConstraint!
    // Default is 74, 43 if offchain wallet is converting...
    let detectedViewHeightDefault = 74
    let detectedViewHeightConverting = 43
    
    @IBOutlet weak var onchainDetectedTitle: UILabel!
    @IBOutlet weak var onchainDetectedTitleTopConstraint: NSLayoutConstraint!
    // Default is 12, 15 if offchain wallet is converting...
    let detectedTitleTopDefault = 12
    let detectedTitleTopConvering = 15
    
    @IBOutlet weak var onchainDetectedDescription: UILabel!
    
    @IBOutlet weak var imgViewArrow: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    // Default is 20, 113 if offchain wallet contains onchain tokens, 82 if offchain wallet is converting...
    let topConstraintDefault = 20
    let topConstraintWithAction = 113
    let topConstraintConverting = 82
    
    private let refreshControl = UIRefreshControl()
    
    var hud: MBProgressHUD?
    
    let onchainWalletView = MozoOnchainWalletView.init(frame: CGRect(x: 0, y: 66, width: UIScreen.main.bounds.width, height: 650))
    
    var displayItem : DetailInfoDisplayItem?
    var collection : TxHistoryDisplayCollection? {
        didSet {
            historyTable.reloadData()
        }
    }
    
    var offchainInfo: OffchainInfoDTO?
    
    override func identifier() -> String {
        return "MozoUserWalletView"
    }
    
    var isAnonymous: Bool = false
    override func loadViewFromNib() {
        if AccessTokenManager.getAccessToken() == nil
            || SessionStoreManager.loadCurrentUser() == nil {
            isAnonymous = true
        } else {
            isAnonymous = false
        }
        super.loadViewFromNib()
        #if !TARGET_INTERFACE_BUILDER
        loadDisplayData()
        testAssests()
        setupTableView()
        setupSegment()
        setupButtonBorder()
        setupLayout()
        setupTarget()
        setupOnchainWalletView()
        setupObservers()
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func testAssests() {
        let img = UIImage(named: "ic_send", in: BundleManager.mozoBundle(), compatibleWith: nil)
        if img != nil {
            print("MozoUserWalletView - TEST ASSESTS - CAN LOAD IMAGE")
        } else {
            print("MozoUserWalletView - TEST ASSESTS - CAN NOT LOAD IMAGE")
        }
    }
    
    override func updateView() {
        // No need to use this method from super class because it will reload all UI components.
        loadDisplayData()
    }
    
    func setupOnchainWalletView() {
        self.addSubview(onchainWalletView)
        self.bringSubviewToFront(onchainWalletView)
        self.onchainWalletView.isHidden = true
    }

    func setupTableView() {
        historyTable.register(UINib(nibName: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER)
        historyTable.dataSource = self
        historyTable.delegate = self
        historyTable.tableFooterView = UIView()
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        historyTable?.refreshControl = refreshControl
        
        setupNoContentView()
    }
    
    func setupSegment() {
        segmentControl.setTitle("Offchain Wallet".localized, forSegmentAt: 0)
        segmentControl.setTitle("Onchain Wallets".localized, forSegmentAt: 1)
        segmentControl.addUnderLines()
    }
    
    func setupLayout() {
        let imgReload = UIImage(named: "ic_curved_arrows", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        btnReload.setImage(imgReload, for: .normal)
        btnReload.tintColor = UIColor(hexString: "d1d7dd")
        
        topConstraint.constant = CGFloat(topConstraintDefault)
        
        onchainDetectedView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "80a9e0"), borderWidth: 0.5)
        onchainDetectedView.layer.cornerRadius = 5
        
        let imgArrow = UIImage(named: "ic_left_arrow", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgViewArrow.image = imgArrow
        imgViewArrow.tintColor = UIColor(hexString: "4e94f3")
        imgViewArrow.transform = imgViewArrow.transform.rotated(by: CGFloat.pi)
    }
    
    func setupTarget() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showQRCode))
        imgQR.isUserInteractionEnabled = true
        imgQR.addGestureRecognizer(tap)
        
        
        let tapConvert = UITapGestureRecognizer(target: self, action: #selector(openConvert))
        onchainDetectedView.isUserInteractionEnabled = true
        onchainDetectedView.addGestureRecognizer(tapConvert)
    }
    
    @objc func openConvert() {
        if let offchainInfo = offchainInfo, let isConvert = offchainInfo.convertToMozoXOnchain, isConvert {
            MozoSDK.convertMozoXOnchain(isConvertOffchainToOffchain: true)
        }
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadTxHistory()
        loadOnchainInfo()
        loadTokenInfo()
    }
    
    func setupButtonBorder() {
        sendMozoView.roundedCircle()
        paymentRequestView.roundedCircle()
        
        infoViewBorderWidthConstraint.constant = UIScreen.main.bounds.width - 26
        infoViewBorder.dropShadow()
        let rectShadow = CGRect(x: infoViewBorder.bounds.origin.x, y: infoViewBorder.bounds.origin.y, width: UIScreen.main.bounds.width - 26, height: infoViewBorder.bounds.height)
        infoViewBorder.layer.shadowPath = UIBezierPath(rect: rectShadow).cgPath
        infoViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        infoViewBorder.layer.shadowRadius = 2.0
        infoViewBorder.layer.shadowColor = UIColor(hexString: "a8c5ec").cgColor
        
        infoView.roundCorners(cornerRadius: 0.015, borderColor: ThemeManager.shared.disable, borderWidth: 0.5)
    }

    func clearValueOnUI() {
        if lbBalance != nil {
            lbBalance.text = "Loading...".localized
            lbBalanceExchange.text = "Loading...".localized
        }
        collection = nil
    }

    func updateData(displayItem: DetailInfoDisplayItem) {
        if lbBalance != nil {
            addUniqueBalanceChangeObserver()
            updateOnlyBalance(displayItem.balance)
        }
        if imgQR != nil {
            if !displayItem.address.isEmpty {
                let qrImg = DisplayUtils.generateQRCode(from: displayItem.address)
                imgQR.image = qrImg
                
                btnAddress.setTitle(displayItem.address, for: .normal)
            }
        }
        print("Save display item for later usage.")
        self.displayItem = displayItem
    }
    
    override func updateOnlyBalance(_ balance : Double) {
        print("Update balance on Mozo UI Components")
        if lbBalance != nil {
            if balance >= 0 {
                let balanceText = balance.roundAndAddCommas()
                lbBalance.text = balanceText
                lbBalanceExchange.text = DisplayUtils.getExchangeTextFromAmount(balance)
            } else {
                clearValueOnUI()
            }
        }
    }
    
    func loadTxHistory() {
        _ = MozoSDK.getTxHistoryDisplayCollection().done { (collectionData) in
            self.collection = collectionData
            
            self.refreshControl.endRefreshing()
        }.catch({ (error) in
            
            self.refreshControl.endRefreshing()
        })
    }
    
    func loadOnchainInfo() {
        /**
         * Detect Onchain MozoX inside Offchain Wallet Address
         * */
        /**
         * Disable Detect On-chain feature for now
         * Thursday, May 6, 2021 4:21:04 PM GMT+07:00
         *
        _ = MozoSDK.getOffchainTokenInfo().done { (info) in
            self.offchainInfo = info
            if (info.convertToMozoXOnchain ?? false) == false {
                self.topConstraint.constant = CGFloat(self.topConstraintConverting)
                self.onchainDetectedViewHeightConstraint.constant = CGFloat(self.detectedViewHeightConverting)
                self.onchainDetectedTitleTopConstraint.constant = CGFloat(self.detectedTitleTopConvering)
                self.onchainDetectedTitle.text = "text_converting_mozo".localized
                self.onchainDetectedDescription.isHidden = true
                
                self.onchainDetectedView.isHidden = false
                return
            }
            if (info.detectedOnchain ?? false) == true {
                self.topConstraint.constant = CGFloat(self.topConstraintWithAction)
                self.onchainDetectedViewHeightConstraint.constant = CGFloat(self.detectedViewHeightDefault)
                
                let balance = (info.balanceOfTokenOnchain?.balance ?? 0).convertOutputValue(decimal: info.balanceOfTokenOnchain?.decimals ?? 2)
                
                self.onchainDetectedTitle.text = "text_detected_mozo_x".localizedFormat(balance.roundAndAddCommas(toPlaces: info.balanceOfTokenOnchain?.decimals ?? 0))
                self.onchainDetectedDescription.isHidden = false
                self.onchainDetectedTitleTopConstraint.constant = CGFloat(self.detectedTitleTopDefault)
                
                self.onchainDetectedView.isHidden = false
            } else {
                self.topConstraint.constant = CGFloat(self.topConstraintDefault)
                self.onchainDetectedView.isHidden = true
            }
        }.catch { (error) in
            self.topConstraint.constant = CGFloat(self.topConstraintDefault)
        }
         */
    }
    
    func loadTokenInfo() {
        _ = MozoSDK.loadBalanceInfo().done({ (displayItem) in
            self.updateData(displayItem: displayItem)
            self.hideRefreshState()
        }).catch({ (error) in
            self.clearValueOnUI()
        })
    }
    
    func loadDisplayData() {
        // Clear all data
        clearValueOnUI()
        if !isAnonymous {
            loadTxHistory()
            loadOnchainInfo()
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
            
        }
    }
    
    @IBAction func touchedViewAllHistory(_ sender: Any) {
        print("Touched Up Inside Button View All history")
        MozoSDK.displayTransactionHistory()
    }

    @IBAction func touchedShowQR(_ sender: Any) {
        showQRCode()
    }
    
    @objc func showQRCode() {
        print("Touch Show QR code button, address: \(self.displayItem?.address ?? "NULL")")
        if let address = self.displayItem?.address {
            DisplayUtils.displayQRView(address: address)
        }
    }
    
    var isLoading = false
    
    @IBAction func touchedBtnReload(_ sender: Any) {
        if !isLoading {
            isLoading = true
            rotateView()
            MozoSDK.loadBalanceInfo().done { (displayItem) in
                self.updateData(displayItem: displayItem)
                self.isLoading = false
            }.catch { (error) in
                self.isLoading = false
            }
        }
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.btnReload.transform = self.btnReload.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if self.isLoading {
                self.rotateView(duration: duration)
            } else {
                self.btnReload.transform = .identity
            }
        }
    }
    
    // MARK: Refresh state
    var refreshView : MozoRefreshView?
    
    func displayRefreshState() {
        print("Display refresh state")
        if refreshView == nil {
            refreshView = MozoRefreshView(frame: UIScreen.main.bounds)
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
        clearValueOnUI()
    }
    
    func copyAddressAndShowHud() {
        UIPasteboard.general.string = btnAddress.titleLabel?.text ?? ""
        showHud()
    }
    
    func showHud() {
        hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.mode = .text
        hud?.label.text = "Copied to clipboard".localized
        hud?.label.textColor = .white
        hud?.label.numberOfLines = 2
        hud?.offset = CGPoint(x: 0, y: -300)
        hud?.bezelView.color = UIColor(hexString: "e63b4b61")
        hud?.isUserInteractionEnabled = false
        hud?.hide(animated: true, afterDelay: 1.5)
    }
    
    // MARK: Empty view
    var noContentView: UIView!
    
    func setupNoContentView() {
        if noContentView != nil {
            return
        }
        let frame = CGRect(x: 0, y: historyTable.frame.origin.y, width: UIScreen.main.bounds.width, height: historyTable.frame.height)
        noContentView = DisplayUtils.defaultNoContentView(frame, message: "Transaction history list is empty".localized)
    }
    
    func checkShowNoContent() {
        if self.collection?.displayItems.count ?? 0 > 0 {
            historyTable.backgroundView = nil
        } else {
            historyTable.backgroundView = noContentView
        }
    }
    
    // MARK: Actions
    
    @IBAction func segmentedControlDidChange(_ sender: Any) {
        segmentControl.changeUnderlinePosition()
        if segmentControl.selectedSegmentIndex == 0 {
            onchainWalletView.isHidden = true
            historyTable.isHidden = false
        } else {
            onchainWalletView.isHidden = false
            historyTable.isHidden = true
        }
    }
    
    @IBAction func touchAddress(_ sender: Any) {
        copyAddressAndShowHud()
    }
    
    @IBAction func touchCopyButton(_ sender: Any) {
        copyAddressAndShowHud()
    }
    
    // MARK: NOTIFICATION - OBSERVATION
    
    func setupObservers() {
        addOriginalObserver()
        addUniqueAuthObserver()
        addEthAndDetectedObserver()
    }
    
    @objc func onDidCloseAllMozoUI(_ notification: Notification) {
        // Reload onchain info when view appear
        loadOnchainInfo()
    }
    
    @objc func onDidConvertSuccessOnchainToOffchain(_ notification: Notification) {
        loadOnchainInfo()
    }
    
    func removeEthAndDetectedObservers() {
        NotificationCenter.default.removeObserver(self, name: .didCloseAllMozoUI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didConvertSuccessOnchainToOffchain, object: nil)
    }
    
    func addEthAndDetectedObserver() {
        removeEthAndDetectedObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidCloseAllMozoUI(_:)), name: .didCloseAllMozoUI, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidConvertSuccessOnchainToOffchain(_:)), name: .didConvertSuccessOnchainToOffchain, object: nil)
    }
    
    override func removeObserverAfterLogout() {
        super.removeObserverAfterLogout()
        removeEthAndDetectedObservers()
    }
}
extension MozoUserWalletView : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        checkShowNoContent()
        return collection != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection?.displayItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! TxHistoryTableViewCell
        let item = (collection?.displayItems[indexPath.row])!
        cell.txHistory = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}
extension MozoUserWalletView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let selectedItem = collection?.displayItems[indexPath.row] {
            if let tokenInfo = SessionStoreManager.tokenInfo {
                MozoSDK.displayTransactionDetail(txHistory: selectedItem, tokenInfo: tokenInfo)
            }
        }
    }
}
