//
//  AutoPINViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/19/19.
//

import Foundation
class AutoPINViewController: MozoBasicViewController {
    var waitingView: MozoWaitingView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWaitingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func setupWaitingView() {
        waitingView = MozoWaitingView(frame: self.view.frame)
        self.view.addSubview(waitingView)
        waitingView.rotateView()
        waitingView.lbExplain.text = "System is using automatically generated PIN to sign your transaction and send it to network...".localized
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            waitingView.stopRotating = true
            navigationController?.isNavigationBarHidden = false
        }
    }
}
