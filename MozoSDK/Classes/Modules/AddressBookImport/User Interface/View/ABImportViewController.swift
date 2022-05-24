//
//  ABImportViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
import Contacts

class ABImportViewController: MozoBasicViewController {
    @IBOutlet weak var lbLastUpdate: UILabel!
    @IBOutlet weak var updateContainerView: UIView!
    @IBOutlet weak var lbUpdate: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnUpdateLoading: UIActivityIndicatorView!
    @IBOutlet weak var permissionGroup: UIView!
    @IBOutlet weak var permissionImage: UIImageView!
    
    var eventHandler: ABImportModuleInterface?
    
    var stopRotating = false
    
    let dateFormat = "MMM d, yyyy - HH:mm".localized
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        eventHandler?.loadProcessStatusForInitializing()
        
        updateContainerView.roundCorners(borderColor: .white, borderWidth: 0.1)
        updateContainerView.layer.cornerRadius = 5
        permissionImage.image = "ic_notif_user_come".asMozoImage()?.withRenderingMode(.alwaysOriginal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Synchronize Contacts".localized
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch(status) {
        case .notDetermined:
            permissionGroup.isHidden = false
            break
        case .restricted, .denied:
            permissionGroup.isHidden = false
            break
        default:
            permissionGroup.isHidden = true
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            eventHandler?.stopCheckStatus()
            stopRotating = true
        }
    }

    func updateLayoutWithProcessStatus(_ processStatus: AddressBookImportProcessDTO) {
        let isCompleted = processStatus.currentStatus == .COMPLETED
        let enable = isCompleted
        let hidden = isCompleted
        let text = (isCompleted ? "Synchronize" : "Synchronizing...").localized
        btnUpdate.isEnabled = enable
        lbUpdate.text = text
        btnUpdateLoading.isHidden = hidden
        stopRotating = isCompleted
        if isCompleted {
            var dateText = "Not yet synchronized".localized
            if let updateAt = processStatus.updatedAt {
                formatter.dateFormat = dateFormat
                let date = Date(timeIntervalSince1970: Double(updateAt))
                dateText = formatter.string(from: date)
            }
            
            lbLastUpdate.text = dateText
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func touchBtnUpdate(_ sender: Any) {
        eventHandler?.requestToImport()
    }
    @IBAction func touchAllow(_ sender: Any) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.permissionGroup.isHidden = true
                    self.eventHandler?.requestToImport()
                }
            }
        } else {
            self.showSettingPermissionAlert()
        }
    }
    @IBAction func touchPrivacy(_ sender: Any) {
        if let url = URL(string: "\(MozoSDK.homePage)/info/privacy-and-cookies-policy") {
            UIApplication.shared.open(url)
        }
    }
}
extension ABImportViewController: ABImportViewInterface {
    func displaySpinner() {
        self.displayMozoSpinner()
    }
    
    func removeSpinner() {
        self.removeMozoSpinner()
    }
    
    func showSettingPermissionAlert() {
        let alert = UIAlertController(
            title: "Cannot access your Contact Book".localized,
            message: "text_reuqest_permission_contact".localized,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "Change Settings".localized, style: .default, handler: { (action) in
            self.openSettings()
        }))
        alert.addAction(.init(title: "Close".localized, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateInterfaceWithProcessStatus(_ processStatus: AddressBookImportProcessDTO) {
        updateLayoutWithProcessStatus(processStatus)
    }
    
    func showContactEmptyAlert() {
        self.displayMozoError("Cannot synchronize, your Contact Book is empty.")
    }
}
