//
//  SettingsViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 6/11/19.
//

import Foundation
class SettingsViewController: MozoBasicViewController {
    var eventHandler: SettingsModuleInterface?
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableBackBarButton()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Settings".localized
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.frame)
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER)
    }
}
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SETTINGS_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! SettingsTableViewCell
        if let tab = SettingsTypeEnum(rawValue: indexPath.row) {
            cell.settingsTypeEnum = tab
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(SETTINGS_TABLE_VIEW_CELL_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let tab = SettingsTypeEnum(rawValue: indexPath.row) {
            eventHandler?.selectSettingsTab(tab)
        }
    }
}
