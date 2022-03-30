//
//  TxCompletionViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/25/18.
//

import Foundation
import UIKit

class TxCompletionViewController: MozoBasicViewController {
    var eventHandler : TxCompletionModuleInterface?
    var detailItem: TxDetailDisplayItem!
    
    @IBOutlet weak var completeImageView: UIImageView!
    @IBOutlet weak var completeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var completeImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelActionComplete: UILabel!
    
    @IBOutlet weak var txCompletionView: UIView!
    @IBOutlet weak var txCompletionViewHeightConstraint: NSLayoutConstraint! // Default: 135, with address book: 181
    
    @IBOutlet weak var txCpAddressLabel: UILabel!
    @IBOutlet weak var addressBookView: AddressBookView!
    
    @IBOutlet weak var txStatusView: UIView!
    @IBOutlet weak var txStatusLoading: UIActivityIndicatorView!
    @IBOutlet weak var txStatusReplaceImg: UIImageView!
    @IBOutlet weak var txStatusLabel: UILabel!
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    @IBOutlet weak var lbAddress: CopyableLabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnDetail: UIButton!
    
    var moduleRequest: Module = .Transaction
    
    var stopWaiting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbAmountEx.isHidden = !Configuration.SHOW_MOZO_EQUIVALENT_CURRENCY
        setBtnLayer()
        updateView()
        eventHandler?.requestWaitingForTxStatus(hash: detailItem.hash)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var text = "title_send_mozo"
        switch moduleRequest {
        case .TopUp, .TopUpTransfer:
            text = "Deposit"
        default:
            break
        }
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = text.localized
        checkAddressBook()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            eventHandler?.requestStopWaiting()
        }
    }
    
    func checkAddressBook() {
        print("TxCompletionViewController - Check address book")
        if moduleRequest == .TopUp || moduleRequest == .TopUpTransfer {
            let addressBook = AddressBookDisplayItem.TopUpAddressBookDisplayItem
            addressBookView.isHidden = false
            lbAddress.isHidden = true
            addressBookView.addressBook = addressBook
            addressBookView.btnClear.isHidden = true
            txCompletionViewHeightConstraint.constant = 181
            
            btnSave.isHidden = true
            btnDetail.isHidden = true
            return
        }
        // No need to show before waiting completed.
        if stopWaiting {
            // Check address book
            // Verify address is existing in address book list or not
            let contain = AddressBookDTO.arrayContainsItem(detailItem.addressTo, array: SafetyDataManager.shared.addressBookList) ||
                StoreBookDTO.arrayContainsItem(detailItem.addressTo, array: SafetyDataManager.shared.storeBookList)
            if contain {
//                lbAddress.text = DisplayUtils.buildNameFromAddress(address: detailItem.addressTo)
                if let addressBook = DisplayUtils.buildContactDisplayItem(address: detailItem.addressTo) {
                    addressBookView.isHidden = false
                    lbAddress.isHidden = true
                    addressBookView.addressBook = addressBook
                    addressBookView.btnClear.isHidden = true
                    txCompletionViewHeightConstraint.constant = 181
                }
            } else {
                addressBookView.isHidden = true
                lbAddress.isHidden = false
                lbAddress.text = detailItem.addressTo
                txCompletionViewHeightConstraint.constant = 135
            }
            btnSave.isHidden = contain
            btnDetail.isHidden = false
        } else {
            btnSave.isHidden = true
            btnDetail.isHidden = true
        }
    }
    
    func updateView() {
        lbAmount.text = detailItem.amount.roundAndAddCommas()
        lbAmountEx.text = DisplayUtils.getExchangeTextFromAmount(detailItem.amount)
    }
    
    func stopSpinnerAnimation(completion: (() -> Swift.Void)? = nil) {
        self.stopWaiting = true
        txStatusLoading.isHidden = true
        txStatusReplaceImg.isHidden = false
    }
    
    func setBtnLayer() {
        btnSave.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
        btnDetail.roundCorners(cornerRadius: 0.08, borderColor: ThemeManager.shared.main, borderWidth: 1)
    }
    
    @IBAction func btnSaveTapped(_ sender: Any) {
        eventHandler?.requestAddToAddressBook(detailItem.addressTo)
    }
    
    @IBAction func btnDetailTapped(_ sender: Any) {
        eventHandler?.requestShowDetail(detailItem)
    }
}
extension TxCompletionViewController : TxCompletionViewInterface {
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func updateView(status: TransactionStatusType) {
        print("Update view with transaction status: \(status)")
        stopSpinnerAnimation()
        checkAddressBook()
        switch status {
        case .FAILED:
            txStatusReplaceImg.image = UIImage(named: "ic_failed", in: BundleManager.mozoBundle(), compatibleWith: nil)
            txStatusLabel.text = status.rawValue.lowercased().capitalizingFirstLetter().localized
        case .SUCCESS:
            txStatusView.isHidden = true
            txCompletionView.isHidden = false
            labelActionComplete.text = "Send Complete".localized
//            txStatusReplaceImg.image = UIImage(named: "ic_check_success", in: BundleManager.mozoBundle(), compatibleWith: nil)
        default:
            break;
        }
    }
}
