//
//  AddressBookViewController.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation
import UIKit
import MBProgressHUD
class AddressBookViewController: MozoBasicViewController {
    var eventHandler: AddressBookModuleInterface?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: MozoSearchFooter!
    @IBOutlet weak var btnUpdateContacts: UIButton!
    
    var displayData : AddressBookDisplayData?
    var addrBooks = [AddressBookDisplayItem]()
    var filteredSections : [AddressBookDisplaySection]?
    var isDisplayForSelect = true
    var isDisplayingAddressBook = true
    
    var isShowStoreBook = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTarget()
        setupSegment()
        eventHandler?.updateDisplayData(forAddressBook: isDisplayingAddressBook)
    }
    
    func setupSegment() {
        segmentControl.setTitle("User Address".localized, forSegmentAt: 0)
        segmentControl.setTitle("Store Address".localized, forSegmentAt: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Change title according to requested module.
        if isDisplayForSelect {
            navigationItem.title = "Select Address".localized
        } else {
            navigationItem.title = "Address Book".localized
        }
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private instance methods
    
    func setupLayout() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Address".localized
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        // Setup the search footer
//        tableView.tableFooterView = searchFooter
        let identifier = String(describing: AddressBookTableViewCell.self)
        tableView.register(UINib(nibName: identifier, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: identifier)
        tableView.register(UINib(nibName: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER)
        let eIdentifier = String(describing: ABEmptyStateTableViewCell.self)
        tableView.register(UINib(nibName: eIdentifier, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: eIdentifier)
        
        tableView.sectionIndexColor = ThemeManager.shared.disable
        if isDisplayForSelect {
            enableBackBarButton()
        }
        if !isShowStoreBook {
            tableView.tableHeaderView = nil
        }
        btnUpdateContacts.roundCorners(borderColor: .white, borderWidth: 0.1)
        btnUpdateContacts.layer.cornerRadius = 5
    }
    
    func setupTarget() {
        segmentControl.addTarget(self, action: #selector(self.segmmentControlChanged), for: .valueChanged)
    }
    
    @objc func segmmentControlChanged() {
        print("Segment did change value")
        let currentIndex = segmentControl.selectedSegmentIndex
        isDisplayingAddressBook = currentIndex == 0
        eventHandler?.updateDisplayData(forAddressBook: isDisplayingAddressBook)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if addrBooks.count == 0 {
            return
        }
        filteredSections = displayData?.filterByText(searchText)
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty() && filteredSections != nil
    }
    
    func clearFilter() {
        filteredSections = nil
        tableView.reloadData()
    }
    
    var hud: MBProgressHUD?
    func showHud() {
        if let navView = navigationController?.view {
            hud = MBProgressHUD.showAdded(to: navView, animated: true)
            hud?.mode = .text
            hud?.label.text = "Synchronize Contacts successful!".localized
            hud?.label.textColor = .white
            hud?.label.numberOfLines = 2
            hud?.offset = CGPoint(x: 0, y: -300)
            hud?.bezelView.color = UIColor(hexString: "e63b4b61")
            hud?.isUserInteractionEnabled = false
            hud?.hide(animated: true, afterDelay: 1.5)
        }
    }
    
    @IBAction func touchBtnUpdateContacts(_ sender: Any) {
        eventHandler?.openImportContact()
    }
}
// MARK: - Table View
extension AddressBookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            if filteredSections!.count == 0 {
                return 1
            }
            return filteredSections!.count
        }
        return displayData?.sections.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            if filteredSections!.count == 0 {
                return 1
            }
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredSections!.count, of: addrBooks.count)
            return filteredSections![section].items.count
        }
        return displayData?.sections[section].items.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayData == nil {
            return ""
        }
        if (isFiltering() && filteredSections!.count == 0) || displayData?.sections.count ?? 0 == 0 {
            return nil
        }
        let name = displayData?.sections[section].sectionName
        return name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isFiltering() && filteredSections!.count == 0) || displayData?.sections.count ?? 0 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ABEmptyStateTableViewCell.self), for: indexPath) as! ABEmptyStateTableViewCell
            return cell
        }
        
        let item: AddressBookDisplayItem
        if isFiltering() {
            item = filteredSections![indexPath.section].items[indexPath.row]
        } else {
            item = (displayData?.sections[indexPath.section].items[indexPath.row])!
        }
        if isDisplayingAddressBook {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddressBookTableViewCell.self), for: indexPath) as! AddressBookTableViewCell
            cell.addressBook = item
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! StoreBookTableViewCell
        cell.displayItem = item
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (isFiltering() && filteredSections!.count == 0) || displayData?.sections.count ?? 0 == 0 {
            return nil
        }
        let headerView = UIView()
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 10, width:
            tableView.bounds.size.width, height: 29))
        headerLabel.textColor = ThemeManager.shared.disable
        headerLabel.font = UIFont.boldSystemFont(ofSize: 25)
        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return displayData != nil ? displayData?.selectIndexTitles() : []
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 29
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isFiltering() && filteredSections!.count == 0) || displayData?.sections.count ?? 0 == 0 {
            return 240
        }
        return isDisplayingAddressBook ? 70 : 76
    }
}

extension AddressBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if (isFiltering() && filteredSections!.count == 0) || displayData?.sections.count ?? 0 == 0 {
            return
        }
        if let selectedItem = isFiltering() ?
            filteredSections![indexPath.section].items[indexPath.row] :
            displayData?.sections[indexPath.section].items[indexPath.row] {
            eventHandler?.selectAddressBookOnUI(selectedItem, isDisplayForSelect: isDisplayForSelect)
        }
    }
}

extension AddressBookViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearFilter()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            clearFilter()
        }
    }
}

extension AddressBookViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            filterContentForSearchText(text)
        }
    }
}

extension AddressBookViewController : AddressBookViewInterface {
    func showAddressBookDisplayData(_ data: AddressBookDisplayData, allItems: [AddressBookDisplayItem]) {
        displayData = data
        addrBooks = allItems
        if isFiltering(), !searchBarIsEmpty(), let text = searchController.searchBar.text {
            filterContentForSearchText(text)
        } else {
            tableView.reloadData()
        }
    }
    
    func showNoContentMessage() {
        displayData = nil
        addrBooks = []
        if isFiltering() {
            clearFilter()
        } else {
            tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    func showImportSuccess() {
        showHud()
    }
}
