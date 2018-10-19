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
    let manager = WebSocketManager()
}
extension RDNInteractor : RDNInteractorInput {
    func startService() {
        NSLog("RDNInteractor - Start services.")
        manager.connect()
        manager.socket.advancedDelegate = self
    }
    
    func stopService() {
        NSLog("RDNInteractor - Stop services.")
        manager.disconnect()
    }
}
// MARK: Websocket Delegate Methods.
extension RDNInteractor : WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        print("Received text: \(text)")
        processMessage(message: text, response: response)
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        print("Received data: \(data.count)")
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
        
        if strings.count == 3 {
            let jsonMessage = strings[1]
            let json = SwiftyJSON.JSON(parseJSON: jsonMessage)
            if let wsMessage = WSMessage(json: json) {
                processWSMessage(message: wsMessage)
            }
        } else if strings.count == 2 {
            // Check Ping
            if strings[0] == "1" {
                print("Received ping!")
            }
        }
    }
    
    private func processWSMessage(message: WSMessage) {
        if message.message != nil {
            let jobj = SwiftyJSON.JSON(parseJSON: message.message!)
            if let rdNoti = RdNotification(json: jobj) {
                if rdNoti.event == NotificationEventType.BalanceChanged.rawValue,
                    let balanceNoti = BalanceNotification(json: jobj) {
                    output?.balanceDidChange(balanceNoti: balanceNoti)
                } else if rdNoti.event == NotificationEventType.AddressBookChanged.rawValue,
                    let abNoti = AddressBookNotification(json: jobj),
                    let list = abNoti.data {
                    output?.addressBookDidChange(addressBookList: list)
                }
            }
        }
    }
}
