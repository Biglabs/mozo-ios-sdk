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
    @IBOutlet weak var btnFloatingAll: UIButton!
    @IBOutlet weak var btnFloatingReceived: UIButton!
    @IBOutlet weak var btnFloatingSent: UIButton!
    
    private let refreshControl = UIRefreshControl()
    private var isLoadingMoreTH = false
    private var isFiltering = false
    
    var collection : TxHistoryDisplayCollection?
    var filteredItems = [TxHistoryDisplayItem]()
    var currentPage : Int = 1
    var loadingPage : Int = 1
    var currentFilterType : TransactionType? = nil // All
    var tokenInfo : TokenInfoDTO?
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.tableView?.refreshControl = refreshControl
        } else {
            self.tableView?.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.tableFooterView = UIView()
        
        setLayerBorder()
        eventHandler?.loadTokenInfo()
        loadHistoryWithPage(page: currentPage)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadHistoryWithPage(page: 1)
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        updateDisplayButtons()
        filterContentForType()
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
        self.title = "Transaction History"
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
        return collection != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        }

        return collection?.displayItems.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TxHistoryTableViewCell", for: indexPath) as! TxHistoryTableViewCell
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
        if let selectedItem = collection?.displayItems[indexPath.row], let tokenInfo = tokenInfo {
            eventHandler?.selectTxHistoryOnUI(selectedItem, tokenInfo: tokenInfo)
        }
    }
}

extension TxHistoryViewController : TxHistoryViewInterface {
    func didReceiveTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
    }
    
    func showTxHistoryDisplayData(_ data: TxHistoryDisplayCollection, forPage: Int) {
        if forPage > currentPage {
            if data.displayItems.count > 1 {
                // Append to current collection
                collection?.appendCollection(data)
                currentPage = forPage
                isLoadingMoreTH = false
            }
        } else {
            currentPage = 1
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
        displayMozoPopupError()
        mozoPopupErrorView?.delegate = self
    }
}
extension TxHistoryViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //Bottom Refresh
        if scrollView == tableView {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if !isLoadingMoreTH && collection != nil && (collection?.displayItems.count)! > 0 {
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
    func didTouchTryAgainButton() {
        print("User try reload transaction history again.")
        removeMozoPopupError()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.loadHistoryWithPage(page: self.loadingPage)
        }
    }
}
