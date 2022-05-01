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
    
    private let MAX_INPUT: Int = 12

    private lazy var words: [String] = {
        return BIP39Language.english.words
    }()
    
    var eventHandler: BackupWalletModuleInterface?
    var mnemonics: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        btnFinish.roundCorners(cornerRadius: 0.015, borderColor: .clear, borderWidth: 0.1)
        btnFinish.layer.cornerRadius = 5
        
        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input4.delegate = self
        
        guard let seed = mnemonics?.split(separator: " ") else { return }
        let max = seed.count - 1
        let word_1 = self.random(max: max)
        let word_2 = self.random(max: max, exclude: [word_1])
        let word_3 = self.random(max: max, exclude: [word_1, word_2])
        let word_4 = self.random(max: max, exclude: [word_1, word_2, word_3])

        input1Number.text = "\(word_1 + 1)."
        input1.tag = word_1
        
        input2Number.text = "\(word_2 + 1)."
        input2.tag = word_2
        
        input3Number.text = "\(word_3 + 1)."
        input3.tag = word_3
        
        input4Number.text = "\(word_4 + 1)."
        input4.tag = word_4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Backup Wallet".localized
        navigationController?.isNavigationBarHidden = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        
        let allowedCharacters = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)
        return count <= MAX_INPUT && allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .darkText
        let lineColor: UIColor = .systemBlue
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text?.lowercased().trim() ?? ""
        let isContains = value.isEmpty || words.contains(value)
        let textColor: UIColor = isContains ? .systemBlue : .systemRed
        
        let lineColor: UIColor = .systemGray
        switch textField {
        case input1:
            input1Line.backgroundColor = lineColor
            input1.textColor = textColor
            
            break
        case input2:
            input2Line.backgroundColor = lineColor
            input2.textColor = textColor
            
            break
        case input3:
            input3Line.backgroundColor = lineColor
            input3.textColor = textColor
            
            break
        case input4:
            input4Line.backgroundColor = lineColor
            input4.textColor = textColor
            
            break
        default:
            break
        }
    }
    
    @IBAction func touchBtnFinish(_ sender: Any) {
        guard let safeMnemonics = self.mnemonics,
              let seed = self.mnemonics?.split(separator: " ") else { return }
        
        let word_1 = input1.text?.lowercased().trim() ?? ""
        let word_2 = input2.text?.lowercased().trim() ?? ""
        let word_3 = input3.text?.lowercased().trim() ?? ""
        let word_4 = input4.text?.lowercased().trim() ?? ""
        if word_1 == seed[input1.tag],
           word_2 == seed[input2.tag],
           word_3 == seed[input3.tag],
           word_4 == seed[input4.tag] {
            eventHandler?.verifyPassPhrases(safeMnemonics)
        } else {
            displayVerifyFailed()
        }
    }
    
    private func random(max: Int, exclude: [Int]? = nil) -> Int {
        var r = Int.random(in: 0...max)
        if let exs = exclude {
            while(exs.contains(r)) {
                r = Int.random(in: 0...max)
            }
        }
        return r
    }
}
extension BackupWalletViewController: BackupWalletViewInterface {
    func displayVerifyFailed() {
        displayMozoError("Invalid Recovery Phrase")
    }
}
