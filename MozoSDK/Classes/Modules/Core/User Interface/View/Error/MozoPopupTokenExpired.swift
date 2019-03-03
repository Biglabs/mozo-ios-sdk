//
//  MozoPopupTokenExpired.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/1/19.
//

import Foundation

class MozoPopupTokenExpired: MozoView {
    @IBOutlet weak var btnOK: UIButton!
    
    var modalCloseHandler: (() -> Void)?
    
    override func identifier() -> String {
        return "MozoPopupTokenExpired"
    }
    
    override func loadViewFromNib() {
        super.loadViewFromNib()
        setupButton()
    }
    
    func setupButton() {
        btnOK.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 0.1)
    }
    
    @objc
    public func dismissView() {
        modalCloseHandler?()
    }
    
    @IBAction func touchedOkBtn(_ sender: Any) {
        dismissView()
    }
}
