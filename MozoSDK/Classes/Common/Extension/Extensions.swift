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
    public var toString: String {
        let value = self
        return "\(value)"
    }
}

public extension String {
    public func isValidReceiveFormat() -> Bool{
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z]+:[a-zA-Z0-9]+\\?[a-zA-Z]+=[0-9.]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public func isValidDecimalFormat() -> Bool{
        return Float(self) != nil
    }
    
    public func isValidDecimalMinValue(decimal: Int) -> Bool {
        let divisor = pow(10.0, Double(decimal))
        return Float(self)! >= Float(1 / divisor)
    }
    
    public func isValidName() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9_-]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public func isValidEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public func isValidPhoneNumber() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\\s\\./0-9]*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    public var toBool: Bool? {
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
    
    public func replace(_ originalString:String, withString newString:String) -> String {
        let replaced =  self.replacingOccurrences(of: originalString, with: newString)
        return replaced
    }
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    public func hasPrefix(_ prefix: String, caseSensitive: Bool) -> Bool {
        if !caseSensitive { return hasPrefix(prefix) }
        return self.lowercased().hasPrefix(prefix.lowercased())
    }
    
    public func censoredMiddle() -> String {
        let prefix = self[0..<3]
        let middle = "********"
        let end = self[count - 3..<count]
        return "\(prefix)\(middle)\(end)"
    }
    
    public func toDoubleValue() -> Double {
        // FIX ISSUE: [MOZO-254] Round Issue in swift
        return (NumberFormatter().number(from: self)?.doubleValue)!
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
    public var deviceToken: String {
        return self.reduce("", {$0 + String(format: "%02X", $1)})
    }
}

public extension UIViewController {
    public func isModal() -> Bool {
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

extension UIColor {
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

extension UIView {
    func roundCorners(cornerRadius: CGFloat = 0.02, borderColor: UIColor, borderWidth: CGFloat) {
        layer.cornerRadius = cornerRadius * bounds.size.width
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension Decimal {
    var toDouble:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
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

extension UINavigationController {
    public var rootViewController : UIViewController? {
        return self.viewControllers.first
    }
}

public extension Array {
    //MARK: - using this method to avoid out of index
    public func getElement(_ index: Int) -> Element? {
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
        let roundedBalance = self.rounded(toPlaces: 2)
        let number = NSNumber(value: roundedBalance)
        return number.addCommas()
    }
}

public extension NSNumber {
    func convertOutputValue(decimal: Int) -> Double{
        let retValue = Double(truncating: self) / Double(truncating: pow(10, decimal) as NSNumber)
        return retValue
    }
    
    func addCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: self)
        return formattedNumber ?? "0"
    }
}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output += "\(key)=\(value)&"
        }
        return output
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
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
                return "Just Now"
            }
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}

extension Notification.Name {
    static let didAuthenticationSuccessWithMozo = Notification.Name("didAuthenticationSuccessWithMozo")
    static let didLogoutFromMozo = Notification.Name("didLogoutFromMozo")
    static let didChangeBalance = Notification.Name("didChangeBalance")
    static let didReceiveDetailDisplayItem = Notification.Name("didReceiveDetailDisplayItem")
    static let didLoadTokenInfoFailed = Notification.Name("didLoadTokenInfoFailed")
    static let didReceiveExchangeInfo = Notification.Name("didReceiveExchangeInfo")
    static let didChangeAddressBook = Notification.Name("didChangeAddressBook")
    static let didChangeStoreBook = Notification.Name("didChangeStoreBook")
}
