//
//  MozoSendView.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/26/18.
//

import UIKit

@IBDesignable class MozoSendView: MozoView {
    @IBOutlet weak var button: UIButton!
    
    override func identifier() -> String {
        return "MozoSendView"
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
        MozoSDK.transferMozo()
    }
}
