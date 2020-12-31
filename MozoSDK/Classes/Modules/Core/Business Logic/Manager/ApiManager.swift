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
    private (set) var client: SessionManager
    var delegate: ApiManagerDelegate?
    var apiKey: String?
    var appType: AppType = .Shopper
    
    public init() {
        // Create a shared URL cache
        let memoryCapacity = 4 * 1024 * 1024; // 4 MB
        let diskCapacity = 20 * 1024 * 1024; // 20 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "mozo_sdk_cache")
        
        // Check network to update cachePolicy
        //let hasInternetConnection = try! Reachability.reachabilityForInternetConnection().isReachable()
        let cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy//hasInternetConnection ? .UseProtocolCachePolicy : .ReturnCacheDataElseLoad
        
        // Create a custom configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = cachePolicy
        configuration.urlCache = cache
        // Create your own manager instance that uses your custom configuration
        client = Alamofire.SessionManager(configuration: configuration)
    }
    
    private func getToken() -> String {
        return "bearer \(AccessTokenManager.getAccessToken() ?? "")"
    }
    
    private func buildHTTPHeaders(withToken: Bool) -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "API-Key": apiKey ?? "",
            "Authorization": withToken ? getToken() : "",
            "Content-Type": MediaType.APPLICATION_JSON.rawValue,
            "Accept": MediaType.APPLICATION_JSON.rawValue,
            "Cache-Control": "private",
            "user-agent": "IOS"
        ]
        
        return headers
    }
    
    private func buildHeaderOauth() -> HTTPHeaders {
        let credentialData = "{OAUTH_CLIENT_ID}:{OAUTH_SECRET}".data(using:String.Encoding.utf8)
        let base64Credentials = credentialData?.base64EncodedString(options: []) ?? ""
        let authorization = "Basic \(base64Credentials)"
        let headers: HTTPHeaders = [
            "Authorization": authorization,
            "Content-Type": MediaType.APPLICATION_FORM_URLENCODED.rawValue,
            "Accept": MediaType.APPLICATION_JSON.rawValue,
            "user-agent": "IOS"
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
            request.allHTTPHeaderFields = headers
            var httpBody : Data? = nil
            
            if ((body as? Data) != nil) {
                httpBody = body as? Data
            } else {
                httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            }
            request.httpBody = httpBody

            self.client.request(request)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
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
                        } else {
                            seal.reject(connectionError)
                        }
                    }
            }
        }
    }

    private func execute(_ method: Alamofire.HTTPMethod, url: String, headers: HTTPHeaders, param: String) -> Promise<[String: Any]> {
        return Promise { seal in
            guard let URL = URL(string: url) else {return}
            var request = URLRequest(url: URL)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = param.data(using: String.Encoding.utf8)

            self.client.request(request)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
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
                        } else {
                            seal.reject(connectionError)
                        }
                    }
            }
        }
    }
    
    func handleApiResponseJSON(_ json: [String: Any], url: String) -> Promise<[String: Any]> {
        return Promise { seal in
            if url.contains(AUTH_CHECK_TOKEN_API_PATH) {
                return seal.fulfill(json)
            }
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

    private func execute(_ method: Alamofire.HTTPMethod, url: String, headers: HTTPHeaders, params: [String: Any]?) -> Promise<[String: Any]>{
        return Promise { seal in
            self.client.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
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
                        } else {
                            seal.reject(connectionError)
                        }
                }
            }
        }
    }
    
    func checkResponse(response: DataResponse<Any>, error: Error) -> ConnectionError {
        var connectionError = ConnectionError.unknowError
        if response.result.error != nil || (response.response?.statusCode)! < 200 || (response.response?.statusCode)! > 299  {
            connectionError = self.mappingConnectionError(response.response, error: error)!
        }
        return connectionError
    }
}
