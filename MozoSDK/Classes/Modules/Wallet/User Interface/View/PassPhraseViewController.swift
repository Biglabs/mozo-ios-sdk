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
    
    @IBOutlet weak var passPhraseContainerView: UIView!
    @IBOutlet fileprivate var passPhraseTextView:UITextView?
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorderForLabel()
        addTapForLabel()
        if passPharse == nil {
            // Generate mnemonic
            eventHandler?.generateMnemonics()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
    }
    
    func addBorderForLabel() {
        checkImg.roundCorners(cornerRadius: 0.5, borderColor: ThemeManager.shared.main, borderWidth: 2)
        checkView.roundCorners(borderColor: ThemeManager.shared.main, borderWidth: 2)
        continueBtn.roundCorners(cornerRadius: 0.02, borderColor: .clear, borderWidth: 0.1)
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
    
    func showPassPhraseOnContainerView() {
        if let array = self.passPharse?.components(separatedBy: " ") {
            let wordViews = self.passPhraseContainerView.subviews.filter({ $0.tag != 99 })
            for (index, element) in array.enumerated() {
                let view = wordViews.first{ $0.tag == index }
                if let label = view as? UILabel {
                    label.text = element
                }
            }
        }
    }
}

extension PassPhraseViewController: PassPhraseViewInterface {
    func showPassPhrase(passPharse: String) {
        self.passPharse = passPharse
        self.showPassPhraseOnContainerView()
//        self.passPhraseTextView?.text = addWordSpace(str: passPharse)
    }
}
