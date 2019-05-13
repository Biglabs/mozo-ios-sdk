//
//  ResetPINSuccessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/10/19.
//

import Foundation
import UIKit
class ResetPINSuccessViewController: MozoBasicViewController {
    @IBOutlet weak var btnDone: UIButton!
    var eventHandler: ResetPINModuleInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDone.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reset PIN".localized
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func touchBtnDone(_ sender: Any) {
        eventHandler?.completeResetPIN()
    }
}
