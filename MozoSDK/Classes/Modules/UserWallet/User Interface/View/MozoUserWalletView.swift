//
//  MozoUserWalletView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/15/18.
//

import Foundation
import MBProgressHUD
import UIKit

let TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER = "TxHistoryTableViewCell"
let HEADER_MOZO_USER_WALLET_TABLE_VIEW_CELL_IDENTIFIER = "HeaderMozoUserWalletTableViewCell"

@IBDesignable class MozoUserWalletView: MozoView {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentControlHeightConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var historyLoading: UIActivityIndicatorView!
    @IBOutlet weak var historyTable: UITableView!
    
    @IBOutlet weak var onchainDetectedView: UIView!
    @IBOutlet weak var onchainDetectedViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
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
    
    // Default is 20, 113 if offchain wallet contains onchain tokens, 82 if offchain wallet is converting...
    let topConstraintDefault = 20
    let topConstraintWithAction = 113
    let topConstraintConverting = 82
    
    var hud: MBProgressHUD?
    
    let onchainWalletView = MozoOnchainWalletView.init(frame: CGRect(x: 0, y: 66, width: UIScreen.main.bounds.width, height: 650))
    
    var displayItem : DetailInfoDisplayItem?
    var collection : TxHistoryDisplayCollection? {
        didSet {
            historyTable.reloadData()
        }
    }
    
    var offchainInfo: OffchainInfoDTO?
    private var refreshView : MozoRefreshView?
    private var isAnonymous: Bool = false
    private var mozoToday: NSNumber = 0
    
    override func identifier() -> String {
        return "MozoUserWalletView"
    }
    
    override func loadViewFromNib() {
        isAnonymous = AccessTokenManager.getAccessToken() == nil || SessionStoreManager.loadCurrentUser() == nil
        super.loadViewFromNib()
        
        #if !TARGET_INTERFACE_BUILDER
        loadTokenInfo()
        loadDisplayData()
        setupTableView()
        setupSegment()
        setupLayout()
        setupTarget()
        setupOnchainWalletView()
        setupObservers()
        #endif
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
        historyTable.register(UINib(nibName: HEADER_MOZO_USER_WALLET_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: HEADER_MOZO_USER_WALLET_TABLE_VIEW_CELL_IDENTIFIER)
        historyTable.register(UINib(nibName: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER)
        historyTable.dataSource = self
        historyTable.delegate = self
        historyTable.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        historyTable.refreshControl = refreshControl
        
        setupNoContentView()
    }
    
    func setupSegment() {
        segmentControl.setTitle("Offchain Wallet".localized, forSegmentAt: 0)
        segmentControl.setTitle("Onchain Wallets".localized, forSegmentAt: 1)
        segmentControl.addUnderLines()
    }
    
    func setupLayout() {
        
        topConstraint.constant = CGFloat(topConstraintDefault)
        
        onchainDetectedView.roundCorners(cornerRadius: 0.015, borderColor: UIColor(hexString: "80a9e0"), borderWidth: 0.5)
        onchainDetectedView.layer.cornerRadius = 5
        
        let imgArrow = UIImage(named: "ic_left_arrow", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgViewArrow.image = imgArrow
        imgViewArrow.tintColor = UIColor(hexString: "4e94f3")
        imgViewArrow.transform = imgViewArrow.transform.rotated(by: CGFloat.pi)
    }
    
    func setupTarget() {
        
        
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
        loadSummary()
    }
    
    func loadDisplayData() {
        // Clear all data
        if !isAnonymous {
            refresh()
        }
    }
    

    func updateData(displayItem: DetailInfoDisplayItem) {
        self.displayItem = displayItem
    }
    
    
    func loadTxHistory() {
        _ = MozoSDK.getTxHistoryDisplayCollection().done { (collectionData) in
            self.collection = collectionData
            self.historyLoading.isHidden = true
            self.historyTable.refreshControl?.endRefreshing()
        }.catch({ (error) in
            
            self.historyTable.refreshControl?.endRefreshing()
        })
    }
        
    func loadOnchainInfo() {
        /**
         * Detect Onchain MozoX inside Offchain Wallet Address
         * */
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
    }
    
    func loadTokenInfo() {
        _ = MozoSDK.loadBalanceInfo().done({ (displayItem) in
            self.updateData(displayItem: displayItem)
            self.hideRefreshState()
        }).catch({ (error) in
            self.updateData(displayItem: DetailInfoDisplayItem(balance: 0.0, address: ""))
            self.displayRefreshState()
        })
    }
    
    func loadSummary() {
        _ = ApiManager.shared.getSummary().done({ mozoToday in
            self.mozoToday = mozoToday
        })
    }
        
    func displayRefreshState() {
        if refreshView == nil {
            refreshView = MozoRefreshView(frame: UIScreen.main.bounds)
            refreshView!.delegate = self
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
            refreshView?.isHidden = true
            refreshView?.isRefreshing = false
        }
    }
        
    func showHud() {
        hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.mode = .text
        hud?.label.text = "Copied to clipboard".localized
        hud?.label.textColor = .white
        hud?.label.numberOfLines = 2
        hud?.offset = CGPoint(x: 0, y: -300)
        hud?.bezelView.color = UIColor(hexString: "333333")
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
        return collection != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return collection?.displayItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HEADER_MOZO_USER_WALLET_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! HeaderMozoUserWalletTableViewCell

            cell.delegate = self
            if let balance = self.displayItem?.balance {
                cell.customAttributedTextMozoTotal(mozo: balance)
                cell.customAttributedTextMozoToday(mozo: Double(truncating: self.mozoToday))
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! TxHistoryTableViewCell
        let item = (collection?.displayItems[indexPath.row])!
        cell.txHistory = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300.0
        }
        return 61
    }
}

extension MozoUserWalletView: HeaderMozoUserWalletTableViewCellDelegate {
    func didRequest() {
        MozoSDK.displayPaymentRequest()
    }
    
    func didBuy() {
        let topVC = DisplayUtils.getTopViewController()
        let vc = BuyMozoVC(nibName: "BuyMozoVC", bundle: BundleManager.mozoBundle())
        vc.modalPresentationStyle = .fullScreen
        topVC?.present(vc, animated: true, completion: nil)
    }
    
    func didInfo() {
        let topVC = DisplayUtils.getTopViewController()
        let vc = MozoAddressWalletVC(nibName: "MozoAddressWalletVC", bundle: BundleManager.mozoBundle())
        vc.displayItem = self.displayItem
        topVC?.present(vc, animated: true, completion: nil)
    }
    
    func didSend() {
        MozoSDK.transferMozo()
    }
    
    func didAllHistory() {
        MozoSDK.displayTransactionHistory()
    }
}

extension MozoUserWalletView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section != 0 {
            if let selectedItem = collection?.displayItems[indexPath.row] {
                if let tokenInfo = SessionStoreManager.tokenInfo {
                    MozoSDK.displayTransactionDetail(txHistory: selectedItem, tokenInfo: tokenInfo)
                }
            }
        }
    }
}
extension MozoUserWalletView: MozoRefreshViewDelegate {
    func didRefresh() {
        self.refresh(nil)
    }
}
