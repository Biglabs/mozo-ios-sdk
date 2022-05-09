//
//  BuyMozoVC.swift
//  MozoSDK
//
//  Created by Min's Macbook on 22/04/2022.
//

import UIKit

class BuyMozoVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var vMozo: UIView!
    @IBOutlet weak var vUSD: UIView!
    
    @IBOutlet weak var lblEnterMozo: UILabel!
    
    @IBOutlet weak var txtMozo: UITextField!
    @IBOutlet weak var txtUSD: UITextField!
    
    @IBOutlet weak var btPaymentPaypal: UIButton!

    var USD = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()
    }

    func customView() {
        self.vUSD.setCornerRadius(5.0)
        self.vMozo.setCornerRadius(5.0)
        self.btPaymentPaypal.setCornerRadius(5.0)

        self.lblTitle.text = "Buy Mozo".localized
        
        self.lblEnterMozo.text = "Nhập số lượng Mozo cần mua"
        
        self.btPaymentPaypal.setTitle("Thanh toán bằng Paypal", for: .normal)
        self.btPaymentPaypal.setTitleColor(.white, for: .normal)

        self.txtMozo.keyboardType = .numberPad
        self.txtMozo.delegate = self
        self.txtMozo.addTarget(self, action: #selector(self.searchDidChange(_:)), for: .editingChanged)

        self.txtUSD.isUserInteractionEnabled = false

    }
    
    @objc func searchDidChange(_ sender: UITextField) {
        if sender.text != "" {
//            self.txtUSD.text = "\(self.rateToken.rate * (sender.text?.toDoubleValue())!)"
            self.USD = self.txtUSD.text!
        }else {
            self.txtUSD.text = "0.0"
        }
    }


    //MARK: - Action
    @IBAction func didClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPayment(_ sender: Any) {
        
    }
}

extension BuyMozoVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.txtMozo.text = ""
    }
}
