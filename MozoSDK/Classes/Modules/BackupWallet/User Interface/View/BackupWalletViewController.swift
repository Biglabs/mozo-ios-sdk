//
//  BackupWalletViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class BackupWalletViewController: MozoBasicViewController {
    @IBOutlet weak var mnemonicsView: MnemonicsView!
    @IBOutlet weak var btnFinish: UIButton!
    var eventHandler: BackupWalletModuleInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
        navigationController?.isNavigationBarHidden = false
    }
    
    func updateLayout() {
        btnFinish.roundCorners(cornerRadius: 0.015, borderColor: .clear, borderWidth: 0.1)
        btnFinish.layer.cornerRadius = 5
        let index1st = Int.random(in: 1...6)
        var index2nd = Int.random(in: 1...6)
        while index2nd == index1st {
            index2nd = Int.random(in: 1...6)
        }
        let index3rd = Int.random(in: 7...12)
        var index4th = Int.random(in: 7...12)
        while index4th == index3rd {
            index4th = Int.random(in: 7...12)
        }
        mnemonicsView.setIndexRandomly(true, randomIndexs: [index1st, index2nd, index3rd, index4th])
    }
    
    @IBAction func touchBtnFinish(_ sender: Any) {
        
    }
}
extension BackupWalletViewController: BackupWalletViewInterface {
    
}
