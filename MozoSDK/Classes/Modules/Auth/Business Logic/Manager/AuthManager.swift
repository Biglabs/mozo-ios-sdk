//
//  AuthManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import PromiseKit

internal class AuthManager : NSObject {
    // MARK: 2 days
    private let TOKEN_REFRESH_OFFSET: Double = 2 * 24 * 3600
    
    var delegate : AuthManagerDelegate?
    
    func checkAuthorization() {
        if SessionStoreManager.isWalletSafe() == false {
            return
        }
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKING
        self.checkToken({ (success) in
            if success {
                self.delegate?.didCheckAuthorizationSuccess()
            } else {
                self.clearAll()
                self.delegate?.didRemoveTokenAndLogout()
            }
        })
    }
    
    private func checkToken(_ completion: @escaping (_ success: Bool) -> Void) {
        guard let tokenInfo = AccessTokenManager.load(), let refreshToken = tokenInfo.refreshToken else {
            completion(false)
            return
        }
        let expireTime = min(tokenInfo.expireTime?.timeIntervalSinceNow ?? 0, tokenInfo.refreshExpireTime?.timeIntervalSinceNow ?? 0)
        if(expireTime < TOKEN_REFRESH_OFFSET) {
            "AuthManager do refresh /token".log()
            _ = ApiManager.shared.refeshToken(
                refreshToken: refreshToken,
                clientId: MozoSDK.appType.clientId
            ).done { res -> Void in
                AccessTokenManager.save(res)
                completion(true)
                self.reportToken(res)
                
            }.catch { e in
                completion(false)
            }
        } else {
            completion(true)
            self.reportToken()
        }
    }
    
    private func reportToken(_ newData: AccessToken? = nil) {
        if let token = newData?.accessToken ?? AccessTokenManager.getAccessToken(), !token.isEmpty {
            _ = ApiManager.shared.reportToken(token)
        }
    }
    
    func clearAll() {
        AccessTokenManager.clearToken()
        AccessTokenManager.clearPinSecret()
        SessionStoreManager.clearCurrentUser()
        SafetyDataManager.shared.offchainDetailDisplayData = nil
        SafetyDataManager.shared.onchainFromOffchainDetailDisplayData = nil
        SafetyDataManager.shared.ethDetailDisplayData = nil
        SafetyDataManager.shared.onchainDetailDisplayData = nil
    }
}
