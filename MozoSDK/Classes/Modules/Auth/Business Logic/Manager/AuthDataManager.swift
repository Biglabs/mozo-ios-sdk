//
//  AuthDataManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/11/18.
//

import Foundation
import AppAuth

class AuthDataManager {
    public static func loadAuthState() -> OIDAuthState? {
        // Get User from UserDefaults
        if let data = UserDefaults.standard.data(forKey: Configuration.AUTH_STATE),
           let state = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
            return state
        }
        return nil
    }
    
    public static func saveAuthState(_ state: OIDAuthState?) {
        var data: Data? = nil
        if let authState = state {
            data = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        }
        UserDefaults.standard.set(data, forKey: Configuration.AUTH_STATE)
    }
    
    public static func saveIdToken(_ idToken: String?) {
        if let id = idToken {
            UserDefaults.standard.set(id, forKey: Configuration.AUTH_ID_TOKEN)
        }
    }
    
    public static func loadIdToken() -> String? {
        if let idToken = UserDefaults.standard.string(forKey: Configuration.AUTH_ID_TOKEN) {
            return idToken
        }
        return nil
    }
    
    public static func clear() {
        UserDefaults.standard.removeObject(forKey: Configuration.AUTH_STATE)
        UserDefaults.standard.removeObject(forKey: Configuration.AUTH_ID_TOKEN)
    }
}
