//
//  MozoPaymentRequestView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/20/18.
//

@IBDesignable class MozoPaymentRequestView: MozoView {
    @IBOutlet weak var button: UIButton!
    
    override func identifier() -> String {
        return "MozoPaymentRequestView"
    }
    
    override func checkDisable() {
        if SessionStoreManager.isWalletSafe() {
            isUserInteractionEnabled = true
            button.backgroundColor = ThemeManager.shared.main
        } else {
            isUserInteractionEnabled = false
            button.backgroundColor = ThemeManager.shared.disable
        }
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        addUniqueAuthObserver()
        let image = UIImage(named: "ic_receive", in: BundleManager.mozoBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        
        self.roundedCircle()
    }
    
    @IBAction func touchedUpInside(_ sender: Any) {
        MozoSDK.displayPaymentRequest()
    }
}
