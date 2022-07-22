//
//  AuthManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/10/18.
//

import Foundation
import PromiseKit

class AuthManager : NSObject {
    private let TOKEN_REFRESH_OFFSET_PROD: Double = 2 * 24 * 3600
    private let TOKEN_REFRESH_OFFSET_STAG: Double = 1 * 60
    private let TOKEN_REFRESH_OFFSET_DEV: Double = 5 * 60
    
    var delegate : AuthManagerDelegate?
    private var refreshTokenTimer: Timer?
    
    override init() {
        super.init()
        self.reportToken()
        self.checkAuthorization()
    }
    
    func setupRefreshTokenTimer() {
        guard let token = AccessTokenManager.load(), let expireTime = token.expireTime else { return }
        
        if let refreshTokenTimer = refreshTokenTimer, refreshTokenTimer.isValid {
            "AuthManager - Refresh token timer is existing.".log()
            return
        }
        
        let fireAt = expireTime.addingTimeInterval(-expireOffset())
        if fireAt > Date() {
            refreshTokenTimer = Timer(
                fireAt: fireAt,
                interval: 0,
                target: self,
                selector: #selector(fireRefreshToken),
                userInfo: nil,
                repeats: false
            )
            RunLoop.main.add(refreshTokenTimer!, forMode: RunLoop.Mode.common)
        } else {
            fireRefreshToken()
        }
    }
    
    @objc func fireRefreshToken() {
        "AuthManager Fire refresh token.".log()
        revokeRefreshTokenTimer()
        checkRefreshToken { (success) in
            if success {
                self.setupRefreshTokenTimer()
            } else {
                self.revokeRefreshTokenTimer()
                self.delegate?.didRemoveTokenAndLogout()
            }
        }
    }
    
    private func checkRefreshToken(_ completion: @escaping (_ success: Bool) -> Void) {
        guard let token = AccessTokenManager.load(),
              let expireTime = token.expireTime,
              let refreshToken = token.refreshToken else {
            completion(false)
            return
        }
        if(expireTime.timeIntervalSinceNow < expireOffset()) {
            _ = ApiManager.shared.refeshToken(
                refreshToken: refreshToken,
                clientId: MozoSDK.appType.clientId
            ).done { res -> Void in
                AccessTokenManager.save(res)
                self.reportToken(res)
                completion(true)
                
            }.catch { e in
                completion(false)
            }
        } else {
            completion(true)
        }
    }
    
    private func checkAuthorization() {
        if SessionStoreManager.isWalletSafe() == false {
            return
        }
        SafetyDataManager.shared.checkTokenExpiredStatus = .CHECKING
        ApiManager.shared.checkTokenExpired().done({ (result) in
            self.delegate?.didCheckAuthorizationSuccess()
            // TODO: Reload user info in case error with user info at the latest login
            // Remember: Authen flow and wallet flow might be affected by reloading here
            self.checkRefreshToken {_ in }
        }).catch({ (err) in
            let error = err as! ConnectionError
            if error == ConnectionError.authenticationRequired {
                self.clearAll()
                self.delegate?.didRemoveTokenAndLogout()
            } else {
                self.checkRefreshToken({ (success) in
                    if success {
                        self.delegate?.didCheckAuthorizationSuccess()
                    } else {
                        self.clearAll()
                        self.delegate?.didRemoveTokenAndLogout()
                    }
                })
            }
        })
    }
    
    private func reportToken(_ newData: AccessToken? = nil) {
        if let token = newData?.accessToken ?? AccessTokenManager.getAccessToken(), !token.isEmpty {
            _ = ApiManager.shared.reportToken(token)
        }
    }
    
    private func revokeRefreshTokenTimer() {
        refreshTokenTimer?.invalidate()
        refreshTokenTimer = nil
    }
    
    func clearAll() {
        AccessTokenManager.clearToken()
        AccessTokenManager.clearPinSecret()
        SessionStoreManager.clearCurrentUser()
        SafetyDataManager.shared.offchainDetailDisplayData = nil
        SafetyDataManager.shared.onchainFromOffchainDetailDisplayData = nil
        SafetyDataManager.shared.ethDetailDisplayData = nil
        SafetyDataManager.shared.onchainDetailDisplayData = nil
        self.revokeRefreshTokenTimer()
    }
    
    private func expireOffset() -> Double {
        switch MozoSDK.network {
        case .MainNet:
            return TOKEN_REFRESH_OFFSET_PROD
        case .TestNet:
            return TOKEN_REFRESH_OFFSET_STAG
        default:
            return TOKEN_REFRESH_OFFSET_DEV
        }
    }
}
