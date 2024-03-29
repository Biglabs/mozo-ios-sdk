//
//  RDNInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/18.
//

import Foundation
import SwiftyJSON
let SOCKET_RETRY_DELAY_IN_SECONDS = 5
let SOCKET_RETRY_MAXIMUM_TIME = 8
class RDNInteractor: NSObject {
    var output: RDNInteractorOutput?
    let manager : WebSocketManager
    var shouldReconnectAfterDisconnected = true
    var retryCount = 0
    var reconnectTimer: Timer?
    
    init(webSocketManager: WebSocketManager) {
        self.manager = webSocketManager
    }
    
    @objc func connectToWebSocketServer() {
        manager.connect()
        manager.delegate = self
    }
    
    func stopReconnectToWebSocket() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        retryCount = 1
    }
    
    private func processJsonWS(_ jsonMessage: String) {
        let json = SwiftyJSON.JSON(parseJSON: jsonMessage)
        if let wsMessage = WSMessage(json: json) {
            processWSMessage(message: wsMessage, rawJsonMessage: jsonMessage)
        }
    }
    
    private func processWSMessage(message: WSMessage, rawJsonMessage: String) {
        if !SessionStoreManager.isAccessDenied, let messageContent = message.content {
            let jobj = SwiftyJSON.JSON(parseJSON: messageContent)
            if let rdNoti = RdNotification(json: jobj) {
                var needSave = false
                if rdNoti.event == NotificationEventType.BalanceChanged.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj) {
                    needSave = true
                    output?.balanceDidChange(balanceNoti: balanceNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.ConvertOnchainToOffchain.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj) {
                    output?.didConvertOnchainToOffchainSuccess(balanceNoti: balanceNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.AddressBookChanged.rawValue,
                        let abNoti = AddressBookNotification(json: jobj),
                        let list = abNoti.data {
                    output?.addressBookDidChange(addressBookList: list, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.StoreBookAdded.rawValue,
                    let sbNoti = StoreBookNotification(json: jobj),
                    let data = sbNoti.data {
                    output?.storeBookDidChange(storeBook: data, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.Airdropped.rawValue,
                    let airdropNoti = AirdropNotification(json: jobj) {
                    needSave = true
                    output?.didAirdropped(airdropNoti: airdropNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.CustomerCame.rawValue,
                    let ccNoti = CustomerComeNotification(json: jobj) {
                    needSave = true
                    output?.didCustomerCame(ccNoti: ccNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.AirdropInvite.rawValue,
                    let inviteNoti = InviteNotification(json: jobj) {
                    output?.didInvitedSuccess(inviteNoti: inviteNoti, rawMessage: rawJsonMessage)
                    
                } else if rdNoti.event == NotificationEventType.InvalidToken.rawValue {
                    //stopService(shouldReconnect: true)
                    
                } else if rdNoti.event == NotificationEventType.ProfileChanged.rawValue {
                    output?.profileDidChange()
                } else if rdNoti.event == NotificationEventType.AirdropFounder.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj)  {
                    output?.didReceivedAirdrop(eventType: NotificationEventType(rawValue: rdNoti.event!)!, balanceNoti: balanceNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.AirdropSignup.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj)  {
                    output?.didReceivedAirdrop(eventType: NotificationEventType(rawValue: rdNoti.event!)!, balanceNoti: balanceNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.AirdropTopRetailer.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj)  {
                    output?.didReceivedAirdrop(eventType: NotificationEventType(rawValue: rdNoti.event!)!, balanceNoti: balanceNoti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.PromotionUsed.rawValue,
                    let noti = PromotionUsedNotification(json: jobj)  {
                    output?.didReceivedPromotionUsed(eventType: NotificationEventType(rawValue: rdNoti.event!)!, usedNoti: noti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.PromotionPurchased.rawValue,
                    let noti = PromotionPurchasedNotification(json: jobj)  {
                    output?.didReceivedPromotionPurchased(eventType: NotificationEventType(rawValue: rdNoti.event!)!, purchasedNoti: noti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.CovidZone.rawValue,
                    let noti = CovidWarningNotification(json: jobj)  {
                    output?.didReceivedCovidWarning(eventType: NotificationEventType(rawValue: rdNoti.event!)!, warningNoti: noti, rawMessage: rawJsonMessage)
                } else if rdNoti.event == NotificationEventType.LuckyDraw.rawValue,
                    let noti = LuckyDrawNotification(json: jobj) {
                    output?.didReceivedLuckyDraw(noti: noti, rawMessage: rawJsonMessage)
                }
                if self.manager.appType == .Retailer && needSave {
//                    saveNotification(content: rawJsonMessage)
                }
            }
        }
    }
    
    private func saveNotification(content: String) {
        // Get current list notification
        var histories = SessionStoreManager.getNotificationHistory()
        // Add current content to list
        histories.append(content)
        // Check length of list
        if histories.count > 15 {
            histories.remove(at: 0)
        }
        // Save to user default
        SessionStoreManager.saveNotificationHistory(histories)
    }
}
extension RDNInteractor : RDNInteractorInput {
    func startService() {
        stopReconnectToWebSocket()
        if !manager.isConnected {
            "RDNInteractor - Start services.".log()
            connectToWebSocketServer()
        }
    }
    
    func stopService(shouldReconnect: Bool) {
        stopReconnectToWebSocket()
        shouldReconnectAfterDisconnected = shouldReconnect
        if manager.isConnected {
            "RDNInteractor - Stop services.".log()
            manager.disconnect()
        }
    }
}
// MARK: Websocket Delegate Methods.
extension RDNInteractor : SocketDelegate {
    func onSocketConnected() {
        stopReconnectToWebSocket()
        shouldReconnectAfterDisconnected = true
    }
    
    func onSocketDisconnected(_ error: String?) {
        "Websocket is disconnected: \(error ?? "")".log()
        
        if shouldReconnectAfterDisconnected {
            let mutiplier = pow(2.0, Double(retryCount))
            let timeInterval = Double(SOCKET_RETRY_DELAY_IN_SECONDS) * mutiplier
            "RDNInteractor - Reconnect after disconnect - delay time in seconds: \(timeInterval)".log()
            reconnectTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(connectToWebSocketServer), userInfo: nil, repeats: false)
            retryCount += 1
            if retryCount > SOCKET_RETRY_MAXIMUM_TIME {
                retryCount = 0
            }
        }
    }
    
    func onSocketReceivedText(_ text: String) {
        let strings = text.components(separatedBy: "|");
        
        if strings.count == 2 {
            // Check connected response
            if strings[0] == "71" {
                return
            }
            // Check Ping
            if strings[0] == "1" {
                "Received ping!".log()
                return
            }
            let jsonMessage = strings[1]
            processJsonWS(jsonMessage)
        }
    }
}
