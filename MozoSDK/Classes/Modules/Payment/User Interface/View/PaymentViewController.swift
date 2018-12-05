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
    var paymentCollection: PaymentRequestDisplayCollection?
    var tokenInfo: TokenInfoDTO?
    var currentPage : Int = 1
    var loadingPage : Int = 1
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Payment Request"
    }
    
    func setupTarget() {
        segmentControl.addTarget(self, action: #selector(self.segmmentControlChanged), for: .valueChanged)
        txtAmount.addTarget(self, action: #selector(textFieldAmountDidChange), for: UIControlEvents.editingChanged)
        txtAmount.delegate = self
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
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
        btnScan.imageView?.tintColor = .white
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
            eventHandler?.createPaymentRequest(Double(text) ?? 0)
        } else {
            displayMozoError("Amount is empty.")
        }
    }
    
    @IBAction func touchedBtnScan(_ sender: Any) {
        eventHandler?.openScanner()
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
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            currentPage = 1
            paymentCollection = collection
        }
    }
    
    func showNoContent() {
        
    }
    
    func displaySpinner() {
        displayMozoSpinner()
    }
    
    func removeSpinner() {
        removeMozoSpinner()
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
