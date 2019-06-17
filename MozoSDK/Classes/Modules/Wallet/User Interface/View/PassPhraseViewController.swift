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
    
    var requestedModule = Module.Wallet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addBorderForLabel()
        addTapForLabel()
        if passPharse == nil {
            // Generate mnemonic
            eventHandler?.generateMnemonics()
        } else {
            self.showPassPhraseOnContainerView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
        if requestedModule == .BackupWallet {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setNavigationBar() {
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 85, height: 40))
        let imageView = UIImageView(frame: CGRect(x: -10, y: 10, width: 20, height: 20))

        if let imgBackArrow = UIImage(named: "ic_left_arrow", in: BundleManager.mozoBundle(), compatibleWith: nil) {
            imageView.image = imgBackArrow.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = ThemeManager.shared.main
        }
        view.addSubview(imageView)

        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 60, height: 18))
        label.text = "Back".localized
        label.textColor = ThemeManager.shared.main

        view.addSubview(label)

        let backTap = UITapGestureRecognizer(target: self, action: #selector(tapBackBtn))
        view.addGestureRecognizer(backTap)

        let leftBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    @objc func tapBackBtn() {
        if requestedModule == .BackupWallet {
            if let mozoNavigationController = navigationController as? MozoNavigationController,
                let coreEventHandler = mozoNavigationController.coreEventHandler {
                coreEventHandler.requestForCloseAllMozoUIs()
            }
        } else {
            if let mozoNavigationController = navigationController as? MozoNavigationController {
                mozoNavigationController.popViewController(animated: false)
            }
        }
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
            eventHandler?.skipShowPassPharse(passPharse: passPhrase, requestedModule: requestedModule)
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
