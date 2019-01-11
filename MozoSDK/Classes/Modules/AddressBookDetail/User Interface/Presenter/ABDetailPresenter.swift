//
//  ABDetailPresenter.swift
//  MozoSDK
//
//  Created by HoangNguyen on 9/30/18.
//

import Foundation
class ABDetailPresenter : NSObject {
    var detailInteractor : ABDetailInteractorInput?
    var detailWireframe : ABDetailWireframe?
    var detailModuleDelegate : ABDetailModuleDelegate?
    var detailUserInterface: ABDetailViewInterface?
}
extension ABDetailPresenter : ABDetailModuleInterface {
    func cancelSaveAction() {
        detailModuleDelegate?.detailModuleDidCancelSaveAction()
    }
    
    func saveAddressBookWithName(_ name: String, address: String) {
        detailUserInterface?.displaySpinner()
        detailInteractor?.saveAddressBookWithName(name, address: address)
    }
    
    func finishSaveAddressBook() {
        detailModuleDelegate?.detailModuleDidSaveAddressBook()
    }
}
extension ABDetailPresenter: ABDetailInteractorOutput {
    func errorWhileSaving(_ error: Error) {
        detailUserInterface?.removeSpinner()
        var errText = error.localizedDescription
        if let connError = error as? ConnectionError, connError.isApiError, let apiError = connError.apiError {
            errText = apiError.description
        }
        detailUserInterface?.displayError(errText)
    }
    func finishSaveWithSuccess() {
        detailUserInterface?.removeSpinner()
        detailUserInterface?.displaySuccess()
    }
}
