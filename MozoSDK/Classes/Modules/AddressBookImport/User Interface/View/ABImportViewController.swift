//
//  ABImportViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
class ABImportViewController: MozoBasicViewController {
    @IBOutlet weak var lbLastUpdate: UILabel!
    @IBOutlet weak var updateContainerView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var lbUpdate: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    
    var eventHandler: ABImportModuleInterface?
    
    var stopRotating = false
    
    let dateFormat = "MMM d, yyyy - HH:mm".localized
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        eventHandler?.loadProcessStatusForInitializing()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Synchronize Contacts".localized
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            eventHandler?.stopCheckStatus()
            stopRotating = true
        }
    }
    
    func setupLayout() {
        let loading = UIImage(named: "ic_loading", in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        loadingImageView.image = loading
        loadingImageView.tintColor = .white
        
        updateContainerView.roundCorners(borderColor: .white, borderWidth: 0.1)
        updateContainerView.layer.cornerRadius = 5
    }

    func updateLayoutWithProcessStatus(_ processStatus: AddressBookImportProcessDTO) {
        let isCompleted = processStatus.currentStatus == .COMPLETED
        let enable = isCompleted
        let hidden = isCompleted
        let text = (isCompleted ? "Update" : "Updating...").localized
        btnUpdate.isEnabled = enable
        lbUpdate.text = text
        loadingImageView.isHidden = hidden
        stopRotating = isCompleted
        if !isCompleted {
            rotateView()
        } else {
            var dateText = "Not yet synchronized".localized
            if let updateAt = processStatus.updatedAt {
                formatter.dateFormat = dateFormat
                let date = Date(timeIntervalSince1970: Double(updateAt))
                dateText = formatter.string(from: date)
            }
            
            lbLastUpdate.text = dateText
        }
    }
    
    func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            self.loadingImageView.transform = self.loadingImageView.transform.rotated(by: CGFloat.pi)
        }) { finished in
            if !self.stopRotating {
                self.rotateView(duration: duration)
            } else {
                self.loadingImageView.transform = .identity
            }
        }
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @IBAction func touchBtnUpdate(_ sender: Any) {
        eventHandler?.requestToImport()
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
        let alert = UIAlertController(title: "Cannot access your Contact Book".localized, message: "You must give the app permission to access the Contact Book first".localized, preferredStyle: .alert)
        alert.addAction(.init(title: "Change Settings".localized, style: .default, handler: { (action) in
            self.openSettings()
        }))
        alert.addAction(.init(title: "OK".localized, style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateInterfaceWithProcessStatus(_ processStatus: AddressBookImportProcessDTO) {
        updateLayoutWithProcessStatus(processStatus)
    }
    
    func showContactEmptyAlert() {
        self.displayMozoError("Cannot synchronize, your Contact Book is empty.")
    }
}
