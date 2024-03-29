//
//  MozoTxHistoryView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/2/18.
//

import UIKit

@IBDesignable class MozoTxHistoryView: MozoView {
    @IBOutlet weak var button: UIButton!
    
    override func identifier() -> String {
        return "MozoTxHistoryView"
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
        self.roundedCircle()
    }
    
    @IBAction func touchedUpInside(_ sender: Any) {
        print("Touched Up Inside Button Transaction history")
        MozoSDK.displayTransactionHistory()
    }
}
