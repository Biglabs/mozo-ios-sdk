//
//  WebSocketManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/18.
//

import Foundation
import Starscream

public protocol SocketDelegate {
    func onSocketConnected()
    func onSocketDisconnected(_ error: String?)
    func onSocketReceivedText(_ text: String)
}
public class WebSocketManager: WebSocketDelegate {
    private var socket: WebSocket? = nil
    var appType: AppType = .Shopper
    var isConnected: Bool = false
    var delegate: SocketDelegate? = nil
    
    private func buildUUID() -> String {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let userObj = SessionStoreManager.loadCurrentUser()
        let userId = userObj?.id ?? ""
        let result = UUID(uuidString: "\(uuid)-\(userId)-\(appType.rawValue)")?.uuidString ?? UUID().uuidString
        return result
    }
    
    func connect() {
        if socket != nil {
            return
        }
        
        let uuid = buildUUID()
        let url = Configuration.WEB_SOCKET_URL + uuid + "/\(appType.rawValue)"
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "X-atmo-protocol" : "true",
            "X-Atmosphere-Framework" : "2.3.3-javascript",
            "X-Atmosphere-tracking-id" : "0",
            "X-Atmosphere-Transport" : "websocket"
        ]
        if let accessToken = AccessTokenManager.getAccessToken() {
            request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        }
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        "WebSocketManager - [connect] with URL \(String(describing: socket?.request.url))".log()
    }
    
    func disconnect() {
        if self.isConnected {
            "WebSocketManager - [disconnect].".log()
            socket?.disconnect()
            socket = nil
        }
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                isConnected = true
                delegate?.onSocketConnected()
                "WebSocketManager is connected: \(headers)".log()
            
            case .disconnected(let reason, let code):
                isConnected = false
                delegate?.onSocketDisconnected(reason)
                socket = nil
                "WebSocketManager is disconnected: \(reason) with code: \(code)".log()
            
            case .text(let string):
                delegate?.onSocketReceivedText(string)
                "WebSocketManager - Received text: \(string)".log()
            
            case .binary(let data):
                "WebSocketManager - Received data: \(data.count)".log()
            
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                isConnected = false
                delegate?.onSocketDisconnected("cancelled")
                socket = nil
            
            case .error(let error):
                isConnected = false
                delegate?.onSocketDisconnected(error?.localizedDescription)
                socket = nil
                "WebSocketManager - [error] with URL \(String(describing: error))".log()
        }
    }
}
