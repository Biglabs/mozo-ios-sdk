//
//  TxProcessViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class TxProcessViewController: MozoBasicViewController {
    @IBOutlet weak var lbStepTitle: UILabel!
    @IBOutlet weak var lbStepDes: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var lbHide: UILabel!
    
    var eventHandler: TxProcessModuleInterface?
    var currentStep = TxProcessStep.Broadcasting
    
    var stopLoading = false
    
    var moduleRequest = Module.Convert
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbStepTitle.text = currentStep.title
        updateLayout()
        prepareNextSteps()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if moduleRequest == .Convert {
            self.title = "text_convert_title".localized
        }
        navigationItem.rightBarButtonItem = nil
    }
    
    func updateLayout() {
        btnHide.roundCorners(cornerRadius: 0.15, borderColor: UIColor(hexString: "4e94f3"), borderWidth: 1.1)
        btnHide.layer.cornerRadius = 22.5
    }
    
    func prepareNextSteps() {
        if currentStep.rawValue < TxProcessStep.Waiting.rawValue {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(currentStep.delaySeconds)) {
                self.currentStep = TxProcessStep(rawValue: self.currentStep.rawValue + 1)!
                self.lbStepTitle.text = self.currentStep.title
                self.prepareNextSteps()
            }
        }
    }
    
    func handleHideAction() {
        if let navigationController = self.navigationController as? MozoNavigationController, let coreEventHandler = navigationController.coreEventHandler {
            eventHandler?.hideProcess()
            coreEventHandler.requestForCloseAllMozoUIs(nil)
        }
    }
    
    @IBAction func touchBtnHide(_ sender: Any) {
        handleHideAction()
    }
}
