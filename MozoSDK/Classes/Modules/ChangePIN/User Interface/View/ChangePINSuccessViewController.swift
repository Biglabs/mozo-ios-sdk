//
//  ChangePINSuccessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINSuccessViewController: MozoBasicViewController {
    @IBOutlet weak var btnDone: UIButton!
    
    var isChangePin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDone.roundCorners(cornerRadius: 0.15, borderColor: .white, borderWidth: 0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Change Security PIN".localized
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func touchBtnDone(_ sender: Any) {
        ModuleDependencies.shared.corePresenter.requestForCloseAllMozoUIs(nil)
    }
}
