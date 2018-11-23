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
    public static let SUB_DOMAIN_ENUM = ServiceType.DEV
    public static let SUB_DOMAIN = SUB_DOMAIN_ENUM.rawValue
    public static let GRANT_TYPE = "password"
    public static let MIN_PASSWORD_LENGTH = 6
    public static let MAX_ADDRESS_BOOK_NAME_LENGTH = 24
    public static var FONT_SIZE: UIFontTextSize = UIFontTextSize(.xSmall)
    public static let DEVICE_TOKEN = "DEVICE_TOKEN"
    public static let API_KEY_DEFAULT = "API_KEY_DEFAULT"
    public static let LOCALE = Locale.current.languageCode ?? "en"
    
    // User id for anonymous user
    public static let USER_ID_ANONYMOUS = "Mozo@UserId@Anonymous"
    
    // Access token for anonymous user
    public static let ACCESS_TOKEN_ANONYMOUS = "Mozo@AccessToken@Anonymous"
    // Access token
    public static let ACCESS_TOKEN = "Mozo@AccessToken"
    // User info
    public static let USER_INFO = "Mozo@UserInfo"
    // User profile
    public static let USER_PROFILE = "Mozo@UserProfile"
    
    //Wallet
    public static let WALLLET_ID = "WalletId"
    
    public static let DOMAIN = "\(SUB_DOMAIN)gateway.mozocoin.io"
    public static let BASE_URL = "https://\(DOMAIN)/solomon"
    public static let BASE_STORE_URL = "https://\(DOMAIN)/store"
    // WEB_SOCKET
    public static let WEB_SOCKET_BASE = SUB_DOMAIN_ENUM.socket
    public static let WEB_SOCKET_URL = "ws://\(WEB_SOCKET_BASE)/websocket/user/"
    
    // MARK: Auth
    /**
     The OIDC issuer from which the configuration will be discovered.
     */
    // STAGING
    public static let AUTH_ISSSUER = "https://\(SUB_DOMAIN)keycloak.mozocoin.io/auth/realms/mozo"
    
    /**
     The OAuth client ID.
     For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
     Set to nil to use dynamic registration with this example.
     */
    public static let AUTH_CLIENT_ID = "native_app"
    
    public static let AUTH_PARAM_KC_LOCALE = "kc_locale"
    
    /**
     The OAuth redirect URI for the client @c kClientID.
     For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
     */
    public static let AUTH_REDIRECT_URL = "com.biglabs.mozosdk:/oauth2redirect/mozo-provider"
    
    /**
     NSCoding key for the authState property.
     */
    public static let AUTH_STATE = "Mozo@AuthState"
}
