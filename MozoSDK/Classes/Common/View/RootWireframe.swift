//
//  RootWireframe.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

let PINViewControllerIdentifier = "PINViewController"
let PassPhraseViewControllerIdentifier = "PassPhraseViewController"
let WaitingViewControllerIdentifier = "WaitingViewController"
let TransferViewControllerIdentifier = "TransferViewController"
let ConfirmTransferViewControllerIdentifier = "ConfirmTransferViewController"
let TxCompletionViewControllerIdentifier = "TxCompletionViewController"
let TxDetailViewControllerIdentifier = "TxDetailViewController"
let AddressBookViewControllerIdentifier = "AddressBookViewController"
let ABDetailViewControllerIdentifier = "ABDetailViewController"
let ABEditViewControllerIdentifier = "ABEditViewController"
let TxHistoryViewControllerIdentifier = "TxHistoryViewController"
let TxHistoryDetailViewControllerIdentifier = "TxHistoryDetailViewController"
let MyWalletViewControllerIdentifier = "MyWalletViewController"
let PaymentViewControllerIdentifier = "PaymentViewController"
let PaymentQRViewControllerIdentifier = "PaymentQRViewController"
let PaymentSendSuccessViewControllerIdentifier = "PaymentSendSuccessViewController"
let ConvertViewControllerIdentifier = "ConvertViewController"
let ConfirmConvertViewControllerIdentifier = "ConfirmConvertViewController"
let TxProcessViewControllerIdentifier = "TxProcessViewController"
let ConvertCompletionViewControllerIdentifier = "ConvertCompletionViewController"
let ConvertFailedViewControllerIdentifier = "ConvertFailedViewController"
let ResetPINViewControllerIdentifier = "ResetPINViewController"
let ResetPINSuccessViewControllerIdentifier = "ResetPINSuccessViewController"
let SpeedSelectionViewControllerIdentifier = "SpeedSelectionViewController"
let WalletProcessingViewControllerIdentifier = "WalletProcessingViewController"
let BackupWalletViewControllerIdentifier = "BackupWalletViewController"
let BackupWalletSuccessViewControllerIdentifier = "BackupWalletSuccessViewController"
let ChangePINProcessViewControllerIdentifier = "ChangePINProcessViewController"
let ChangePINSuccessViewControllerIdentifier = "ChangePINSuccessViewController"
let ABImportViewControllerIdentifier = "ABImportViewController"
let TopUpTransferViewControllerIdentifier = "TopUpTransferViewController"
let TopUpFailureViewControllerIdentifier = "TopUpFailureViewController"

class RootWireframe : NSObject {
    let mozoNavigationController = MozoNavigationController()
    
    func showRootViewController(_ viewController: UIViewController, inWindow: UIWindow) {
        mozoNavigationController.viewControllers = [viewController]
        mozoNavigationController.modalPresentationStyle = .fullScreen
        if inWindow.rootViewController != nil {
            let topController = DisplayUtils.getTopViewController()
            if let controller = topController, let klass = DisplayUtils.getAuthenticationClass(), controller.isKind(of: klass) {
                controller.dismiss(animated: false, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let contrl = DisplayUtils.getTopViewController()
                    contrl?.present(self.mozoNavigationController, animated: true, completion: nil)
                }
            } else {
                topController?.present(mozoNavigationController, animated: true, completion: nil)
            }
        } else {
            inWindow.rootViewController = mozoNavigationController
        }
    }
    
    func displayViewController(_ viewController: UIViewController) {
        print("RootWireframe - Present \(viewController.self)")
        if mozoNavigationController.viewControllers.count > 0 || DisplayUtils.getTopViewController() is MozoNavigationController {
            // Need to call override function to push view controller
            var viewControllers : [UIViewController] = mozoNavigationController.viewControllers
            viewControllers.append(viewController)
            mozoNavigationController.setViewControllers(viewControllers, animated: false)
        } else {
            // Handle case: one of our mozo view controllers need to be displayed while MozoNavigationController is dismissed
            showRootViewController(viewController, inWindow: (UIApplication.shared.delegate?.window!)!)
        }
    }
    
    func changeRootViewController(_ newRootViewController: UIViewController) {
        mozoNavigationController.setViewControllers([newRootViewController], animated: false)
    }
    
    func presentViewController(_ viewController: UIViewController) {
        let top = getTopViewController()
        viewController.modalPresentationStyle = .fullScreen
        top?.present(viewController, animated: true, completion: nil)
    }
    
    func dismissTopViewController() {
        if mozoNavigationController.viewControllers.count > 1 {
            _ = mozoNavigationController.viewControllers.popLast()
        } else {
            closeAllMozoUIs(completion: {})
        }
    }
    
    public func getTopViewController() -> UIViewController! {
        let appDelegate = UIApplication.shared.delegate
        if let window = appDelegate!.window { return window?.visibleViewController }
        return nil
    }
    
    public func closeAllMozoUIs(completion: @escaping (() -> Swift.Void)) {
        if mozoNavigationController.viewControllers.count == 0 {
            completion()
        } else {
            mozoNavigationController.viewControllers.removeAll()
            mozoNavigationController.dismiss(animated: false) {
                print("Mozo: Dismiss Navigation Controller")
                completion()
            }
        }
    }
    
    public func closeToLastMozoUIs() {
        let controllers = mozoNavigationController.viewControllers
        // Check controllers count after get first
        if controllers.count > 0 {
            mozoNavigationController.setViewControllers([controllers[0]], animated: false)
        }
    }
}
