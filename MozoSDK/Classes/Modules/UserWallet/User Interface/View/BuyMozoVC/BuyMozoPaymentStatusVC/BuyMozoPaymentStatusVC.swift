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
        self.rootView.setCornerRadius(24.0)
         
        if isSuccess {
            self.imgStatus.image = UIImage(named: "ic_success", in: BundleManager.mozoBundle(), compatibleWith: nil)

            self.lblTitleStatus.text = "Thanh toán thành công"
            self.lblContentStatus.text = "Mozo sẽ được cộng vào ví bạn trong\nít phút nữa"
            self.btRetry.isHidden = true
            self.btContinue.isHidden = false
        }else {
            self.imgStatus.image = UIImage(named: "ic_fail", in: BundleManager.mozoBundle(), compatibleWith: nil)
            self.lblTitleStatus.text = "Thanh toán không thành công"
            self.lblContentStatus.text = "Giao dịch thất bại, vui lòng\nthử lại trong giây lát"
            self.btRetry.isHidden = false
            self.btContinue.isHidden = false
        }
        
        self.lblContentStatus.numberOfLines = 2

        self.btRetry.setTitle("Thử lại", for: .normal)
        self.btRetry.setTitleColor(UIColor.init(hexString: "#005CEE"), for: .normal)
        self.btRetry.setCornerRadius(8.0)
        self.btRetry.setBackgroundColor(color: UIColor.init(hexString: "#E6EFFE"), forState: .normal)
        
        self.btContinue.setTitle("Tiếp tục", for: .normal)
        self.btContinue.setTitleColor(.white, for: .normal)
        self.btContinue.setCornerRadius(8.0)
        self.btContinue.setBackgroundColor(color: UIColor.init(hexString: "#005CEE"), forState: .normal)
    }

    //MARK: - Action
    @IBAction func didRetry(_ sender: Any) {
            
    }
    
    @IBAction func didContinue(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
