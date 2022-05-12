//
//  AccessTokenManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/18.
//

import Foundation
import JWTDecode
public class AccessTokenManager {
    public static func save(_ token: AccessToken?) {
        DispatchQueue.main.async {
            if token == nil {
                UserDefaults.standard.removeObject(forKey: Configuration.AUTH_STATE)
            } else {
                UserDefaults.standard.set(token!.rawData, forKey: Configuration.AUTH_STATE)
            }
            self.saveToken(token?.accessToken)
        }
    }
    
    public static func load() -> AccessToken? {
        if let data = UserDefaults.standard.data(forKey: Configuration.AUTH_STATE) {
            return AccessToken.parse(data)
        }
        return nil
    }
    
    public static func loadToken() -> String? {
        if let token = UserDefaults.standard.string(forKey: Configuration.ACCESS_TOKEN) {
            return token
        }
        return UserDefaults.standard.string(forKey: Configuration.ACCESS_TOKEN_ANONYMOUS)
    }
    
    public static func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: Configuration.ACCESS_TOKEN)
    }
    
    private static func saveToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: Configuration.ACCESS_TOKEN)
        
        if let accessToken = token {
            let jwt = try! decode(jwt: accessToken)
            let pin_secret = jwt.claim(name: "pin_secret").string
            self.savePinSecret(pin_secret)
        }
    }
    
    public static func clearToken() {
        UserDefaults.standard.removeObject(forKey: Configuration.AUTH_STATE)
        UserDefaults.standard.removeObject(forKey: Configuration.ACCESS_TOKEN)
    }
    
    public static func getPinSecret() -> String? {
        return UserDefaults.standard.string(forKey: Configuration.PIN_SECRET)
    }
    
    private static func savePinSecret(_ pinSecrect: String?) {
        UserDefaults.standard.set(pinSecrect, forKey: Configuration.PIN_SECRET)
    }
    
    public static func clearPinSecret() {
        UserDefaults.standard.removeObject(forKey: Configuration.PIN_SECRET)
    }
    
    public static func saveAnonymousToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: Configuration.ACCESS_TOKEN_ANONYMOUS)
    }
}
