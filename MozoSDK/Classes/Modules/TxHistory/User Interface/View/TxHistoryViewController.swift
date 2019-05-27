//
//  TxHistoryViewController.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation
import UIKit

class TxHistoryViewController: MozoBasicViewController {
    var eventHandler: TxHistoryModuleInterface?
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnFloatingAll: UIButton!
    @IBOutlet weak var btnFloatingReceived: UIButton!
    @IBOutlet weak var btnFloatingSent: UIButton!
    
    var noticeEmptyView: UIView!
    
    private let refreshControl = UIRefreshControl()
    private var isLoadingMoreTH = false
    private var isFiltering = false
    
    var collection : TxHistoryDisplayCollection?
    var filteredItems = [TxHistoryDisplayItem]()
    var currentPage : Int = 0
    var loadingPage : Int = 0
    var currentFilterType : TransactionType? = nil {
        didSet {
            print("Set current filter type: \(currentFilterType)")
        }
    }
    var tokenInfo : TokenInfoDTO?
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNoticeEmptyView()
        definesPresentationContext = true
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.tableView?.refreshControl = refreshControl
        } else {
            self.tableView?.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.applyFooterLoadingView()
        
        tableView.register(UINib(nibName: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER)
        setLayerBorder()
        eventHandler?.loadTokenInfo()
        loadHistoryWithPage(page: currentPage)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadHistoryWithPage(page: 0)
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
//        updateDisplayButtons()
//        filterContentForType()
    }
    
    func loadHistoryWithPage(page: Int) {
        eventHandler?.updateDisplayData(page: page)
        loadingPage = page
    }
    
    func setLayerBorder() {
        btnFloatingAll.roundCorners(cornerRadius: 0.15, borderColor: .clear, borderWidth: 0)
        btnFloatingReceived.roundCorners(cornerRadius: 0.15, borderColor: .clear, borderWidth: 0)
        btnFloatingSent.roundCorners(cornerRadius: 0.15, borderColor: .clear, borderWidth: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Transaction History".localized
        // Fix issue: Back button show up after going back from transaction detail controller
        self.navigationItem.hidesBackButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private instance methods
    
    func filterContentForType(_ type: TransactionType? = nil) {
        if collection == nil || collection?.displayItems.count == 0 {
            return
        }
        isFiltering = false
        if type != nil {
            isFiltering = true
            filteredItems = (collection?.filterByTransactionType(type!))!
        }
        tableView.reloadData()
    }
    
    // MARK: Empty View
    
    func setupNoticeEmptyView() {
        let frame = view.frame
        noticeEmptyView = UIView(frame: frame)
        
        let image = UIImage(named: "img_no_tx_history", in: BundleManager.mozoBundle(), compatibleWith: nil)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 145, width: 160, height: 160))
        imageView.image = image
        imageView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 40, height: 20))
        label.textAlignment = .center
        label.text = "Transaction History is emtpy or your connection is too slow".localized
        label.textColor = ThemeManager.shared.textSection
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 92, height: 30))
        description.textAlignment = .center
        description.text = "Transfer MozoX to your friends or request them to send you MozoX.".localized
        description.textColor = ThemeManager.shared.textSection
        description.font = UIFont.systemFont(ofSize: 13)
        description.numberOfLines = 4
        description.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 295, height: 48))
        button.setTitle("Go to Wallet".localized, for: .normal)
        button.backgroundColor = UIColor(hexString: "4e94f3")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font =  .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(touchBtnGoToWallet), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
        
        noticeEmptyView.addSubview(imageView)
        noticeEmptyView.addSubview(label)
        noticeEmptyView.addSubview(description)
        noticeEmptyView.addSubview(button)
        
        noticeEmptyView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.noticeEmptyView, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.noticeEmptyView, attribute: .top, multiplier: 1.0, constant: 145),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 160),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 160),
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.noticeEmptyView, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: frame.width - 40),
            NSLayoutConstraint(item: description, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: description, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1.0, constant: 24),
            NSLayoutConstraint(item: description, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: frame.width - 92),
            NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: description, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: description, attribute: .bottom, multiplier: 1.0, constant: 40),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 295),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 48),
            ])
    }
    
    @objc func touchBtnGoToWallet() {
        if let navigationController = self.navigationController as? MozoNavigationController, let coreEventHandler = navigationController.coreEventHandler {
            coreEventHandler.requestForCloseAllMozoUIs()
        }
    }
    
    func checkShowNoContent() {
        if self.collection?.displayItems.count ?? 0 > 0 {
            tableView.backgroundView = nil
            floatingView.isHidden = false
            floatingViewHeightConstraint.constant = 111
        } else {
            tableView.backgroundView = noticeEmptyView
            floatingView.isHidden = true
            floatingViewHeightConstraint.constant = 0
        }
    }
    
    // MARK: Change display of buttons
    func updateDisplayButtons(_ type: TransactionType? = nil) {
        currentFilterType = type
        if type == nil {
            // All
            btnFloatingAll.backgroundColor = ThemeManager.shared.main
            btnFloatingAll.setTitleColor(.white, for: .normal)
            btnFloatingReceived.backgroundColor = ThemeManager.shared.disable
            btnFloatingReceived.setTitleColor(ThemeManager.shared.textSection, for: .normal)
            btnFloatingSent.backgroundColor = ThemeManager.shared.disable
            btnFloatingSent.setTitleColor(ThemeManager.shared.textSection, for: .normal)
        } else if type == .Received {
            // Received
            btnFloatingAll.backgroundColor = ThemeManager.shared.disable
            btnFloatingAll.setTitleColor(ThemeManager.shared.textSection, for: .normal)
            btnFloatingReceived.backgroundColor = ThemeManager.shared.main
            btnFloatingReceived.setTitleColor(.white, for: .normal)
            btnFloatingSent.backgroundColor = ThemeManager.shared.disable
            btnFloatingSent.setTitleColor(ThemeManager.shared.textSection, for: .normal)
        } else {
            // Sent
            btnFloatingAll.backgroundColor = ThemeManager.shared.disable
            btnFloatingAll.setTitleColor(ThemeManager.shared.textSection, for: .normal)
            btnFloatingReceived.backgroundColor = ThemeManager.shared.disable
            btnFloatingReceived.setTitleColor(ThemeManager.shared.textSection, for: .normal)
            btnFloatingSent.backgroundColor = ThemeManager.shared.main
            btnFloatingSent.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: Floating view actions
    @IBAction func touchedBtnFloatingAll(_ sender: Any) {
        updateDisplayButtons()
        filterContentForType()
    }
    
    @IBAction func touchedBtnFloatingReceived(_ sender: Any) {
        updateDisplayButtons(.Received)
        filterContentForType(.Received)
    }
    
    @IBAction func toucheBtnFloatingSent(_ sender: Any) {
        updateDisplayButtons(.Sent)
        filterContentForType(.Sent)
    }
}
// MARK: - Table View
extension TxHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        checkShowNoContent()
        return collection != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        }

        return collection?.displayItems.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! TxHistoryTableViewCell
        let item: TxHistoryDisplayItem
        if isFiltering {
            item = filteredItems[indexPath.row]
        } else {
            item = (collection?.displayItems[indexPath.row])!
        }
        cell.txHistory = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}

