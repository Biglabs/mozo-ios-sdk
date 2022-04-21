//
//  DisplayUtils.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/27/18.
//

import Foundation
public class DisplayUtils {
    public static func viewImages(_ parent: UIViewController, paths: [String], selected: Int = 0) {
        ImageViewerVC.launch(parent, paths, selected)
    }
    
    public static func getExchangeTextFromAmount(_ amount: Double) -> String {
        let rateInfo = SessionStoreManager.exchangeRateInfo
        let curType = (rateInfo?.currency ?? CurrencyType.USD.rawValue)
        if let curSymbol = rateInfo?.currencySymbol {
            var exValue = (amount * (rateInfo?.rate ?? 0)).roundAndAddCommas()
            if curType == CurrencyType.VND.rawValue {
                exValue = (((amount * (rateInfo?.rate ?? 0)) / 1000).rounded() * 1000).addCommas()
            }
            let exValueStr = "\(curSymbol)\(exValue)"
            return exValueStr
        }
        return "\(rateInfo?.currencySymbol ?? "")0"
    }
    
    public static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 9, y: 9)
            
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
        
    public static func displayTryAgainPopupInParentView(parentView: UIView,
                                                        allowTapToDismiss: Bool = true,
                                                        isEmbedded: Bool = false,
                                                        error: ConnectionError? = nil,
                                                        delegate: PopupErrorDelegate) {
        if error == ConnectionError.apiError_MAINTAINING {
            displayMaintenanceScreen()
            return
        }
        let popupWidth = 315
        let popupHeight = error == .requestTimedOut ? popupWidth : 384
        let mozoPopupErrorView = MozoPopupErrorView(frame: CGRect(x: 0, y: 0, width: popupWidth, height: popupHeight))
        mozoPopupErrorView.delegate = delegate
        mozoPopupErrorView.shouldTrackNetwork = !isEmbedded
        mozoPopupErrorView.isEmbedded = isEmbedded
        if let err = error {
            mozoPopupErrorView.error = err
        }
        
        if !isEmbedded {
            mozoPopupErrorView.clipsToBounds = false
            mozoPopupErrorView.dropShadow()
            mozoPopupErrorView.containerView.roundCorners(borderColor: .white, borderWidth: 1)
        }
        mozoPopupErrorView.center = parentView.center
        
        // cover view
        let displayWidth: CGFloat = parentView.frame.width
        let displayHeight: CGFloat = parentView.frame.height
        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        if !isEmbedded {
            coverView.backgroundColor = .black
            coverView.alpha = 0.5
        } else {
            coverView.backgroundColor = .white
        }
        parentView.addSubview(coverView)
        
        if allowTapToDismiss {
            let coverViewTap = UITapGestureRecognizer(target: mozoPopupErrorView, action: #selector(MozoPopupErrorView.dismissView))
            coverView.addGestureRecognizer(coverViewTap)
            
            mozoPopupErrorView.modalCloseHandler = {
                mozoPopupErrorView.forceDisable()
                mozoPopupErrorView.removeFromSuperview()
                coverView.removeFromSuperview()
            }
        }
        
        mozoPopupErrorView.tapTryHandler = {
            mozoPopupErrorView.forceDisable()
            mozoPopupErrorView.removeFromSuperview()
            coverView.removeFromSuperview()
        }
        
        parentView.addSubview(mozoPopupErrorView)
    }
    
    public static func displayTryAgainPopup(allowTapToDismiss: Bool = true,
                                            isEmbedded: Bool = false,
                                            error: ConnectionError? = nil,
                                            delegate: PopupErrorDelegate) {
        if error == ConnectionError.apiError_MAINTAINING {
            displayMaintenanceScreen()
            return
        }
        if let topViewController = getTopViewController(), let parentView = topViewController.view {
            DisplayUtils.displayTryAgainPopupInParentView(parentView: parentView,
                                                          allowTapToDismiss: allowTapToDismiss,
                                                          isEmbedded: isEmbedded,
                                                          error: error,
                                                          delegate: delegate)
        }
    }
    
    public static func displayMozoErrorWithContact(_ error: String, delegate: MozoPopupContactDelegate? = nil) {
        if let parentView = UIApplication.shared.keyWindow {
            let mozoContactView = MozoPopupContact(frame: CGRect(x: 0, y: 0, width: 300, height: 340))
            mozoContactView.appType = MozoSDK.appType
            mozoContactView.clipsToBounds = false
            mozoContactView.dropShadow()
            mozoContactView.containerView.roundCorners(borderColor: .white, borderWidth: 1)
            
            mozoContactView.center = parentView.center
            
            mozoContactView.errorMessage = error
            mozoContactView.delegate = delegate
            
            // cover view
            let displayWidth: CGFloat = parentView.frame.width
            let displayHeight: CGFloat = parentView.frame.height
            let coverView = UIView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
            coverView.backgroundColor = .black
            coverView.alpha = 0.5
            parentView.addSubview(coverView)
            
            let coverViewTap = UITapGestureRecognizer(target: mozoContactView, action: #selector(MozoPopupContact.dismissView))
            coverView.addGestureRecognizer(coverViewTap)
            
            mozoContactView.modalCloseHandler = {
                mozoContactView.removeFromSuperview()
                coverView.removeFromSuperview()
            }
            
            parentView.addSubview(mozoContactView)
        }
    }
    
    public static func formatMessageTime(time: Double) -> String {
        let today = Calendar.current
        let date = Date(timeIntervalSince1970: time)
        let years = today.dateComponents([.year], from: Date(), to: date).year
        
        var pattern = "MMM dd, yyyy"
        if today.isDateInToday(date) {
            pattern = "HH:mm"
        } else if years == 0 {
            pattern = "MMM dd"
        }
        
        return convertDateToStringWithFormat(date, format: pattern.localized)
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
    
    public static func getTopViewController() -> UIViewController? {
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
                return AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.soloAddress ?? "", physicalAddress: "", isStoreBook: false, phoneNo: item.phoneNo ?? "")
            } else {
                if let item = StoreBookDTO.storeBookFromAddress(address, array: SafetyDataManager.shared.storeBookList) {
                    return AddressBookDisplayItem(id: item.id ?? 0, name: item.name ?? "", address: item.offchainAddress ?? "", physicalAddress: item.physicalAddress ?? "", isStoreBook: true, phoneNo: item.phoneNo ?? "")
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
    
    public static func defaultNoContentView(_ frame: CGRect, message: String, imageName: String = "img_no_content") -> UIView {
        let noContentView = UIView(frame: frame)
        let image = UIImage(named: imageName, in: BundleManager.mozoBundle(), compatibleWith: nil)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 156, height: 150))
        imageView.image = image
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 40, height: 18))
        label.textAlignment = .center
        label.text = message.localized
        label.textColor = ThemeManager.shared.disable
        label.font = UIFont.italicSystemFont(ofSize: 15)
        
        imageView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let lbFrameCenter = CGPoint(x: imageView.center.x, y: imageView.center.y + (imageView.frame.size.height / 2) + 15)
        label.center = lbFrameCenter
        
        noContentView.addSubview(label)
        noContentView.addSubview(imageView)
        
        return noContentView
    }
    
    public static func getHelpCenterPath() -> String {
        return "/help-center\(Configuration.PARAM_LANGUAGE)"
    }
    
    public static func getAuthenticationClass() -> AnyClass? {
        return AuthWebVC.classForCoder()
    }
    
    public static func isAuthenticationOnTop() -> Bool {
         if let topViewController = getTopViewController(), let klass = getAuthenticationClass(), topViewController.isKind(of: klass) {
            return true
         } else {
            return false
         }
    }
}
