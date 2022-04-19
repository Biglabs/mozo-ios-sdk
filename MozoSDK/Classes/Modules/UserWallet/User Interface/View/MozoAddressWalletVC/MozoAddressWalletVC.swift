//
//  MozoAddressWalletVC.swift
//  MozoSDK
//
//  Created by Min's Macbook on 19/04/2022.
//

import UIKit

class MozoAddressWalletVC: UIViewController {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()
    }

    func customView() {
        self.lineView.setCornerRadius(self.lineView.frame.height/2)
        self.addressView.setCornerRadius(20.0, corners: [.topLeft, .topRight])
    }
}
