//
//  AddressBookViewController.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation
import UIKit

class AddressBookViewController: MozoBasicViewController {
    var eventHandler: AddressBookModuleInterface?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: MozoSearchFooter!
    @IBOutlet weak var noDataView: UIView!
    
    var displayData : AddressBookDisplayData?
    var addrBooks = [AddressBookDisplayItem]()
    var filteredSections : [AddressBookDisplaySection]?
    var isDisplayForSelect = true
    var isDisplayingAddressBook = true
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tableView.frame.size.height)
        prepareNoContentView(frame, message: "Contacts list is empty")
        setupLayout()
        setupTarget()
        eventHandler?.updateDisplayData(forAddressBook: isDisplayingAddressBook)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Change title according to requested module.
        if isDisplayForSelect {
            self.title = "Select Address".localized
        } else {
            self.title = "Address Book".localized
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
        searchController.searchBar.placeholder = "Search".localized
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        // Setup the search footer
        tableView.tableFooterView = searchFooter
        tableView.register(UINib(nibName: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER, bundle: BundleManager.mozoBundle()), forCellReuseIdentifier: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER)
        
        tableView.sectionIndexColor = ThemeManager.shared.disable
        if isDisplayForSelect {
            enableBackBarButton()
        }
        
        segmentControl.setTitle("User Address".localized, forSegmentAt: 0)
        segmentControl.setTitle("Store Address".localized, forSegmentAt: 1)
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
    
    func loadFoundNoDataView() -> UIView {
        let bundle = BundleManager.mozoBundle()
        let nib = UINib(nibName: "MozoFoundNoDataView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func checkShowNoContent() {
        if self.displayData?.sections.count ?? 0 > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = noContentView
        }
    }
}
// MARK: - Table View
extension AddressBookViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            if filteredSections!.count == 0 {
                noDataView.isHidden = false
            } else {
                noDataView.isHidden = true
            }
            return filteredSections!.count
        }
        checkShowNoContent()
        noDataView.isHidden = true
        return displayData?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredSections!.count, of: addrBooks.count)
            return filteredSections![section].items.count
        }
        return displayData?.sections[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayData == nil {
            return ""
        }
        let name = displayData?.sections[section].sectionName
        return name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = isDisplayingAddressBook ? tableView.dequeueReusableCell(withIdentifier: "MozoAddressBookCell", for: indexPath) : tableView.dequeueReusableCell(withIdentifier: STORE_BOOK_TABLE_VIEW_CELL_IDENTIFIER, for: indexPath) as! StoreBookTableViewCell
//        let itemCount = (displayData?.sections[indexPath.section].items.count)!
//        if itemCount > 0 {
            let item: AddressBookDisplayItem
            if isFiltering() {
                item = filteredSections![indexPath.section].items[indexPath.row]
            } else {
                item = (displayData?.sections[indexPath.section].items[indexPath.row])!
            }
            if isDisplayingAddressBook {
                cell.textLabel!.text = item.name
                cell.detailTextLabel!.text = item.address
            } else {
                (cell as! StoreBookTableViewCell).displayItem = item
            }
            // MARK: Border
            let border = CALayer()
            border.backgroundColor = ThemeManager.shared.disable.cgColor
            let width : CGFloat = 1.0
            border.frame = CGRect(x: 20, y: cell.frame.size.height - width, width: cell.frame.size.width - 40, height: width)
            cell.layer.addSublayer(border)
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 10, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isDisplayingAddressBook ? 56 : 76
    }
}

extension AddressBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
}
