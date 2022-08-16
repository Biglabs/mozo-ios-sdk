//
//  ChangePINProcessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/12/19.
//

import Foundation
class ChangePINProcessViewController: MozoBasicViewController {
    @IBOutlet weak var lbExplainWaiting: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Change Security PIN".localized
        navigationItem.rightBarButtonItem = nil
    }
}
extension ChangePINProcessViewController: ChangePINProcessViewInterface {
    func displayError(_ error: String) {
        displayMozoError(error)
    }
}
