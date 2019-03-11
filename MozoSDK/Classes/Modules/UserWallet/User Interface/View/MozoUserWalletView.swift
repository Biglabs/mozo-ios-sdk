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
    @IBOutlet weak var infoView: UIView!
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
    private let refreshControl = UIRefreshControl()
    
    var infoViewBorder: UIView!
    var infoShadowLayer: CAShapeLayer!
    
    var hud: MBProgressHUD?
    
    let onchainWalletView = MozoOnchainWalletView.init(frame: CGRect(x: 0, y: 66, width: UIScreen.main.bounds.width, height: 650))
    
    var displayItem : DetailInfoDisplayItem?
    var collection : TxHistoryDisplayCollection? {
        didSet {
            historyTable.reloadData()
        }
    }
    
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
        loadDisplayData()
        testAssests()
        setupTableView()
        setupSegment()
        setupButtonBorder()
        setupLayout()
        setupTarget()
        setupOnchainWalletView()
        addOriginalObserver()
        addUniqueAuthObserver()
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
        self.bringSubview(toFront: onchainWalletView)
        self.onchainWalletView.isHidden = true
    }

    func setupTableView() {
        historyTable.register(UINib(nibName: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER)
        historyTable.dataSource = self
        historyTable.delegate = self
        historyTable.tableFooterView = UIView()
        setupRefreshControl()
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
    }
    
    func setupTarget() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showQRCode))
        imgQR.isUserInteractionEnabled = true
        imgQR.addGestureRecognizer(tap)
    }
    
    func setupRefreshControl() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.historyTable?.refreshControl = refreshControl
        } else {
            self.historyTable?.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadTxHistory()
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func setupButtonBorder() {
        sendMozoView.roundCorners(cornerRadius: 0.149, borderColor: .white, borderWidth: 1)
        sendMozoView.layer.cornerRadius = 18
        paymentRequestView.roundCorners(cornerRadius: 0.149, borderColor: .white, borderWidth: 1)
        paymentRequestView.layer.cornerRadius = 18
        
        if infoViewBorder == nil {
            infoViewBorder = UIView(frame: CGRect(x: infoView.frame.origin.x - 2, y: infoView.frame.origin.y - 20, width: UIScreen.main.bounds.width - 30 + 4, height: 200))
            infoViewBorder.backgroundColor = .clear
            infoView.superview?.insertSubview(infoViewBorder, belowSubview: infoView)
        }
        
        infoViewBorder.dropShadow()
        infoViewBorder.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        infoViewBorder.layer.shadowRadius = 2.0
        infoViewBorder.layer.shadowColor = UIColor(hexString: "a8c5ec").cgColor
        
        infoView.roundCorners(cornerRadius: 0.015, borderColor: ThemeManager.shared.disable, borderWidth: 0.5)
    }

    func clearValueOnUI() {
        if lbBalance != nil {
            lbBalance.text = "0.0"
            lbBalanceExchange.text = "0.0"
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
            let balanceText = balance.roundAndAddCommas()
            lbBalance.text = balanceText
            var result = "0.0"
            if let rateInfo = SessionStoreManager.exchangeRateInfo {
                let type = CurrencyType(rawValue: rateInfo.currency?.uppercased() ?? "")
                if let type = type, let rateValue = rateInfo.rate, let curSymbol = rateInfo.currencySymbol {
                    let valueText = (balance * rateValue).roundAndAddCommas(toPlaces: type.decimalRound)
                    result = "\(curSymbol)\(valueText)"
                }
            }
            lbBalanceExchange.text = result
        }
    }
    
    func loadTxHistory() {
        print("\(String(describing: self)) - Load display collection item data.")
        _ = MozoSDK.getTxHistoryDisplayCollection().done { (collectionData) in
            self.collection = collectionData
        }.catch({ (error) in
            
        })
    }
    
    func loadDisplayData() {
        // Clear all data
        clearValueOnUI()
        if !isAnonymous {
            loadTxHistory()
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
            bringSubview(toFront: refreshView!)
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
    
    func copyAddressAndShowHud() {
        UIPasteboard.general.string = btnAddress.titleLabel?.text
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
}
extension MozoUserWalletView : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
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
