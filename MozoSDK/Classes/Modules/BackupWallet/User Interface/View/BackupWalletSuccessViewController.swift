//
//  BackupWalletSuccessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation

class BackupWalletSuccessViewController: MozoBasicViewController {
    @IBOutlet weak var btnGotIt: UIButton!
    var eventHandler: BackupWalletModuleInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
        navigationItem.rightBarButtonItem = nil
    }
    
    func updateLayout() {
        btnGotIt.roundCorners(cornerRadius: 0.015, borderColor: .clear, borderWidth: 0.1)
        btnGotIt.layer.cornerRadius = 5
    }
    
    @IBAction func touchBtnGotIt(_ sender: Any) {
        
    }
}
