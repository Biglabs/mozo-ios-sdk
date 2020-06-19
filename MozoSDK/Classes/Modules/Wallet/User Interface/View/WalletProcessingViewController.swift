//
//  WalletProcessingViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/10/19.
//

import Foundation
enum WalletProcessingRetryAction {
    
}
class WalletProcessingViewController: MozoBasicViewController {
    @IBOutlet weak var imgViewLoading: UIImageView!
    @IBOutlet weak var lbExplainWaiting: UILabel!
    var eventHandler: WalletModuleInterface?
    
    var isCreateNew = false
    
    var stopRotating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotateView()
        let explainText = isCreateNew ? "text_explain_creating_wallet" : "text_explain_recovering_wallet"
        lbExplainWaiting.text = explainText.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let title = isCreateNew ? "title_create_wallet" : "Recover Mozo Wallet"
        navigationItem.title = title.localized
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            stopRotating = true
        }
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.imgViewLoading.transform = self.imgViewLoading.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopRotating {
                self.rotateView(duration: duration)
            } else {
                self.imgViewLoading.transform = .identity
            }
        }
    }
}
extension WalletProcessingViewController: WalletProcessingViewInterface {
    func displayError(_ error: String) {
        displayMozoError(error)
    }
    
    func displayErrorAndLogout(_ error: ErrorApiResponse) {
        displayMozoAlertInfo(infoMessage: error.description) {
            MozoSDK.logout()
        }
    }
}
