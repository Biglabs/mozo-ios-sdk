//
//  WebSocketManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 10/15/18.
//

import Foundation
import Starscream

public class WebSocketManager {
    var socket: WebSocket
    
    public init() {
        let request = URLRequest(url: URL(string: Configuration.WEB_SOCKET_URL)!)
        socket = WebSocket(request: request)
    }

    public func requestWithHeader() -> URLRequest{
        var url = Configuration.WEB_SOCKET_URL + "?X-Atmosphere-tracking-id=0&X-Atmosphere-Framework=2.3.3-javascript&X-Atmosphere-Transport=websocket&Content-Type=application/json&X-atmo-protocol=true&Token="
        if let accessToken = AccessTokenManager.getAccessToken() {
            url += accessToken
        }
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
//        request.setValue("0", forHTTPHeaderField: "X-Atmosphere-tracking-id")
//        request.setValue("2.3.3-javascript", forHTTPHeaderField: "X-Atmosphere-Framework")
//        request.setValue("websocket", forHTTPHeaderField: "X-Atmosphere-Transport")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("true", forHTTPHeaderField: "X-atmo-protocol")
//        if let accessToken = AccessTokenManager.getAccessToken() {
//            request.setValue(accessToken, forHTTPHeaderField: "Token")
//        }
        return request
    }
    
    func connect() {
        NSLog("WebSocketManager - [connect].")
        // Build header with current access token
        let request = requestWithHeader()
        socket = WebSocket(request: request)
        NSLog("WebSocketManager - [connect] with URL \(socket.currentURL)")
        socket.connect()
    }
    
    func disconnect() {
        if socket.isConnected {
            NSLog("WebSocketManager - [disconnect].")
            socket.disconnect()
        }
    }
    
    func isConnected() -> Bool {
        return socket.isConnected
    }
}
