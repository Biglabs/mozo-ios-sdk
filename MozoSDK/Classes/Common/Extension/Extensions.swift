//
//  Extensions.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 8/28/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import Foundation
import UIKit

public extension Bool {
    var toString: String {
        let value = self
        return "\(value)"
    }
}

public extension String {
    func asMozoImage() -> UIImage? {
        return UIImage(named: self, in: BundleManager.mozoBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }
    
    func isValidReceiveFormat() -> Bool{
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z]+:[a-zA-Z0-9]+\\?[a-zA-Z]+=[0-9.]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    func isValidDecimalFormat() -> Bool{
        let text = self.toTextNumberWithoutGrouping()
        return Float(text) != nil
    }
    
    func isValidDecimalMinValue(decimal: Int) -> Bool {
        let divisor = pow(10.0, Double(decimal))
        return Float(self)! >= Float(1 / divisor)
    }
    
    func isValidName() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9_-]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    func isValidEmail() -> Bool {
        // Old regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        // The new regex follow RFC 5322 standard
        let regex = try? NSRegularExpression(pattern: "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
        "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    func isValidPhoneNumber() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    var toBool: Bool? {
        let trueValues = ["true", "yes", "1"]
        let falseValues = ["false", "no", "0"]
        
        let lowerSelf = self.lowercased()
        
        if trueValues.contains(lowerSelf) {
            return true
        } else if falseValues.contains(lowerSelf) {
            return false
        } else {
            return nil
        }
    }
    
    func replace(_ originalString:String, withString newString:String) -> String {
        let replaced =  self.replacingOccurrences(of: originalString, with: newString)
        return replaced
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func hasPrefix(_ prefix: String, caseSensitive: Bool) -> Bool {
        if !caseSensitive { return hasPrefix(prefix) }
        return self.lowercased().hasPrefix(prefix.lowercased())
    }
    
    func censoredMiddle() -> String {
        let prefix = self[0..<3]
        let middle = "********"
        let end = self[count - 3..<count]
        return "\(prefix)\(middle)\(end)"
    }
    
    func toDoubleValue() -> Double {
        // FIX ISSUE: [MOZO-254] Round Issue in swift
        return NSDecimalNumber(string: self).doubleValue + (1 / pow(10, 15))
    }
    
    func toTextNumberWithoutGrouping() -> String {
        let decimalSeparator = NSLocale.current.decimalSeparator ?? "."
        let groupingSeparator = NSLocale.current.groupingSeparator ?? ","
        return self.replace(groupingSeparator, withString: "").replace(decimalSeparator, withString: ".")
    }
    
    func hasValidSchemeForQRCode() -> Bool {
        return hasPrefix(AppType.Retailer.scheme) || hasPrefix(AppType.Shopper.scheme)
    }
    
    var isMozoErrorWithContact: Bool {
        return contains(" (email + phone)") || contains(" (phone + email)") || contains(" (이메일 + 전화)") || contains(" (전화 + 이메일)")
    }
    
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func log() {
        if MozoSDK.network != .MainNet {
            print("[Mozo] \(self)")
        }
    }
    
    func split(usingRegex pattern: String) -> [String] {
        //### Crashes when you pass invalid `pattern`
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }
    
    func summary() -> String {
        let result = self.split(usingRegex: "\\.|\r\n|\n")
        return (result.first ?? self) + ((result.count > 1 && !result[1].isEmpty) ? "…" : "")
    }
}

internal extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    var hasOnlyNewlineSymbols: Bool {
        return trimmingCharacters(in: CharacterSet.newlines).isEmpty
    }
}

public extension Data {
    var deviceToken: String {
        return self.reduce("", {$0 + String(format: "%02X", $1)})
    }
}

public extension UIViewController {
    func isModal() -> Bool {
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
        
        if self.presentingViewController != nil {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public extension UIView {
    func roundedAvatar() {
        roundedCircle()
        layer.borderWidth = 1
        layer.borderColor = UIColor(hexString: "cacaca").cgColor
    }
    
    func roundCorners(cornerRadius: CGFloat = 0.02, borderColor: UIColor, borderWidth: CGFloat) {
        layer.cornerRadius = cornerRadius * bounds.size.width
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true
    }
    
    func roundedCircle() {
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    func roundCornersBezier(frame: CGRect, corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func dropShadow(scale: Bool = true, color: UIColor = UIColor.black, isOnlyBottom: Bool = false) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = isOnlyBottom ? CGSize(width: 0.0, height: 3.0) : CGSize.zero
        layer.shadowRadius = isOnlyBottom ? 1.5 : 3
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addGradientLayer(colors: [CGColor], locations: [NSNumber]? = nil, frame: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors
        gradient.locations = locations
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradient, at: 0)
    }
}

public extension Decimal {
    var toDouble:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}

public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            if let visibleViewController = nc.visibleViewController {
                return UIWindow.getVisibleViewControllerFrom(visibleViewController)
            }
            if let lastViewController = nc.viewControllers.last {
                return UIWindow.getVisibleViewControllerFrom(lastViewController)
            }
            return vc
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

public extension UINavigationController {
    var rootViewController : UIViewController? {
        return self.viewControllers.first
    }
}

public extension Array {
    //MARK: - using this method to avoid out of index
    func getElement(_ index: Int) -> Element? {
        return (0 <= index && index < self.count ? self[index] : nil)
    }
}

internal extension Int {
    func times(f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    func times( f: @autoclosure () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
}

public extension Int {
    func addCommas() -> String {
        let number = NSNumber(value: self)
        return number.addCommas()
    }
}

public extension Int64 {
    func addCommas() -> String {
        let number = NSNumber(value: self)
        return number.addCommas()
    }
}

public extension Double {
    func convertTokenValue(decimal: Int) -> NSNumber{
        let retValue = NSNumber(value: self * Double(truncating: pow(10, decimal) as NSNumber))
        return retValue
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundAndAddCommas(toPlaces places:Int = 2) -> String {
        let roundedBalance = self.rounded(toPlaces: places)
        let number = NSNumber(value: roundedBalance)
        return number.addCommas()
    }
    
    func addCommas() -> String {
        let number = NSNumber(value: self)
        return number.addCommas()
    }
    
    func removeZerosFromEnd(maximumFractionDigits: Int = 16) -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? " ")
    }
    
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

public extension NSNumber {
    func convertOutputValue(decimal: Int) -> Double {
        let retValue = Double(truncating: self) / Double(truncating: pow(10, decimal) as NSNumber)
        return retValue
    }
    
    func addCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: self)
        return formattedNumber ?? "0"
    }
    
    func roundAndAddCommas(toPlaces places:Int = 2) -> String {
        let decimalNumber = NSDecimalNumber(decimal: self.decimalValue)
        let rounded = decimalNumber.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .up, scale: Int16(places), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
        return rounded.addCommas()
    }
}

public extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output += "\(key)=\(value)&"
        }
        return output
    }
}

public extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
    
