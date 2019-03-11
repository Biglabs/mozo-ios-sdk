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
    public func getEthAndOnchainExchangeRateInfo() -> Promise<EthRateInfoDTO> {
        return Promise { seal in
            let locale = Locale.current.languageCode ?? "en"
            let url = Configuration.BASE_URL + "/exchange/rateETHAndToken?locale=\(locale)"
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
}
