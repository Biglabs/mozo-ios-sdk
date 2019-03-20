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
    
    @IBOutlet weak var labelActionComplete: UILabel!
    
    @IBOutlet weak var txCompletionView: UIView!
    
    @IBOutlet weak var txCpAddressLabel: UILabel!
    
    @IBOutlet weak var txStatusView: UIView!
    @IBOutlet weak var txStatusImg: UIImageView!
    @IBOutlet weak var txStatusReplaceImg: UIImageView!
    @IBOutlet weak var txStatusLabel: UILabel!
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbAmountEx: UILabel!
    @IBOutlet weak var lbAddress: CopyableLabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnDetail: UIButton!
    
    var stopWaiting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBtnLayer()
        startSpinnerAnimation()
        updateView()
        eventHandler?.requestWaitingForTxStatus(hash: detailItem.hash)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Send MozoX".localized
        checkAddressBook()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            print("View controller was popped")
            eventHandler?.requestStopWaiting()
        }
    }
    
    func checkAddressBook() {
        print("Check address book")
        // No need to show before waiting completed.
        if stopWaiting {
            // Check address book
            // Verify address is existing in address book list or not
            let contain = AddressBookDTO.arrayContainsItem(detailItem.addressTo, array: SafetyDataManager.shared.addressBookList) ||
                StoreBookDTO.arrayContainsItem(detailItem.addressTo, array: SafetyDataManager.shared.storeBookList)
            if contain {
                lbAddress.text = DisplayUtils.buildNameFromAddress(address: detailItem.addressTo)
            } else {
                lbAddress.text = detailItem.addressTo
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
        
        if let rateInfo = SessionStoreManager.exchangeRateInfo {
            if let type = CurrencyType(rawValue: rateInfo.currency ?? ""), let curSymbol = rateInfo.currencySymbol {
                let exValue = (detailItem.amount * (rateInfo.rate ?? 0)).rounded(toPlaces: type.decimalRound)
                let exValueStr = "(\(curSymbol)\(exValue))"
                lbAmountEx.text = exValueStr
            }
        }
    }
    
    func startSpinnerAnimation() {
        rotateView()
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.txStatusImg.transform = self.txStatusImg.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopWaiting {
                self.rotateView(duration: duration)
            } else {
                self.txStatusImg.transform = .identity
            }
        }
    }
    
    func stopSpinnerAnimation(completion: (() -> Swift.Void)? = nil) {
        self.stopWaiting = true
        txStatusImg.isHidden = true
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
