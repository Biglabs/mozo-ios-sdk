//
//  PassPhraseViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/29/18.
//

import Foundation
import UIKit

class PassPhraseViewController: MozoBasicViewController {
    var eventHandler : WalletModuleInterface?
    var passPharse : String? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBOutlet fileprivate var passPhraseTextView:UITextView?
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorderForLabel()
        addTapForLabel()
        // Generate mnemonic
        eventHandler?.generateMnemonics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Backup Wallet".localized
    }
    
    func addBorderForLabel() {
        checkView.roundCorners(borderColor: ThemeManager.shared.disable, borderWidth: 1.1)
    }
    
    func addTapForLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.checkLabelTapped))
        tap.numberOfTapsRequired = 1
        checkLabel?.isUserInteractionEnabled = true
        checkLabel?.addGestureRecognizer(tap)
        
        let tapI = UITapGestureRecognizer(target: self, action: #selector(self.checkLabelTapped))
        tapI.numberOfTapsRequired = 1
        checkImg.isUserInteractionEnabled = true
        checkImg.addGestureRecognizer(tapI)
    }
    
    @objc func checkLabelTapped() {
        if !continueBtn.isEnabled {
            checkLabel.textColor = ThemeManager.shared.main
            continueBtn.isEnabled = true
            continueBtn.backgroundColor = ThemeManager.shared.main
            checkImg.isHighlighted = true
            checkView.layer.borderColor = ThemeManager.shared.main.cgColor
        }
    }
    
    @IBAction fileprivate func continueBtnTapped(_ sender:AnyObject) {
        if let passPhrase = self.passPharse {
            eventHandler?.skipShowPassPharse(passPharse: passPhrase)
        }
    }
    
    func addWordSpace(str: String) -> String {
        return str.replace(" ", withString: "  ")
    }
}

extension PassPhraseViewController: PassPhraseViewInterface {
    func showPassPhrase(passPharse: String) {
        self.passPharse = passPharse
        self.passPhraseTextView?.text = addWordSpace(str: passPharse)
    }
}
