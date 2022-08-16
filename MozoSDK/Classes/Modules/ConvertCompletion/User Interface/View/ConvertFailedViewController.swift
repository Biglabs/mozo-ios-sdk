//
//  ConvertFailedViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/12/19.
//

import Foundation
class ConvertFailedViewController: MozoBasicViewController {
    @IBOutlet weak var lbDes: UILabel!
    @IBOutlet weak var lbDesTry: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    var eventHandler: ConvertCompletionModuleInterface?
    var transaction: IntermediaryTransactionDTO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "text_convert_title".localized
        navigationItem.rightBarButtonItem = nil
    }
    
    func setupLayout() {
        btnBack.roundCorners(cornerRadius: 0.015, borderColor: .white, borderWidth: 0.1)
    }
    
    @IBAction func touchBack(_ sender: Any) {
        ModuleDependencies.shared.corePresenter.requestForCloseAllMozoUIs(nil)
    }
}
