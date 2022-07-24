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
        let language = UserDefaults.standard.string(forKey: "AppLanguage")
        let bundlePath = BundleManager.mozoBundle().path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: bundlePath!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    public func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

public protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            text = key?.localized
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}
extension UITextField: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            placeholder = key?.localized
        }
    }
}
extension UITabBarItem: XIBLocalizable {
    @IBInspectable public var xibLocKey: String? {
        get { return nil }
        set(key) {
            title = key?.localized
        }
    }
}
