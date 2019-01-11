//
//  RDNInteractor.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/18.
//

import Foundation
import Starscream
import SwiftyJSON

class RDNInteractor: NSObject {
    var output: RDNInteractorOutput?
    let manager : WebSocketManager
    
    init(webSocketManager: WebSocketManager) {
        self.manager = webSocketManager
    }
}
extension RDNInteractor : RDNInteractorInput {
    func startService() {
        if !manager.isConnected() {
            NSLog("RDNInteractor - Start services.")
            manager.connect()
            manager.socket.advancedDelegate = self
        }
    }
    
    func stopService() {
        if manager.isConnected() {
            NSLog("RDNInteractor - Stop services.")
            manager.disconnect()
        }
    }
}
// MARK: Websocket Delegate Methods.
extension RDNInteractor : WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        NSLog("Websocket is connected")
    }
    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        if let e = error {
            NSLog("Websocket is disconnected: \(e.localizedDescription)")
        } else {
            NSLog("Websocket disconnected")
        }
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        print("Received notification text: \(text)")
        processMessage(message: text, response: response)
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        print("Received notification data: \(data.count)")
    }
    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        print("websocket Http Upgrade with request: \(request)")
    }
    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        print("websocket Http Upgrade with response: \(response)")
    }
}
// MARK: WS Message (Private)
extension RDNInteractor {
    private func processMessage(message: String, response: WebSocket.WSResponse) {
        // split string by | character
        let strings = message.components(separatedBy: "|");
        
        if strings.count == 2 {
            // Check connected response
            if strings[0] == "71" {
                return
            }
            // Check Ping
            if strings[0] == "1" {
                print("Received ping!")
                return
            }
            let jsonMessage = strings[1]
            processJsonWS(jsonMessage)
        }
    }
    
    private func processJsonWS(_ jsonMessage: String) {
        let json = SwiftyJSON.JSON(parseJSON: jsonMessage)
        if let wsMessage = WSMessage(json: json) {
            processWSMessage(message: wsMessage, rawJsonMessage: jsonMessage)
        }
    }
    
    private func processWSMessage(message: WSMessage, rawJsonMessage: String) {
        if let messageContent = message.content {
            let jobj = SwiftyJSON.JSON(parseJSON: messageContent)
            if let rdNoti = RdNotification(json: jobj) {
                saveNotification(content: rawJsonMessage)
                if rdNoti.event == NotificationEventType.BalanceChanged.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj) {
                    output?.balanceDidChange(balanceNoti: balanceNoti)
                } else if rdNoti.event == NotificationEventType.AddressBookChanged.rawValue,
                        let abNoti = AddressBookNotification(json: jobj),
                        let list = abNoti.data {
                    output?.addressBookDidChange(addressBookList: list)
                } else if rdNoti.event == NotificationEventType.Airdropped.rawValue,
                    let airdropNoti = AirdropNotification(json: jobj) {
                    output?.didAirdropped(airdropNoti: airdropNoti)
                } else if rdNoti.event == NotificationEventType.CustomerCame.rawValue,
                    let ccNoti = CustomerComeNotification(json: jobj) {
                    output?.didCustomerCame(ccNoti: ccNoti)
                } else {
                    NSLog("Can not handle message: \(messageContent)")
                }
            }
        }
    }
    
    private func saveNotification(content: String) {
        print("Save notification to local user defaults with content: \(content)")
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