extension TxHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedItem = isFiltering ? filteredItems[indexPath.row] : collection?.displayItems[indexPath.row], let tokenInfo = tokenInfo {
            eventHandler?.selectTxHistoryOnUI(selectedItem, tokenInfo: tokenInfo)
        }
    }
}

extension TxHistoryViewController : TxHistoryViewInterface {
    func didReceiveTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
    }
    
    func showTxHistoryDisplayData(_ data: TxHistoryDisplayCollection, forPage: Int) {
        tableView.tableFooterView?.isHidden = true
        if forPage > currentPage {
            isLoadingMoreTH = false
            if data.displayItems.count > 0 {
                // Append to current collection
                collection?.appendCollection(data)
                currentPage = forPage
            }
        } else {
            currentPage = 0
            isFiltering = false
            collection = data
        }
        // Check current filter type
        filterContentForType(currentFilterType)
    }
    
    func showNoContentMessage() {
        
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
        navigationItem.hidesBackButton = true
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displayTryAgain(_ error: ConnectionError) {
        DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
    }
}
extension TxHistoryViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Bottom Refresh
        if scrollView == tableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if !isLoadingMoreTH && collection != nil && (collection?.displayItems.count)! > 0 {
                    tableView.tableFooterView?.isHidden = false
                    let nextPage = currentPage + 1
                    print("Load more transaction histories with next page: \(nextPage)")
                    isLoadingMoreTH = true
                    loadHistoryWithPage(page: nextPage)
                }
            }
        }
    }
}
extension TxHistoryViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        print("User try reload transaction history again.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.loadTokenInfo()
            self.loadHistoryWithPage(page: self.loadingPage)
        }
    }
}
