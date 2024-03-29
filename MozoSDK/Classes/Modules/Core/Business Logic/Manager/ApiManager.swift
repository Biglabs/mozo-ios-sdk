//
//  ApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/5/18.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

public class ApiManager {
    private (set) var client: Session
    public var delegate: ApiManagerDelegate?
    
    public static let shared = ApiManager()
    
    private init() {
        // Create a shared URL cache
        let memoryCapacity = 4 * 1024 * 1024; // 4 MB
        let diskCapacity = 20 * 1024 * 1024; // 20 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "mozo_sdk_cache")
        
        // Check network to update cachePolicy
        //let hasInternetConnection = try! Reachability.reachabilityForInternetConnection().isReachable()
        let cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy//hasInternetConnection ? .UseProtocolCachePolicy : .ReturnCacheDataElseLoad
        
        // Create a custom configuration
        let configuration = URLSessionConfiguration.af.default
        configuration.requestCachePolicy = cachePolicy
        configuration.urlCache = cache
        // Create your own manager instance that uses your custom configuration
        client = Session(configuration: configuration)
    }
    
    private func getToken() -> String {
        return "bearer \(AccessTokenManager.getAccessToken() ?? "")"
    }
    
    private func userAgent() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return "iOS - \(MozoSDK.appType) \(version) - \(MozoSDK.network.value)"
    }
    
    private func buildHTTPHeaders(withToken: Bool) -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization": withToken ? getToken() : "",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Cache-Control": "private",
            "user-agent": userAgent()
        ]
        
        return headers
    }
    
    public func convertNetworkToPath(network: String) -> String{
        var path = network.lowercased()
        path = path.replacingOccurrences(of: "_", with: "/")
        return path
    }
    
    public func extractNetworkPathFromText(network: String) -> String{
        let path = network.lowercased()
        let paths = path.components(separatedBy: "_")
        return paths.last!
    }
    
    private func mappingConnectionError(_ response: HTTPURLResponse?, error: Error?) -> ConnectionError?{
        var connectionError: ConnectionError?
        
        if let error = error, (error as NSError).domain == NSURLErrorDomain
            && ((error as NSError).code == NSURLErrorNotConnectedToInternet) {
            connectionError = ConnectionError.noInternetConnection
        } else if let error = error, (error as NSError).domain == NSURLErrorDomain
            && (error as NSError).code == NSURLErrorTimedOut {
            connectionError = ConnectionError.requestTimedOut
        } else if response?.statusCode == 500 {
            connectionError = ConnectionError.internalServerError
        } else if response?.statusCode == 404 {
            connectionError = ConnectionError.requestNotFound
        } else if response?.statusCode == 401 {
            connectionError = ConnectionError.authenticationRequired
        } else if response?.statusCode == 400 {
            connectionError = ConnectionError.badRequest
        } else if let error = error {
            connectionError = ConnectionError.network(error: error)
        }
        return connectionError
    }
    
    func executeWithoutToken(_ method: Alamofire.HTTPMethod, url: String, parameters: Any? = nil) -> Promise<[String: Any]> {
        #if DEBUG
        print("--> \(method.rawValue) \(url)\n NO TOKEN")
        if let json = parameters as? Dictionary<String, Any> {
            print("params: \(String(describing: json))")
        }
        #endif
        let headers = self.buildHTTPHeaders(withToken: false)
        return self.execute(method, url: url, headers: headers, body: parameters!)
    }
    
    public func execute(_ method: Alamofire.HTTPMethod, url: String, parameters: Any? = nil) -> Promise<[String: Any]> {
        let headers = self.buildHTTPHeaders(withToken: true)
        #if DEBUG
        print("--> \(method.rawValue) \(url)\nToken: \(String(describing: headers["Authorization"] ?? ""))")
        if let json = parameters as? Dictionary<String, Any> {
            print("params: \(String(describing: json))")
        }
        #endif
        if parameters == nil {
            return self.execute(method, url: url, headers: headers, params: nil)
        } else if let params = parameters as? [String: Any] {
            return self.execute(method, url: url, headers: headers, params: params)
        } else if let param = parameters as? String {
            return self.execute(method, url: url, headers: headers, param: param)
        } else {
            return self.execute(method, url: url, headers: headers, body: parameters!)
        }
    }
    
