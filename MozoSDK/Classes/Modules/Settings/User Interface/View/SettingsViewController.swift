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
        view.backgroundColor = .white
        let frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.height)
        tableView = UITableView(frame: frame)
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30).isActive = true
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            
        } else {
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 30).isActive = true
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -20).isActive = true
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        }
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
