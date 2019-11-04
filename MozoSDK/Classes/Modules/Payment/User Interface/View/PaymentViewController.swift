//
//  PaymentViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
enum PaymentTab: Int {
    case List = 0
    case Create = 1
}
class PaymentViewController: MozoBasicViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    // MARK: Payment List
    @IBOutlet weak var listContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButtonView: UIView!
    @IBOutlet weak var btnScan: UIButton!
    // MARK: Create Request
    @IBOutlet weak var createContainerView: UIView!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lbExchange: UILabel!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var constraintTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintListContainerViewHeight: NSLayoutConstraint!
    
    var noticeEmptyView: UIView!
    
    private var gradient: CAGradientLayer!
    let defaultTableViewBottomConstant : CGFloat = 20
    var lastOffsetY :CGFloat = 0
    
    var eventHandler: PaymentModuleInterface?
    var paymentCollection: PaymentRequestDisplayCollection? {
        didSet {
            tableView.reloadData()
        }
    }
    var tokenInfo: TokenInfoDTO?
    var currentPage : Int = 0
    var loadingPage : Int = 0
    private let refreshControl = UIRefreshControl()
    private var isLoadingMore = false
    var currentTab = PaymentTab.List {
        didSet {
            updateLayout()
        }
    }
    
    override func viewDidLoad() {
        print("PaymentViewController - View did load")
        super.viewDidLoad()
        setupNoticeEmptyView()
        eventHandler?.loadTokenInfo()
        setupSegment()
        setupTableView()
        setupTarget()
        setupBorder()
        checkDisableButtonSend()
        loadRequestWithPage(page: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Request MozoX".localized
    }
    
    func checkDisableButtonSend(_ text: String = "") {
        if !text.isEmpty, let value = Double(text.toTextNumberWithoutGrouping()), value > 0 {
            btnCreate.isUserInteractionEnabled = true
            btnCreate.backgroundColor = ThemeManager.shared.main
        } else {
            btnCreate.isUserInteractionEnabled = false
            btnCreate.backgroundColor = ThemeManager.shared.disable
        }
    }
    
    func setupSegment() {
        segmentControl.setTitle("Requested List".localized, forSegmentAt: 0)
        segmentControl.setTitle("Create Request".localized, forSegmentAt: 1)
        
        if #available(iOS 13.0, *) {
            self.segmentControl.selectedSegmentTintColor = ThemeManager.shared.primary
        }
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.shared.primary], for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .highlighted)
    }
    
    func setupTarget() {
        segmentControl.addTarget(self, action: #selector(self.segmmentControlChanged), for: .valueChanged)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidChange), for: UIControlEvents.editingChanged)
        txtAmount.delegate = self
        txtAmount.doneAccessory = true
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: PAYMENT_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: PAYMENT_TABLE_VIEW_CELL_IDENTIFIER)
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.tableView?.refreshControl = refreshControl
        } else {
            self.tableView?.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        containerButtonView.backgroundColor = UIColor(white: 1, alpha: 0.7)
    }
    
    @objc func refresh(_ sender: Any? = nil) {
        loadRequestWithPage(page: 0)
        if let refreshControl = sender as? UIRefreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func loadRequestWithPage(page: Int) {
        eventHandler?.updateDisplayData(page: page)
        loadingPage = page
    }
    
    func setupBorder() {
        let image = UIImage(named: "ic_scan", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        btnScan.setImage(image, for: .normal)
        btnScan.tintColor = .white
        btnScan.roundCorners(cornerRadius: 0.02, borderColor: .white, borderWidth: 0.1)
        btnCreate.roundCorners(cornerRadius: 0.02, borderColor: .white, borderWidth: 0.1)
    }
    
    @objc func segmmentControlChanged() {
        print("Segment did change value")
        let currentIndex = segmentControl.selectedSegmentIndex
        if let tab = PaymentTab(rawValue: currentIndex) {
            currentTab = tab
        }
    }
    
    func updateLayout() {
        switch currentTab {
        case .List:
            view.insertSubview(listContainerView, aboveSubview: createContainerView)
            refresh()
        case .Create:
            view.insertSubview(createContainerView, aboveSubview: listContainerView)
        }
    }
    
    @objc func textFieldAmountDidChange() {
        print("TextFieldAmountDidChange")
        let originalText = txtAmount.text ?? "0"
        let text = originalText.toTextNumberWithoutGrouping()
        
        let amountNumber = text.isEmpty ? 0 : NSDecimalNumber(string: text)
        txtAmount.text = amountNumber.addCommas()
        if originalText.hasSuffix(NSLocale.current.decimalSeparator ?? ".") {
            txtAmount.text = amountNumber.addCommas() + String(originalText.last!)
        } else if originalText.hasSuffix("\(NSLocale.current.decimalSeparator ?? ".")0") {
            txtAmount.text = amountNumber.addCommas() + String(originalText.suffix(2))
        }
        let value = amountNumber.doubleValue
        
        lbExchange.text = DisplayUtils.getExchangeTextFromAmount(value)
    }
    
    @IBAction func touchedBtnCreate(_ sender: Any) {
        if let text = txtAmount.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let tokenInfo = self.tokenInfo {
                let valueText = text.toTextNumberWithoutGrouping()
                eventHandler?.createPaymentRequest(valueText.toDoubleValue(), tokenInfo: tokenInfo)
            } else {
                displayMozoError("No token info")
            }
        } else {
            displayMozoError("Amount is empty.")
        }
    }
    
    @IBAction func touchedBtnScan(_ sender: Any) {
        if let tokenInfo = self.tokenInfo {
            eventHandler?.openScanner(tokenInfo: tokenInfo)
        } else {
            displayMozoError("No token info")
        }
    }
    
    // MARK: Empty View
    
    func setupNoticeEmptyView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: listContainerView.frame.size.height)
        noticeEmptyView = UIView(frame: frame)
        
        let image = UIImage(named: "img_no_request", in: BundleManager.mozoBundle(), compatibleWith: nil)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 145, width: 160, height: 160))
        imageView.image = image
        imageView.roundCorners(cornerRadius: 0.5, borderColor: .clear, borderWidth: 0.1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 40, height: 20))
        label.textAlignment = .center
        label.text = "Requested List is empty or your connection is too slow".localized
        label.textColor = ThemeManager.shared.textSection
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 92, height: 30))
        description.textAlignment = .center
        description.text = "Any MozoX Request from your friends will be displayed here.".localized
        description.textColor = ThemeManager.shared.textSection
        description.font = UIFont.systemFont(ofSize: 13)
        description.numberOfLines = 4
        description.translatesAutoresizingMaskIntoConstraints = false
        
        noticeEmptyView.addSubview(imageView)
        noticeEmptyView.addSubview(label)
        noticeEmptyView.addSubview(description)
        
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
            NSLayoutConstraint(item: description, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: frame.width - 92)
            ])
    }
    
    func checkShowNoContent() {
        if self.paymentCollection?.displayItems.count ?? 0 > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = noticeEmptyView
        }
    }
}
extension PaymentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        if newLength > MAXIMUM_MOZOX_AMOUNT_TEXT_LENGTH {
            return false
        }
        // Validate decimal format
        let finalText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if finalText.isEmpty == false {
            if (finalText.isValidDecimalFormat() == false){
                displayMozoError("Error: Please input value in decimal format.")
                return false
            } else if let value = Decimal(string: finalText.toTextNumberWithoutGrouping()), value.significantFractionalDecimalDigits > tokenInfo?.decimals ?? 0 {
                displayMozoError("Error".localized + ": " + "The length of decimal places must be equal or smaller than %d".localizedFormat(tokenInfo?.decimals ?? 0))
                return false
            }
        }
        checkDisableButtonSend(finalText)
        return true
    }
}
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        checkShowNoContent()
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentCollection?.displayItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PAYMENT_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! PaymentTableViewCell
        let item = (paymentCollection?.displayItems[indexPath.row])!
        cell.paymentItem = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = (paymentCollection?.displayItems[indexPath.row])!
        if let tokenInfo = self.tokenInfo {
            eventHandler?.selectPaymentRequestOnUI(item, tokenInfo: tokenInfo)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let deleteItem = paymentCollection?.displayItems[indexPath.row] {
                eventHandler?.deletePaymentRequest(deleteItem)
            }
        }
    }
}
extension PaymentViewController: PaymentViewInterface {
    func updateUserInterfaceWithTokenInfo(_ tokenInfo: TokenInfoDTO) {
        self.tokenInfo = tokenInfo
    }
    
    func showPaymentRequestCollection(_ collection: PaymentRequestDisplayCollection, forPage: Int) {
        if forPage > currentPage {
            if collection.displayItems.count > 1 {
                // Append to current collection
                paymentCollection?.appendCollection(collection)
                currentPage = forPage
                isLoadingMore = false
            }
        } else {
            currentPage = 0
            paymentCollection = collection
        }
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner(hidesBackButton: true)
    }
    
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displayTryAgain(_ error: ConnectionError) {
        DisplayUtils.displayTryAgainPopup(error: error, delegate: self)
    }
}
extension PaymentViewController: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        
    }
    
    func didClosePopupWithoutRetry() {
        
    }
}
extension PaymentViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        if scrollView == tableView {
            var shouldChange = false
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                shouldChange = true
                if !isLoadingMore, let paymentCollection = self.paymentCollection, paymentCollection.displayItems.count > 0 {
                    let nextPage = currentPage + 1
                    print("Load more request with next page: \(nextPage)")
                    isLoadingMore = true
                    loadRequestWithPage(page: nextPage)
                }
            }
            constraintTableViewBottom.constant = shouldChange ? constraintListContainerViewHeight.constant : defaultTableViewBottomConstant
        }
    }
}