//    func execute(_ method: Alamofire.HTTPMethod, url: String, parameters: Any? = nil) -> Promise<[Any?]> {
//        print("Execute url: " + url)
//        let headers = self.buildHTTPHeaders(withToken: true)
//        if parameters == nil {
//            return self.execute(method, url: url, headers: headers, params: nil)
//        } else {
//            let params = parameters as? [String: Any]
//            return self.execute(method, url: url, headers: headers, params: params)
//        }
//    }

    private func execute(_ method: Alamofire.HTTPMethod, url: String, headers: HTTPHeaders, body: Any) -> Promise<[String: Any]> {
        return Promise { seal in
            guard let URL = URL(string: url) else {return}
            var request = URLRequest(url: URL)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers.dictionary
            var httpBody : Data? = nil
            
            if ((body as? Data) != nil) {
                httpBody = body as? Data
            } else {
                httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            }
            request.httpBody = httpBody

            self.client.request(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        self.handleApiResponseJSON(json, url: url).done({ (jsonData) in
                            seal.fulfill(jsonData)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                    case .failure(let error):
                        "🔴 Request failed with error: \(error.localizedDescription), url: \(url), detail: \(self.getErrorDetailMessage(responseData: response.data))".log()
                        let connectionError = self.checkResponse(response: response, error: error)
                        if connectionError == .authenticationRequired, let viewController = DisplayUtils.getTopViewController(), !viewController.isKind(of: WaitingViewController.self) {
                            self.delegate?.didReceiveAuthorizationRequired()
                        }
                        seal.reject(connectionError)
                    }
            }
        }
    }

    private func execute(_ method: Alamofire.HTTPMethod, url: String, headers: HTTPHeaders, param: String) -> Promise<[String: Any]> {
        return Promise { seal in
            guard let URL = URL(string: url) else {return}
            var request = URLRequest(url: URL)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers.dictionary
            request.httpBody = param.data(using: String.Encoding.utf8)

            self.client.request(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        self.handleApiResponseJSON(json, url: url).done({ (jsonData) in
                            seal.fulfill(jsonData)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                    case .failure(let error):
                        "🔴 Request failed: \(error.localizedDescription), url: \(url), detail: \(self.getErrorDetailMessage(responseData: response.data))".log()
                        let connectionError = self.checkResponse(response: response, error: error)
                        if connectionError == .authenticationRequired, let viewController = DisplayUtils.getTopViewController(), !viewController.isKind(of: WaitingViewController.self) {
                            self.delegate?.didReceiveAuthorizationRequired()
                        }
                        seal.reject(connectionError)
                    }
            }
        }
    }
    
    func handleApiResponseJSON(_ json: [String: Any], url: String) -> Promise<[String: Any]> {
        return Promise { seal in
            let jsonObj = JSON(json)
            if let mozoResponse = ResponseDTO(json: jsonObj) {
                if mozoResponse.success {
                    seal.fulfill(mozoResponse.data)
                } else {
                    if let error = mozoResponse.error {
                        "🔴 Request failed: \(error), url: \(url)".log()
                        if let errorEnum = ErrorApiResponse(rawValue: error) {
                            switch errorEnum {
                            case .INVALID_USER_TOKEN, .UNAUTHORIZED_ACCESS:
                                delegate?.didReceiveInvalidToken()
                                break
                                
                            case .USER_DEACTIVATED, .SUB_ACCOUNT_DEACTIVATED:
                                delegate?.didReceiveDeactivated(error: errorEnum)
                                break
                                
                            case .UPDATE_VERSION_REQUIREMENT:
                                delegate?.didReceiveRequireUpdate(type: errorEnum)
                                break
                                
                            case .TEMPORARILY_SUSPENDED:
                                delegate?.didReceiveRequireUpdate(type: .TEMPORARILY_SUSPENDED)
                                seal.reject(errorEnum.connectionError)
                                break
                            case .STORE_FATAL_USER_NO_OFFCHAIN_ADDRESS:
                                ModuleDependencies.shared.authenticate()
                                break
                            default:
                                if errorEnum == .MAINTAINING {
                                    self.delegate?.didReceiveMaintenance()
                                }
                                seal.reject(errorEnum.connectionError)
                            }
                        } else {
                            seal.reject(ConnectionError.internalServerError)
                        }
                    }
                }
            }
        }
    }
    
    func getErrorDetailMessage(responseData: Data?) -> String {
        var errorMessage = "General error message"
        
        if let data = responseData {
            do {
                let responseJSON = try JSON(data: data)
                errorMessage = responseJSON.rawString() ?? ""
            } catch {
                print("ApiManager - getErrorDetailMessage catch error while parsing JSON: \(error)")
            }
        }
        
        return errorMessage
    }

    private func execute(_ method: Alamofire.HTTPMethod, url: String, headers: HTTPHeaders, params: Parameters?) -> Promise<[String: Any]>{
        return Promise { seal in
            self.client.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        self.handleApiResponseJSON(json, url: url).done({ (jsonData) in
                            seal.fulfill(jsonData)
                        }).catch({ (error) in
                            seal.reject(error)
                        })
                    case .failure(let error):
                        "🔴 Request failed: \(error.localizedDescription), url: \(url), detail: \(self.getErrorDetailMessage(responseData: response.data))".log()
                        let connectionError = self.checkResponse(response: response, error: error)
                        if connectionError == .authenticationRequired, let viewController = DisplayUtils.getTopViewController(), !viewController.isKind(of: WaitingViewController.self) {
                            self.delegate?.didReceiveAuthorizationRequired()
                        }
                        seal.reject(connectionError)
                }
            }
        }
    }
    
    func checkResponse(response: AFDataResponse<Data>, error: Error) -> ConnectionError {
        var connectionError = ConnectionError.unknowError
        if response.error != nil || (response.response?.statusCode)! < 200 || (response.response?.statusCode)! > 299  {
            connectionError = self.mappingConnectionError(response.response, error: error)!
        }
        return connectionError
    }
    
    private func requestToken(parameters: Parameters) -> Promise<AccessToken> {
        var headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "*/*",
            "user-agent": userAgent()
        ]
        do {
            let parameterData = try JSONSerialization.data(withJSONObject: parameters)
            headers.add(name: "Content-Length", value: "\(parameterData.count)")
        } catch {
        }
        
        return Promise { seal in
            let url = Configuration.AUTH_ISSSUER.appending(Configuration.END_POINT_TOKEN_PATH)
            self.client.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(AccessToken(json))
                    case .failure(let error):
                        seal.reject(error)
                }
            }
        }
    }
    
    func requestToken(
        authorizationCode: String,
        codeVerifier: String,
        clientId: String,
        redirectUri: String
    ) -> Promise<AccessToken> {
        let parameters: Parameters = [
            "grant_type" : "authorization_code",
            "code" : authorizationCode,
            "redirect_uri": redirectUri,
            "code_verifier": codeVerifier,
            "client_id": clientId
        ]
        return requestToken(parameters: parameters)
    }
    
    func refeshToken(refreshToken: String, clientId: String) -> Promise<AccessToken> {
        let parameters: Parameters = [
            "grant_type" : "refresh_token",
            "refresh_token" : refreshToken,
            "client_id": clientId
        ]
        return requestToken(parameters: parameters)
    }
    
    func reportToken(_ token: String) -> Promise<Any> {
        return Promise { seal in
            let url = Configuration.BASE_HOST + "/store/api/public/tokenHistory/addTokenHistory"
            let params = ["token" : token] as [String : Any]
            self.execute(.post, url: url, parameters: params)
                .done { json -> Void in
                    seal.fulfill(json)
                }
                .catch { error in
                    seal.reject(error)
                }
        }
    }
}
