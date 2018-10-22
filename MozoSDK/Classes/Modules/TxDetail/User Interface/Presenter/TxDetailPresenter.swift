//
//  TxDetailPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/22/18.
//

import Foundation

class TxDetailPresenter : NSObject {
    var detailModuleDelegate: TxDetailModuleDelegate?
    
}

extension TxDetailPresenter : TxDetailModuleInterface {
    func requestAddToAddressBook(_ address: String) {
        detailModuleDelegate?.detailModuleRequestAddToAddressBook(address)
    }
}
