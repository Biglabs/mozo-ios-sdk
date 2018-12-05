//
//  PaymentWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 12/4/18.
//

import Foundation
class PaymentWireframe: MozoWireframe {
    var presenter: PaymentPresenter?
    
    func presentScannerQRCodeInterface() {
        let viewController = ScannerViewController()
        viewController.delegate = presenter
        rootWireframe?.presentViewController(viewController)
    }
}
