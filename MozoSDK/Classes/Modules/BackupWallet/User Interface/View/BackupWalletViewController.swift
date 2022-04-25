//
//  BackupWalletViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
import web3swift
class BackupWalletViewController: MozoBasicViewController, UITextFieldDelegate {
    @IBOutlet weak var input1: UITextField!
    @IBOutlet weak var input1Number: UILabel!
    @IBOutlet weak var input1Line: UIView!
    
    @IBOutlet weak var input2: UITextField!
    @IBOutlet weak var input2Number: UILabel!
    @IBOutlet weak var input2Line: UIView!
    
    @IBOutlet weak var input3: UITextField!
    @IBOutlet weak var input3Number: UILabel!
    @IBOutlet weak var input3Line: UIView!
    
    @IBOutlet weak var input4: UITextField!
    @IBOutlet weak var input4Number: UILabel!
    @IBOutlet weak var input4Line: UIView!
    
    @IBOutlet weak var btnFinish: UIButton!
    var eventHandler: BackupWalletModuleInterface?
    
    var mnemonics: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
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
        //mnemonicsView.setIndexRandomly(true, randomIndexs: [index1st, index2nd, index3rd, index4th])
        
        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input4.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func onEdittingChanged(_ sender: Any) {
        let textField = sender as? UITextField
        let focused = textField?.isFirstResponder ?? false
        let lineColor: UIColor = focused ? .systemBlue : .systemGray
        switch textField {
        case input1:
            input1Line.backgroundColor = lineColor
            
            break
        case input2:
            input2Line.backgroundColor = lineColor
            break
        case input3:
            input3Line.backgroundColor = lineColor
            break
        case input4:
            input4Line.backgroundColor = lineColor
            break
        default:
            break
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        <#code#>
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        <#code#>
    }
    
    @IBAction func touchBtnFinish(_ sender: Any) {
//        if let mnemonics = self.mnemonics, let randomIndexs = self.mnemonicsView.randomIndexs as? [Int] {
//            eventHandler?.verifyPassPhrases(self.mnemonicsView.mnemonics, indexs: randomIndexs, originalPassPhrases: mnemonics)
//        } else {
//            displayVerifyFailed()
//        }
    }
}
extension BackupWalletViewController: BackupWalletViewInterface {
    func displayVerifyFailed() {
        displayMozoError("Invalid Recovery Phrase")
    }
}
