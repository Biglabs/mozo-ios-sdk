//
//  Localizable.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/12/19.
//

import Foundation
public protocol Localizable {
    var localized: String { get }
}
extension String: Localizable {
    public var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: BundleManager.mozoBundle(), value: "", comment: "")
    }
    
    public func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
    public var mainLocalized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    public func mainLocalizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.mainLocalized, arguments: arguments)
    }
}

public protocol XIBLocalizable {
    var xibLocKey: String? { get set }
    var mainLocalize: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable public var mainLocalize: String? {
        get { return nil }
        set(key) {
            text = key?.mainLocalized
        }
    }
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable public var mainLocalize: String? {
        get { return nil }
        set(key) {
            setTitle(key?.mainLocalized, for: .normal)
        }
    }
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}
extension UITextField: XIBLocalizable {
    @IBInspectable public var mainLocalize: String? {
        get { return nil }
        set(key) {
            placeholder = key?.mainLocalized
        }
    }
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}
extension UITabBarItem: XIBLocalizable {
    @IBInspectable public var mainLocalize: String? {
        get { return nil }
        set(key) {
            title = key?.mainLocalized
        }
    }
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}
