//
//  BuyMozoPaymentStatusVC.swift
//  Alamofire
//
//  Created by Min's Macbook on 20/05/2022.
//

import UIKit
import Foundation

class BuyMozoPaymentStatusVC: UIViewController {

    @IBOutlet weak var rootView: UIView!
    
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var lblTitleStatus: UILabel!
    @IBOutlet weak var lblContentStatus: UILabel!
    
    @IBOutlet weak var btRetry: UIButton!
    @IBOutlet weak var btContinue: UIButton!
    
    var isSuccess = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()
    }
    
    func customView() {
        self.rootView.layer.cornerRadius = 24.0
        self.rootView.layer.masksToBounds = true
        self.rootView.clipsToBounds = true
        
        if isSuccess {
            self.imgStatus.image = UIImage(named: "ic_fail", in: BundleManager.mozoBundle(), compatibleWith: nil)

            self.lblTitleStatus.text = "Thanh toán thành công"
            self.lblContentStatus.text = "Mozo sẽ được cộng vào ví bạn sau ít phút nữa"
            self.btRetry.isHidden = true
            self.btContinue.isHidden = false
        }else {
            self.imgStatus.image = UIImage(named: "ic_fail", in: BundleManager.mozoBundle(), compatibleWith: nil)
            self.lblTitleStatus.text = "Thanh toán không thành công"
            self.lblContentStatus.text = "Giao dịch thất bại, vui lòng thử lại trong giây lát"
            self.btRetry.isHidden = false
            self.btContinue.isHidden = false
        }
        
        
    }

    //MARK: - Action
    @IBAction func didRetry(_ sender: Any) {
        
    }
    
    @IBAction func didContinue(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
