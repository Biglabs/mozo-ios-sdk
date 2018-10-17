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
        let uuid = NSUUID().uuidString
        var url = Configuration.WEB_SOCKET_URL + uuid
        var headers = ["X-Atmosphere-tracking-id" : "0",
                       "X-Atmosphere-Framework" : "2.3.3-javascript",
                       "X-Atmosphere-Transport" : "websocket",
                       "Content-Type" : "application/json",
                       "X-atmo-protocol" : "true"]
//        url += "/?\(headers.queryString)"
        
        if let accessToken = AccessTokenManager.getAccessToken() {
//            url += "Authentication=bearer+\(accessToken)"
            headers["Authentication"] = "bearer+\(accessToken)"
        }
        var request = URLRequest(url: URL(string: url)!)
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = 5
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
