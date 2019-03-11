//
//  ConvertCompletionPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
class ConvertCompletionPresenter: NSObject {
    
}
extension ConvertCompletionPresenter: ConvertCompletionModuleInterface {
    func handleViewHash(_ hash: String) {
        guard let url = URL(string: "https://etherscan.io/tx/\(hash)") else { return }
        UIApplication.shared.open(url)
    }
}
