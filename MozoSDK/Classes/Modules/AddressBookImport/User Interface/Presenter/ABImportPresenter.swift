//
//  ABImportPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/26/19.
//

import Foundation
import Contacts
enum ABImportActionEnum {
    case InitialLoading
    case Import
}
class ABImportPresenter: NSObject {
    var wireframe: ABImportWireframe?
    var interactor: ABImportInteractorInput?
    var viewInterface: ABImportViewInterface?
    var delegate: ABImportModuleDelegate?
    
    var retryAction: ABImportActionEnum?
    
    func retrieveAddressBookContacts() {
        let abAuthStatus = CNContactStore.authorizationStatus(for: .contacts)
        if abAuthStatus == .denied || abAuthStatus == .restricted {
            viewInterface?.showSettingPermissionAlert()
            return
        }
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                self.viewInterface?.showSettingPermissionAlert()
                return
            }
            
            // get the contacts
            
            var contacts = [CNContact]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as NSString,
                                                              CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                                              CNContactPhoneNumbersKey as CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print("ABImportPresenter - Request fetch contact error: \(error)")
            }
                        
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            var contactInfoArray = [ContactInfoDTO]()
            for contact in contacts {
                let fullName = formatter.string(from: contact) ?? ""
                let phoneNos = contact.phoneNumbers.map({ $0.value.stringValue })
                print("ABImportPresenter - Retrieve address book contacts - Full name: \(fullName), phoneNos: \(phoneNos)")
                let contactInfo = ContactInfoDTO(name: fullName, phoneNums: phoneNos)
                contactInfoArray.append(contactInfo)
            }
            if contactInfoArray.count > 0 {
                self.viewInterface?.displaySpinner()
                self.interactor?.requestImportWithContacts(contactInfoArray)
            } else {
                self.viewInterface?.showContactEmptyAlert()
            }
        }
    }
}
extension ABImportPresenter: ABImportModuleInterface {
    func loadProcessStatusForInitializing() {
        viewInterface?.displaySpinner()
        interactor?.loadProcessStatusForInitializing()
    }
    
    func requestToImport() {
        retrieveAddressBookContacts()
    }
    
    func stopCheckStatus() {
        interactor?.stopWaitingForImporting()
    }
}
extension ABImportPresenter: ABImportInteractorOutput {
    func didReceiveProcessStatus(_ processStatus: AddressBookImportProcessDTO, forInitializing: Bool) {
        if forInitializing {
            viewInterface?.removeSpinner()
            if processStatus.currentStatus == .PROCESSING {
                interactor?.startWaitingForImporting()
            } else {
                interactor?.stopWaitingForImporting()
            }
        }
        viewInterface?.updateInterfaceWithProcessStatus(processStatus)
    }
    
    func errorWhileLoadingProcessStatus(error: ConnectionError, forInitializing: Bool) {
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        if forInitializing {
            viewInterface?.removeSpinner()
            retryAction = .InitialLoading
            DisplayUtils.displayTryAgainPopup(allowTapToDismiss: false, error: error, delegate: self)
        }
    }
    
    func didRequestImportSuccess() {
        viewInterface?.removeSpinner()
        delegate?.didFinishImport()
    }
    
    func errorWhileRequestingImport(error: ConnectionError) {
        viewInterface?.removeSpinner()
        if error == .apiError_MAINTAINING {
            DisplayUtils.displayMaintenanceScreen()
            return
        }
        DisplayUtils.displayTryAgainPopup(allowTapToDismiss: true, error: error, delegate: self)
    }
}
extension ABImportPresenter: PopupErrorDelegate {
    func didTouchTryAgainButton() {
        if let action = self.retryAction {
            switch action {
            case .InitialLoading: loadProcessStatusForInitializing()
            case .Import: requestToImport()
            }
        }
    }
    
    func didClosePopupWithoutRetry() {
        retryAction = nil
    }
}
