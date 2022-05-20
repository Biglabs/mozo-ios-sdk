//
//  OnchainApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 3/9/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
let ONCHAIN_PATH = "/onchain"
extension ApiManager {
    public func getEthAndOnchainTokenInfoFromAddress(_ address: String) -> Promise<OnchainInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/getBalanceETHAndToken/\(address)"
            self.execute(.get , url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get ETH and onchain balance, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let onchainInfo = OnchainInfoDTO.init(json: jobj) {
                        seal.fulfill(onchainInfo)
                        self.delegate?.didLoadETHOnchainTokenSuccess(onchainInfo)
                    } else {
                        
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get ETH and onchain balance: " + error.localizedDescription)
                    seal.reject(err)
                    self.delegate?.didLoadETHOnchainTokenFailed()
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    /// Call API to get exchange rate info.
    ///
    public func getEthAndOnchainExchangeRateInfo(locale: String) -> Promise<EthRateInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_SOLO + "/exchange/rateETHAndToken?locale=\(locale)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get exchange rate info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let data = EthRateInfoDTO(json: jobj) {
                        seal.fulfill(data)
                    }
                }
                .catch { error in
                    print("Error when request get exchange rate info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getOffchainTokenInfo(_ address: String) -> Promise<OffchainInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/getBalanceTokenOnchainOffchain/\(address)"
            self.execute(.get , url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get offchain info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let offchainInfo = OffchainInfoDTO.init(json: jobj) {
                        seal.fulfill(offchainInfo)
                        self.delegate?.didLoadOffchainInfoSuccess(offchainInfo)
                    } else {
                        
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get offchain info: " + error.localizedDescription)
                    seal.reject(err)
                    self.delegate?.didLoadOffchainInfoFailed()
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getETHAndTransferFee(_ address: String) -> Promise<EthAndTransferFeeDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + ONCHAIN_PATH + "/getBalanceETHAndFeeTransferERC20/\(address)"
            self.execute(.get , url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get ETH and transfer fee from address \(address), json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let info = EthAndTransferFeeDTO.init(json: jobj) {
                        seal.fulfill(info)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request get ETH and transfer fee from address \(address): " + error.localizedDescription)
                    seal.reject(err)
                    self.delegate?.didLoadETHFailed()
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
