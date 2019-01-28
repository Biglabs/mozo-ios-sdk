//
//  DisplayUtils.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/27/18.
//

import Foundation
public class DisplayUtils {
    public static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return UIImage.init(named: "ic_qr_code")
    }
    
    public static func displayQRView(address: String) {
        if let parentView = UIApplication.shared.keyWindow {
        
            let displayWidth: CGFloat = parentView.frame.width
            let displayHeight: CGFloat = parentView.frame.height
            let viewFrame = CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight)
            
            // cover view
            let coverView = UIView(frame: viewFrame)
            coverView.backgroundColor = .black
            coverView.alpha = 0.5
            parentView.addSubview(coverView)
            
            let view = MozoQRView(frame: CGRect(x: 0, y: 0, width: 254, height: 284))
            let img = generateQRCode(from: address)
            view.qrImage = img
            view.coverView = coverView
            
            view.clipsToBounds = false
            view.dropShadow()
            view.containerView.roundCorners(borderColor: .white, borderWidth: 1)
            
            view.center = parentView.center
            parentView.addSubview(view)
        }
    }
    
    public static func displayTryAgainPopup(allowTapToDismiss: Bool = true,
                                            error: ConnectionError? = nil,
                                            delegate: PopupErrorDelegate) {
        if let topViewController = getTopViewController(), let parentView = topViewController.view {
            let mozoPopupErrorView = MozoPopupErrorView(frame: CGRect(x: 0, y: 0, width: 315, height: 315))
            mozoPopupErrorView.delegate = delegate
            if let err = error {
                mozoPopupErrorView.error = err
            }
            
            mozoPopupErrorView.clipsToBounds = false
            mozoPopupErrorView.dropShadow()
            mozoPopupErrorView.containerView.roundCorners(borderColor: .white, borderWidth: 1)
            
            mozoPopupErrorView.center = parentView.center
            
            // cover view
            let displayWidth: CGFloat = parentView.frame.width
            let displayHeight: CGFloat = parentView.frame.height
            let coverView = UIView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
            coverView.backgroundColor = .black
            coverView.alpha = 0.5
            parentView.addSubview(coverView)
            
            if allowTapToDismiss {
                let coverViewTap = UITapGestureRecognizer(target: mozoPopupErrorView, action: #selector(MozoPopupErrorView.dismissView))
                coverView.addGestureRecognizer(coverViewTap)
                
                mozoPopupErrorView.modalCloseHandler = {
                    mozoPopupErrorView.removeFromSuperview()
                    coverView.removeFromSuperview()
                }
            }
            
            mozoPopupErrorView.tapTryHandler = {
                mozoPopupErrorView.removeFromSuperview()
                coverView.removeFromSuperview()
            }
            
            parentView.addSubview(mozoPopupErrorView)
        }
    }
    
    public static func convertInt64ToStringWithFormat(_ dateInt64: Int64, format: String) -> String{
        let date = Date(timeIntervalSince1970:Double(dateInt64))
        return convertDateToStringWithFormat(date, format: format)
    }
    
    public static func convertDateToStringWithFormat(_ date: Date, format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        let dateString:String = dateFormatter.string(from: date)
        return dateString
    }
    
//    public static func showError(_ connectionError: Error) {
//        switch connectionError {
//        case ConnectionError.noInternetConnection:
//            JDStatusBarNotification.show(withStatus: ConnectionError.noInternetConnection.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleDark)
//        case ConnectionError.requestTimedOut:
//            JDStatusBarNotification.show(withStatus: ConnectionError.requestNotFound.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleDark)
//        case ConnectionError.requestNotFound:
//            JDStatusBarNotification.show(withStatus: ConnectionError.requestNotFound.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleError)
//        case ConnectionError.authenticationRequired:
//            JDStatusBarNotification.show(withStatus: ConnectionError.authenticationRequired.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleError)
//        case ConnectionError.badRequest:
//            JDStatusBarNotification.show(withStatus: ConnectionError.badRequest.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleError)
//        case ConnectionError.internalServerError:
//            JDStatusBarNotification.show(withStatus: ConnectionError.internalServerError.localizedDescription, dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleError)
//        case ConnectionError.network(let error):
//            print("Error: \(error)")
//        default:
//            JDStatusBarNotification.show(withStatus: "Network Error.", dismissAfter: notificationDismissAfter, styleName: JDStatusBarStyleError)
//        }
//    }
    
    public static func getTopViewController() -> UIViewController! {
        let appDelegate = UIApplication.shared.delegate
        if let window = appDelegate!.window { return window?.visibleViewController }
        return nil
    }
    
    public static func buildNameFromAddress(address: String) -> String {
        var displayName = address
        if !address.isEmpty {
            let list = SafetyDataManager.shared.addressBookList
            if let ab = AddressBookDTO.addressBookFromAddress(address, array: list), let name = ab.name {
                displayName = name
            } else {
                if let sb = StoreBookDTO.storeBookFromAddress(address, array: SafetyDataManager.shared.storeBookList), let name = sb.name {
                    displayName = name
                }
            }
        }
        return displayName
    }
    
    public static func buildContactDisplayItem(address: String) -> AddressBookDisplayItem? {
        if !address.isEmpty {
            if let item = AddressBookDTO.addressBookFromAddress(address, array: SafetyDataManager.shared.addressBookList) {
                return AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.soloAddress ?? "", physicalAddress: "", isStoreBook: false)
            } else {
                if let item = StoreBookDTO.storeBookFromAddress(address, array: SafetyDataManager.shared.storeBookList) {
                    return AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.offchainAddress ?? "", physicalAddress: item.physicalAddress ?? "", isStoreBook: true)
                }
            }
        }
        
        return nil
    }
    
    public static func displayUnderConstructionPopup() {
        if let topViewController = getTopViewController() {
            let alert = UIAlertController(title: "Under Construction".localized, message: "Coming soon".localized, preferredStyle: .alert)
            alert.addAction(.init(title: "OK".localized, style: .default, handler: nil))
            topViewController.present(alert, animated: true, completion: nil)
        }
    }
}
