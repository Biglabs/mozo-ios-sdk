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
    var appType: AppType = .Shopper
    
    public init() {
        let request = URLRequest(url: URL(string: Configuration.WEB_SOCKET_URL)!)
        socket = WebSocket(request: request)
    }
    
    func buildUUID() -> String {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let userObj = SessionStoreManager.loadCurrentUser()
        let userId = userObj?.id ?? ""
        let result = UUID(uuidString: "\(uuid)-\(userId)-\(appType.rawValue)")?.uuidString ?? UUID().uuidString
        return result
    }

    public func requestWithHeader() -> URLRequest{
        let uuid = buildUUID()
        var url = Configuration.WEB_SOCKET_URL + uuid + "/\(appType.rawValue)"
        let headers = ["X-Atmosphere-tracking-id" : "0",
                       "X-Atmosphere-Framework" : "2.3.3-javascript",
                       "X-Atmosphere-Transport" : "websocket",
                       "Content-Type" : "application/json",
                       "X-atmo-protocol" : "true"]
        url += "/?\(headers.queryString)"
        
        if let accessToken = AccessTokenManager.getAccessToken() {
            url += "Authorization=bearer+\(accessToken)"
        }
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        return request
    }
    
    func connect() {
        print("WebSocketManager - [connect].")
        // Build header with current access token
        let request = requestWithHeader()
        socket = WebSocket(request: request)
        print("WebSocketManager - [connect] with URL \(socket.currentURL)")
        socket.connect()
    }
    
    func disconnect() {
        if socket.isConnected {
            print("WebSocketManager - [disconnect].")
            socket.disconnect()
        }
    }
    
    func isConnected() -> Bool {
        return socket.isConnected
    }
}
