//
//  SettingsTableViewCell.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
let SETTINGS_TABLE_VIEW_CELL_IDENTIFIER = "SettingsTableViewCell"
let SETTINGS_TABLE_VIEW_CELL_HEIGHT = 60

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var containerImageView: UIView!
    @IBOutlet weak var imgViewType: UIImageView!
    @IBOutlet weak var constraintCenterY: NSLayoutConstraint!
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintImageWidth: NSLayoutConstraint!
    @IBOutlet weak var lbSettingType: UILabel!
    
    var settingsTypeEnum = SettingsTypeEnum.Currencies
    var additionalText: String = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bindData()
    }
    
    func bindData() {
        lbSettingType.text = settingsTypeEnum.name.localized + additionalText
        let image = UIImage(named: settingsTypeEnum.icon, in: BundleManager.mozoBundle(), compatibleWith: nil)
        imgViewType.image = image
               
        switch settingsTypeEnum {
        case .Currencies:
            constraintImageWidth.constant = 18
            constraintImageHeight.constant = 18
            break
        case .Password:
            constraintImageWidth.constant = 17
            constraintImageHeight.constant = 23
            break
        case .Pin:
            constraintImageWidth.constant = 27
            constraintImageHeight.constant = 26
            break
        case .Backup:
            constraintImageWidth.constant = 21
            constraintImageHeight.constant = 22
            break
        case .Cache:
            constraintImageWidth.constant = 22
            constraintImageHeight.constant = 22
            break
        case .ChangeLanguages:
            constraintImageWidth.constant = 22
            constraintImageHeight.constant = 22
            break
        case .DeleteAccount:
            constraintImageWidth.constant = 26
            constraintImageHeight.constant = 30
            lbSettingType.textColor = .red
            break
        }
    }
}
