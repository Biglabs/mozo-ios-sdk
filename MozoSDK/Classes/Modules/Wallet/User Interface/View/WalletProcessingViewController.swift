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
    @IBOutlet weak var lbExplainWaiting: UILabel!
    var eventHandler: WalletModuleInterface?
    
    var isCreateNew = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let explainText = isCreateNew ? "text_explain_creating_wallet" : "text_explain_recovering_wallet"
        lbExplainWaiting.text = explainText.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let title = isCreateNew ? "title_create_wallet" : "Recover Mozo Wallet"
        navigationItem.title = title.localized
        navigationItem.rightBarButtonItem = nil
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