    mutating func appendQueryItem(name: String, value: String?) {

        guard var urlComponents = URLComponents(string: absoluteString) else { return }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        if let index = queryItems.firstIndex(of: queryItem) {
            queryItems.remove(at: index)
        }
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
    }
}
public extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            if diff < 30 {
                return "Just now".localized
            }
            return "%d sec(s) ago".localizedFormat(diff)
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "%d min(s) ago".localizedFormat(diff)
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "%d hour(s) ago".localizedFormat(diff)
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "%d day(s) ago".localizedFormat(diff)
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "%d week(s) ago".localizedFormat(diff)
    }
}

public extension Notification.Name {
    static let didAuthenticationSuccessWithMozo = Notification.Name("didAuthenticationSuccessWithMozo")
    static let didLogoutFromMozo = Notification.Name("didLogoutFromMozo")
    static let didCloseAllMozoUI = Notification.Name("didCloseAllMozoUI")
    static let didChangeBalance = Notification.Name("didChangeBalance")
    static let didConvertSuccessOnchainToOffchain = Notification.Name("didConvertSuccessOnchainToOffchain")
    static let didReceiveDetailDisplayItem = Notification.Name("didReceiveDetailDisplayItem")
    static let didLoadTokenInfoFailed = Notification.Name("didLoadTokenInfoFailed")
    static let didReceiveOnchainDetailDisplayItem = Notification.Name("didReceiveOnchainDetailDisplayItem")
    static let didReceiveETHDetailDisplayItem = Notification.Name("didReceiveETHDetailDisplayItem")
    static let didReceiveETHOffchainDetailDisplayItem = Notification.Name("didReceiveETHOffchainDetailDisplayItem")
    static let didLoadETHOnchainTokenInfoFailed = Notification.Name("didLoadETHOnchainTokenInfoFailed")
    static let didReceiveExchangeInfo = Notification.Name("didReceiveExchangeInfo")
    static let didChangeAddressBook = Notification.Name("didChangeAddressBook")
    static let didChangeStoreBook = Notification.Name("didChangeStoreBook")
    static let didChangeProfile = Notification.Name("didChangeProfile")
    static let didMeetMaintenance = Notification.Name("didMeetMaintenance")
    static let didMaintenanceComplete = Notification.Name("didMaintenanceComplete")
    static let didExpiredToken = Notification.Name("didExpiredToken")
    static let openStoreDetailsFromHistory = Notification.Name("openStoreDetailsFromHistory")
}
