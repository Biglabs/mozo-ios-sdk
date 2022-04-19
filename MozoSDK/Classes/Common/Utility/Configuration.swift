//
//  Configuration.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/4/18.
//

import Foundation
import UIKit

public class Configuration {
    public static let DEBUG = false
    public static let GRANT_TYPE = "password"
    public static var FONT_SIZE: UIFontTextSize = UIFontTextSize(.xSmall)
    public static let DEVICE_TOKEN = "DEVICE_TOKEN"
    public static let LOCALE = Locale.current.identifier
    public static let PARAM_LANGUAGE = "?language=\(LOCALE)"
    
    public static let PAGING_SIZE = 100
    public static let MIN_PASSWORD_LENGTH = 6
    public static let MAX_NAME_LENGTH = 128
    public static let SHOW_MOZO_EQUIVALENT_CURRENCY = false
    
    // User id for anonymous user
    public static let USER_ID_ANONYMOUS = "Mozo@UserId@Anonymous"
    
    // Access token for anonymous user
    public static let ACCESS_TOKEN_ANONYMOUS = "Mozo@AccessToken@Anonymous"
    // Access token
    public static let ACCESS_TOKEN = "Mozo@AccessToken"
    // Pin Secrect
    public static let PIN_SECRET = "Mozo@PinSecret"
    // User info
    public static let USER_INFO = "Mozo@UserInfo"
    // User profile
    public static let USER_PROFILE = "Mozo@UserProfile"
    // User Notification history
    public static let USER_NOTI_HISTORY = "Mozo@UserNotiHistory_"
    // User Need to show Auto PIN screen
    public static let USER_NOT_SHOW_AUTO_PIN_SCREEN = "Mozo@UserNotShowAutoPINScreen_"
    
    //Wallet
    public static let WALLLET_ID = "WalletId"
    
    internal static var BASE_DOMAIN = ServiceType.DEVELOP
    public static let BASE_HOST = "https://\(BASE_DOMAIN.api)"
    public static let BASE_SOLO = "\(BASE_HOST)/solomon/api/app"
    public static let BASE_STORE_URL = "\(BASE_HOST)/store/api/app"
    public static let BASE_SCAN_URL = "\(BASE_HOST)/mozoscan/api/app"
    public static let BASE_NOTIFICATION_URL = "\(BASE_HOST)/notification/api/app"
    
    // WEB_SOCKET
    public static let WEB_SOCKET_URL = "wss://\(BASE_DOMAIN.socket)/websocket/user/"
    
    // MARK: Auth
    /**
     The OIDC issuer from which the configuration will be discovered.
     */
    // AUTHENTICATION
    public static let AUTH_ISSSUER = "https://\(BASE_DOMAIN.auth)/auth/realms/mozo"
    
    // IMAGE SERVER
    public static let DOMAIN_IMAGE = "https://\(BASE_DOMAIN.image)/api/public/"
    
    public static let BEGIN_SESSION_URL_PATH = "/protocol/openid-connect/auth"
    
    public static let END_SESSION_URL_PATH = "/protocol/openid-connect/logout"
    
    internal static let END_POINT_TOKEN_PATH = "/protocol/openid-connect/token"
    
    // LOGOUT WITH REDIRECT
    public static let LOGOUT_URL_WITH_REDIRECT_URI = "\(AUTH_ISSSUER)\(END_SESSION_URL_PATH)?redirect_uri="
    
    public static let AUTH_CLIENT_ID = "native_app"
    
    public static let AUTH_RETAILER_CLIENT_ID = "retailer_mobile_app"
    
    public static let AUTH_SHOPPER_CLIENT_ID = "shopper_mobile_app"
    
    public static let AUTH_STATE = "Mozo@AuthState"
    public static let AUTH_ID_TOKEN = "Mozo@IdToken"
    
    public static let TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS = 5
    
    static func authRedirectURL() -> String {
        return "com.biglabs.mozosdk.\(String(describing: Bundle.main.bundleIdentifier!)):/oauth2redirect/mozo-provider"
    }
}
