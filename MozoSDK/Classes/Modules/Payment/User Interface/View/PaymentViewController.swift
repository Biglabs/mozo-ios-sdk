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
        super.viewDidLoad()
        eventHandler?.loadTokenInfo()
        setupTableView()
        setupTarget()
        setupBorder()
        loadRequestWithPage(page: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Payment Request"
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
        case .Create:
            view.insertSubview(createContainerView, aboveSubview: listContainerView)
        }
    }
    
    @objc func textFieldAmountDidChange() {
        print("TextFieldAmountDidChange")
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? "") {
                let text = txtAmount.text != nil ? (txtAmount.text != "" ? txtAmount.text : "0") : "0"
                let value = Double(text ?? "0")!
                let exValue = (value * (rateInfo.rate ?? 0))
                let exValueStr = "\(type.unit)\(exValue.roundAndAddCommas(toPlaces: type.decimalRound))"
                lbExchange.text = exValueStr
            }
        }
    }
    
    @IBAction func touchedBtnCreate(_ sender: Any) {
        if let text = txtAmount.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            eventHandler?.createPaymentRequest(Double(text) ?? 0, tokenInfo: self.tokenInfo!)
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
}
extension PaymentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Validate decimal format
        let finalText = (textField.text ?? "") + string
        if (finalText.isValidDecimalFormat() == false){
            displayMozoError("Error: Please input value in decimal format.")
            return false
        } else if let value = Decimal(string: finalText), value.significantFractionalDecimalDigits > tokenInfo?.decimals ?? 0 {
            displayMozoError("Error: The length of decimal places must be equal or smaller than \(tokenInfo?.decimals ?? 0).")
            return false
        }
        return true
    }
}
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    func showNoContent() {
        
//        displayMozoNoContentView(listContainerView.frame, message: "Payment request list is empty")
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
