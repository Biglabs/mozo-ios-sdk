//
//  SettingsViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
import PromiseKit

class SettingsViewController: MozoBasicViewController {
    private var tableView: UITableView!
    
    private var documentsSize: Int64 = 0
    private let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftNavigationBarButton()
        setupTableView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Settings".localized
        calculateDocumentsSize()
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        let frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.height)
        tableView = UITableView(frame: frame)
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        let guide = self.view.safeAreaLayoutGuide
        tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER)
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 20, right: 0)
    }
    
    private func calculateDocumentsSize() {
        self.documentsSize = 0
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileList = listFilesFromDocumentsFolder()
        
        for i in fileList {
            let filePath = documentsDir.appendingPathComponent(i)
            if fileManager.fileExists(atPath: filePath.path) {
                do {
                    let fileAttr = try FileManager.default.attributesOfItem(atPath: filePath.path)
                    let fileSize = fileAttr[FileAttributeKey.size] as? Int64
                    self.documentsSize += (fileSize ?? 0)
                }
                catch{}
            }
        }
        
        if let index = SettingsTypeEnum.allCases.firstIndex(of: .Cache) {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    private func clearDocuments() {
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileList = listFilesFromDocumentsFolder()
        for f in fileList {
            let filePath = documentsDir.appendingPathComponent(f)
            if fileManager.fileExists(atPath: filePath.path) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                } catch { }
            }
        }
        self.calculateDocumentsSize()
    }
    
    private func listFilesFromDocumentsFolder() -> [String] {
        let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs != [] {
            let dir = dirs[0]
            let fileList = try! FileManager.default.contentsOfDirectory(atPath: dir)
            return fileList
        }else{
            let fileList = [""]
            return fileList
        }
    }
    
    class func launch(root: UINavigationController) {
        let viewController = SettingsViewController()
        root.pushViewController(viewController, animated: true)
    }
}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsTypeEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! SettingsTableViewCell
        if let tab = SettingsTypeEnum(rawValue: indexPath.row) {
            cell.settingsTypeEnum = tab
            if tab == .Cache {
                let size = ByteCountFormatter.string(fromByteCount: documentsSize, countStyle: .file)
                cell.additionalText = String(format: ": %@", size)
            } else {
                cell.additionalText = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(SETTINGS_TABLE_VIEW_CELL_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let tab = SettingsTypeEnum(rawValue: indexPath.row) {
            switch tab {
            case .Currencies, .Password:
                DisplayUtils.displayUnderConstructionPopup()
                break
            case .Pin:
                MozoSDK.requestForChangePin()
                break
            case .Backup:
                MozoSDK.requestForBackUpWallet()
                break
            case .ChangeLanguages:
                self.alertListItemLanguages()
                break
            case .Cache:
                self.clearDocuments()
                break
            case .DeleteAccount:
                self.alertDeleteAccount()
                break
            }
        }
    }
    
    func alertNotiDeleteAccount() {
        let alert = UIAlertController(title: "Your account has been scheduled for deletion.", message: "Please login with in the next 30 days to cancel the schedule.", preferredStyle: .alert)

        let closeAppAction = UIAlertAction(title: "Close App", style: .default) { closeApp in
            ModuleDependencies.shared.authPresenter.authInteractor?.clearAllAuthSession()
            exit(0)
        }
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { login in
            MozoSDK.logout()
        }
        
        alert.addAction(closeAppAction)
        alert.addAction(loginAction)
        self.present(alert, animated: false, completion: nil)

    }
    
    func alertDeleteAccount() {
        let alert = UIAlertController(title: "Delete Account".localized, message: "\nAre you sure you want to delete your whole account?\nYou’ll lose everything, your MozoX wallet including the token, purchased vouchers, friend list, liked and shared forever.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete everything", style: .default) { deleteAction in
            _ = ApiManager.shared.deleteAccount().done({ isSuccess in
                if isSuccess {
                    self.alertNotiDeleteAccount()
                }
            })
        }
        
        deleteAction.titleTextColor = .red

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(_) in }))
        alert.addAction(deleteAction)
        
        self.present(alert, animated: false, completion: nil)
    }
    
    func alertListItemLanguages() {
        let arrLanguages = ["Language_English".localized, "Language_Korean".localized, "Language_Vietnamese".localized]
        
        let alert = UIAlertController(title: "Change Languages".localized, message: nil, preferredStyle: .alert)
        
        let closure = { (action: UIAlertAction!) -> Void in
            let index = alert.actions.firstIndex(of: action)
            var language = ""
            if index != nil {
                if index == 0 {
                    language = "en"
                }else if index == 1 {
                    language = "ko"
                }else {
                    language = "vi"
                }
                                                
                UserDefaults.standard.set(language, forKey: "AppLanguage")
                UserDefaults.standard.synchronize()
                
                MozoSDK.baseApplication?.resetApp()
                
                print("Index: \(index!) - Language: \(language)")
            }
        }
        
        for itemLanguage in arrLanguages {
            alert.addAction(UIAlertAction(title: itemLanguage, style: .default, handler: closure))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(_) in }))

        self.present(alert, animated: false, completion: nil)
    }
}

extension ApiManager {
    func deleteAccount() -> Promise<Bool> {
        return Promise {seal in
            let url = Configuration.BASE_STORE_URL + "/accountDeleted/deletedUserInShopperApp"
            self.execute(.post, url: url).done { json in
                seal.fulfill(true)
            }
            .catch { error in
                print("Error when delete account:" + error.localizedDescription)
                seal.reject(error)
            }
            .finally {
                
            }
        }
    }
}
