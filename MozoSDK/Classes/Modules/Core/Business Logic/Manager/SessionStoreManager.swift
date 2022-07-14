//
//  SessionStoreManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/6/18.
//

import Foundation

public class SessionStoreManager {
    private static var userInfo: UserDTO?
    
    public static func loadCurrentUser() -> UserDTO? {
        if let user = userInfo {
            return user
            
        } else if let userData = UserDefaults.standard.data(forKey: Configuration.USER_INFO) {
            if let user = try? JSONDecoder().decode(UserDTO.self, from: userData) {
                userInfo = user
                return user
            }
        }
        return nil
    }
    
    public static func saveCurrentUser(user: UserDTO) {
        userInfo = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: Configuration.USER_INFO)
        }
    }
    
    public static func clearCurrentUser() {
        userInfo = nil
        UserDefaults.standard.removeObject(forKey: Configuration.USER_INFO)
    }
    
    public static func loadAnonymousUUID() -> String? {
        return UserDefaults.standard.value(forKey: Configuration.USER_ID_ANONYMOUS) as? String
    }
    
    public static func saveAnonymousUUID(_ UUID: String?) {
        UserDefaults.standard.setValue(UUID, forKey: Configuration.USER_ID_ANONYMOUS)
    }
    
    public static func getNotificationHistory() -> [String]{
        if let user = SessionStoreManager.loadCurrentUser(), let id = user.id {
            let defaults = UserDefaults.standard
            let array = defaults.stringArray(forKey: "\(Configuration.USER_NOTI_HISTORY)\(id)") ?? []
            return array
        }
        return []
    }
    
    public static func saveNotificationHistory(_ histories: [String]) {
        if let user = SessionStoreManager.loadCurrentUser(), let id = user.id {
            let defaults = UserDefaults.standard
            defaults.set(histories, forKey: "\(Configuration.USER_NOTI_HISTORY)\(id)")
        }
    }
    
    public static func getNotShowAutoPINScreen() -> Bool {
        if let user = SessionStoreManager.loadCurrentUser(), let id = user.id {
            let defaults = UserDefaults.standard
            return defaults.bool(forKey: "\(Configuration.USER_NOT_SHOW_AUTO_PIN_SCREEN)\(id)")
        }
        return true
    }
    
    public static func saveNotShowAutoPINScreen(_ notShow: Bool) {
        if let user = SessionStoreManager.loadCurrentUser(), let id = user.id {
            let defaults = UserDefaults.standard
            defaults.set(notShow, forKey: "\(Configuration.USER_NOT_SHOW_AUTO_PIN_SCREEN)\(id)")
        }
    }
    
    public static var gasPrice : GasPriceDTO?
    
    public static var exchangeRateInfo : RateInfoDTO?
    
    public static var ethExchangeRateInfo : RateInfoDTO?
    
    public static var tokenInfo: TokenInfoDTO?
    
    public static var onchainInfo: OnchainInfoDTO?
    
    public static var countryList: [CountryCodeDTO] = []
    
    public static var inviteLink: InviteLinkDTO?
    
    public static var inviteLinkRetailer: InviteLinkDTO?
    
    public static var isAccessDenied = false
    
    public static func isWalletSafe() -> Bool {
        if let user = loadCurrentUser(), user.profile?.walletInfo?.offchainAddress != nil {
            return true
        }
        
        return false
    }
}
