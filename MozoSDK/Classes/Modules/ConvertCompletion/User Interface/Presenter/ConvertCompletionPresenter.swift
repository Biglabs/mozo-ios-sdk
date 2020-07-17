//
//  ConvertCompletionPresenter.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/11/19.
//

import Foundation
import UIKit
class ConvertCompletionPresenter: NSObject {
    
}
extension ConvertCompletionPresenter: ConvertCompletionModuleInterface {
    func handleViewHash(_ hash: String, controller: UIViewController) {
        controller.openLink(link: "https://etherscan.io/tx/\(hash)")
    }
}
