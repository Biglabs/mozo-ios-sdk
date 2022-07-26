//
//  TxHistoryViewController.swift
//  MozoSDK
//
//  Created by HoangNguyen on 10/2/18.
//

import Foundation
import UIKit

class TxHistoryViewController: MozoBasicViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var eventHandler: TxHistoryModuleInterface?
    
    private let ROW_HEIGHT: CGFloat = 61
    private var isLoadingMoreTH = false
    
    private let segment = UISegmentedControl(items: ["All".localized, "Received".localized, "Sent".localized])
    private var noticeEmptyView: UIView!
    private var tokenInfo: TokenInfoDTO?
    
    private var dataAll: TxHistoryDisplayCollection?
    private var dataReceived: TxHistoryDisplayCollection?
    private var dataSent: TxHistoryDisplayCollection?
    
    private var pageAll: Int = 0
    private var pageReceived: Int = 0
    private var pageSent: Int = 0
    
    private var canLoadMoreAll: Bool = true
    private var canLoadMoreReceived: Bool = true
    private var canLoadMoreSent: Bool = true
    
    private var isLoadingChanged: Bool = false
    private var filterType : TransactionType = .All
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.prompt = "Transaction History".localized
        navigationItem.hidesBackButton = true
        
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0
        if #available(iOS 13.0, *) {
            segment.largeContentTitle = "Transaction History".localized
            segment.selectedSegmentTintColor = ThemeManager.shared.primary
        } else {
           segment.tintColor = ThemeManager.shared.primary
        }
        segment.setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ],
            for: .selected
        )
        segment.setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor: ThemeManager.shared.textSection
            ],
            for: .normal
        )
        segment.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segment
        
        setupNoticeEmptyView()
        definesPresentationContext = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView?.refreshControl = refreshControl
        self.tableView.applyFooterLoadingView()
        
        tableView.register(UINib(nibName: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        eventHandler?.loadTokenInfo()
        loadHistoryWithPage()
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        pageCollection(0)
        loadHistoryWithPage()
    }
    
    func loadHistoryWithPage() {
        eventHandler?.updateDisplayData(page: pageCollection(), type: filterType)
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
        label.text = "history_empty_title".localized
        label.textColor = ThemeManager.shared.textSection
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 92, height: 30))
        description.textAlignment = .center
        description.text = "history_empty_content".localized
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
    
    private func dataCollection() -> TxHistoryDisplayCollection? {
        switch filterType {
        case .Received:
            return dataReceived
        case .Sent:
            return dataSent
        default:
            return dataAll
        }
    }
    
    private func dataCollection(_ newData: TxHistoryDisplayCollection) {
        switch filterType {
        case .Received:
            dataReceived = newData
        case .Sent:
            dataSent = newData
        default:
            dataAll = newData
        }
    }
    
    private func pageCollection() -> Int {
        switch filterType {
        case .Received:
            return pageReceived
        case .Sent:
            return pageSent
        default:
            return pageAll
        }
    }
    
    private func pageCollection(_ newPage: Int) {
        switch filterType {
        case .Received:
            pageReceived = newPage
        case .Sent:
            pageSent = newPage
        default:
            pageAll = newPage
        }
    }
    
    private func canLoadMore() -> Bool {
        switch filterType {
        case .Received:
            return canLoadMoreReceived
        case .Sent:
            return canLoadMoreSent
        default:
            return canLoadMoreAll
        }
    }
    
    private func canLoadMore(_ loadMore: Bool) {
        switch filterType {
        case .Received:
            canLoadMoreReceived = loadMore
        case .Sent:
            canLoadMoreSent = loadMore
        default:
            canLoadMoreAll = loadMore
        }
    }
    
    @objc func touchBtnGoToWallet() {
        ModuleDependencies.shared.corePresenter.requestForCloseAllMozoUIs(nil)
    }
    
    func checkShowNoContent() {
        tableView.backgroundView = (dataCollection()?.displayItems.count ?? 0) > 0 ? noticeEmptyView : nil
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!) {
        switch sender.selectedSegmentIndex {
        case 1:
            filterType = .Received
        case 2:
            filterType = .Sent
        default:
            filterType = .All
        }
        tableView.refreshControl?.beginRefreshing()
        isLoadingChanged = true
        tableView.reloadData()
        
        if dataCollection() == nil {
            loadHistoryWithPage()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.isLoadingChanged = false
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            })
        }
    }
}
// MARK: - Table View
extension TxHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoadingChanged ? 0 : (dataCollection()?.displayItems.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TX_HISTORY_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! TxHistoryTableViewCell
        cell.type = filterType
        cell.txHistory = dataCollection()?.displayItems.getElement(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
}

extension TxHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedItem = dataCollection()?.displayItems.getElement(indexPath.row), let tokenInfo = tokenInfo {
            eventHandler?.selectTxHistoryOnUI(selectedItem, tokenInfo: tokenInfo, type: filterType)
        }
    }
}

extension TxHistoryViewController : TxHistoryViewInterface {
    func didReceiveTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
    }
    
    func showTxHistoryDisplayData(_ data: TxHistoryDisplayCollection, forPage: Int) {
        isLoadingChanged = false
        isLoadingMoreTH = false
        segment.isEnabled = true
        tableView.tableFooterView?.isHidden = true
        
        canLoadMore(data.displayItems.count == Configuration.PAGING_SIZE)
        
        if pageCollection() == 0 {
            dataCollection(data)
        } else {
            dataCollection()?.appendCollection(data)
        }
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
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
                if !isLoadingMoreTH && dataCollection() != nil && canLoadMore() {
                    isLoadingMoreTH = true
                    segment.isEnabled = false
                    tableView.tableFooterView?.isHidden = false
                    pageCollection(pageCollection() + 1)
                    loadHistoryWithPage()
                }
            }
        }
    }
}
extension TxHistoryViewController : PopupErrorDelegate {
    func didClosePopupWithoutRetry() {
        
    }
    
    func didTouchTryAgainButton() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
            self.eventHandler?.loadTokenInfo()
            self.loadHistoryWithPage()
        }
    }
}
