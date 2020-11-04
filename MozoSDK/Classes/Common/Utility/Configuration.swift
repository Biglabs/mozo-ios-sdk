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
    public static var SUB_DOMAIN_ENUM = ServiceType.DEV
    public static let SUB_DOMAIN = SUB_DOMAIN_ENUM.rawValue
    public static let GRANT_TYPE = "password"
    public static let MIN_PASSWORD_LENGTH = 6
    public static let MAX_NAME_LENGTH = 128
    public static var FONT_SIZE: UIFontTextSize = UIFontTextSize(.xSmall)
    public static let DEVICE_TOKEN = "DEVICE_TOKEN"
    public static let API_KEY_DEFAULT = "API_KEY_DEFAULT"
    public static let LOCALE = Locale.current.identifier
    public static let PARAM_LANGUAGE = "?language=\(LOCALE)"
    
    // User id for anonymous user
    public static let USER_ID_ANONYMOUS = "Mozo@UserId@Anonymous"
    
    // Access token for anonymous user
    public static let ACCESS_TOKEN_ANONYMOUS = "Mozo@AccessToken@Anonymous"
    // Access token
    public static let ACCESS_TOKEN = "Mozo@AccessToken"
    // Pin Secrect
    public static let PIN_SECRET = "Mozo@PinSecret"
    public static let JWT_TOKEN_CLAIM_PIN_SECRET = "pin_secret"
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
    
    public static let DOMAIN = "\(SUB_DOMAIN)gateway.mozocoin.io"
    public static let API_APP_PATH = "/api/app"
    
    public static let BASE_HOST = "https://\(DOMAIN)"
    public static let BASE_URL = "\(BASE_HOST)/solomon\(API_APP_PATH)"
    public static let BASE_STORE_URL = "\(BASE_HOST)/store\(API_APP_PATH)"
    public static let BASE_NOTIFICATION_URL = "\(BASE_HOST)/notification\(API_APP_PATH)"
    
    // WEB_SOCKET
    public static let WEB_SOCKET_BASE = SUB_DOMAIN_ENUM.socket
    public static let WEB_SOCKET_URL = "wss://\(WEB_SOCKET_BASE)/websocket/user/"
    
    // MARK: Auth
    /**
     The OIDC issuer from which the configuration will be discovered.
     */
    // AUTHENTICATION
    public static let AUTH_BASE = SUB_DOMAIN_ENUM.auth
    public static let AUTH_ISSSUER = "https://\(AUTH_BASE)mozocoin.io/auth/realms/mozo"
    
    // IMAGE SERVER
    public static let DOMAIN_IMAGE = "https://\(SUB_DOMAIN)image.mozocoin.io/api/public/"
    
    public static let BEGIN_SESSION_URL_PATH = "/protocol/openid-connect/auth"
    
    public static let END_SESSION_URL_PATH = "/protocol/openid-connect/logout"
    
    internal static let END_POINT_TOKEN_PATH = "/protocol/openid-connect/token"
    
    // LOGOUT WITH REDIRECT
    public static let LOGOUT_URL_WITH_REDIRECT_URI = "\(AUTH_ISSSUER)\(END_SESSION_URL_PATH)?redirect_uri="
    
    /**
     The OAuth client ID.
     For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
     Set to nil to use dynamic registration with this example.
     */
    public static let AUTH_CLIENT_ID = "native_app"
    
    public static let AUTH_RETAILER_CLIENT_ID = "retailer_mobile_app"
    
    public static let AUTH_SHOPPER_CLIENT_ID = "shopper_mobile_app"
    
    public static let AUTH_PARAM_KC_LOCALE = "kc_locale"
    
    public static let AUTH_PARAM_APPLICATION_TYPE = "application_type"
    
    public static let AUTH_PARAM_APPLICATION_TYPE_VALUE = "native"
    
    public static let AUTH_PARAM_PROMPT = "prompt"
    
    /**
     The OAuth redirect URI for the client @c kClientID.
     For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
     */
//    public static let AUTH_REDIRECT_URL = "com.biglabs.mozosdk:/oauth2redirect/mozo-provider"
    
    //public static let AUTH_REDIRECT_CALLBACK_PATH = "oauth2redirect/mozo-provider"
    
//    public static let AUTH_REDIRECT_URL = "\((Bundle.main.bundleIdentifier ?? "").lowercased())://\(AUTH_REDIRECT_CALLBACK_PATH)"
    
    //public static let AUTH_REDIRECT_URL = "com.biglabs.mozosdk://\(AUTH_REDIRECT_CALLBACK_PATH)"
    
    //public static let AUTH_REDIRECT_URL_FOR_IOS_10 = "\(Bundle.main.bundleIdentifier ?? "")://\(AUTH_REDIRECT_CALLBACK_PATH)"
    
    /**
     NSCoding key for the authState property.
     */
    public static let AUTH_STATE = "Mozo@AuthState"
    public static let AUTH_ID_TOKEN = "Mozo@IdToken"
    
    public static let TIME_TO_USER_READ_AUTO_PIN_IN_SECONDS = 10
    
    // Landing page
    public static let LANDING_PAGE_URL = "https://\(SUB_DOMAIN)mozocoin.io"
    
    public static func authRedirectURL() -> String {
//        if #available(iOS 10, *) {
//            return AUTH_REDIRECT_URL_FOR_IOS_10
//        }
//        return AUTH_REDIRECT_URL
        return "com.biglabs.mozosdk.\(String(describing: Bundle.main.bundleIdentifier!)):/oauth2redirect/mozo-provider"
    }
    
    public static let MAX_DAY_OF_COVID = 24
}
