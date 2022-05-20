//
//  BuyMozoVC.swift
//  MozoSDK
//
//  Created by Min's Macbook on 22/04/2022.
//

import UIKit
import PayPalCheckout

class BuyMozoVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var vMozo: UIView!
    @IBOutlet weak var vUSD: UIView!
    
    @IBOutlet weak var lblEnterMozo: UILabel!
    
    @IBOutlet weak var txtMozo: UITextField!
    @IBOutlet weak var txtUSD: UITextField!
    
    @IBOutlet weak var btPaymentPaypal: UIButton!

    var USD = ""
    var rate: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()
        self.getTokenRate()
    }

    func customView() {
        self.vUSD.setCornerRadius(5.0)
        self.vMozo.setCornerRadius(5.0)
        self.btPaymentPaypal.setCornerRadius(5.0)

        self.lblTitle.text = "btn_buy_mozo".localized
        
        self.lblEnterMozo.text = "input_amount_mozo".localized
        
        self.btPaymentPaypal.setTitle("payment_mozo".localized, for: .normal)
        self.btPaymentPaypal.setTitleColor(.white, for: .normal)

        self.txtMozo.keyboardType = .numberPad
        self.txtMozo.delegate = self
        self.txtMozo.addTarget(self, action: #selector(self.searchDidChange(_:)), for: .editingChanged)

        self.txtUSD.isUserInteractionEnabled = false
    }
    
    @objc func searchDidChange(_ sender: UITextField) {
        if sender.text != "" {
            self.txtUSD.text = "\(self.rate * (sender.text?.toDoubleValue())!)"
            self.USD = self.txtUSD.text!
        }else {
            self.txtUSD.text = "0.0"
        }
    }
    
    func getTokenRate() {
        _ = ApiManager.shared.getEthAndOnchainExchangeRateInfo(locale: "en-US").done({ data in
            self.rate = (data.token?.rate)!
        })
    }

    //MARK: - Action
    @IBAction func didClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPayment(_ sender: Any) {
//        Checkout.start(presentingViewController: self
//            , createOrder: { createOrderAction in
//                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: self.USD)
//                let purchaseUnit = PurchaseUnit(amount: amount)
//                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
//                createOrderAction.create(order: order)
//            }, onApprove: { approval in
//                approval.actions.capture { (response, error) in
//                    print("Order successfully captured: \(response!.data)")
//                }
//            }, onCancel: {
//                // Optionally use this closure to respond to the user canceling the paysheet
//            }, onError: { error in
//                // Optionally use this closure to respond to the user experiencing an error in
//                // the payment experience
//            }
//        )
        let topVC = DisplayUtils.getTopViewController()
        let vc = BuyMozoPaymentStatusVC(nibName: "BuyMozoPaymentStatusVC", bundle: BundleManager.mozoBundle())
        vc.modalPresentationStyle = .fullScreen
        vc.isSuccess = false
        topVC?.present(vc, animated: true, completion: nil)

    }
}

extension BuyMozoVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.txtMozo.text = ""
    }
}
