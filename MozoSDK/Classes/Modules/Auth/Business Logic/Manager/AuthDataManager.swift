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
            let state = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            return state
        }
        print("Not found Authn State")
        return nil
    }
    
    public static func saveAuthState(_ state: OIDAuthState?) {
        var data: Data? = nil
        if let authState = state {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        UserDefaults.standard.set(data, forKey: Configuration.AUTH_STATE)
    }
    
    public static func saveIdToken(_ idToken: String?) {
        if let id = idToken {
            let data = NSKeyedArchiver.archivedData(withRootObject: id)
            UserDefaults.standard.set(data, forKey: Configuration.AUTH_ID_TOKEN)
        }
    }
    
    public static func loadIdToken() -> String? {
        if let data = UserDefaults.standard.data(forKey: Configuration.AUTH_ID_TOKEN),
            let state = NSKeyedUnarchiver.unarchiveObject(with: data) as? String {
            return state
        }
        return nil
    }
    
    public static func clear() {
        UserDefaults.standard.removeObject(forKey: Configuration.AUTH_STATE)
        UserDefaults.standard.removeObject(forKey: Configuration.AUTH_ID_TOKEN)
    }
}
