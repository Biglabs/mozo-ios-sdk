//
//  RedeemApiManager.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 7/11/19.
//

import Foundation
import PromiseKit
import SwiftyJSON
extension ApiManager {
    public func getPromotionRedeemInfo(promotionId: Int64, branchId: Int64) -> Promise<PromotionRedeemInfoDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL
                + SHOPPER_PROMOTION_RESOURCE_API_PATH
                + "/getInfoPromoRedeem/v2?promoId=\(promotionId)&branchId=\(branchId)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion redeem info, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let info = PromotionRedeemInfoDTO(json: jobj) {
                        seal.fulfill(info)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion redeem info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getBranchesInChain(promotionId: Int64, lat: Double, lng: Double) -> Promise<[BranchInfoDTO]> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + "/shopper/branch/getLinkPromo/\(promotionId)?lat=\(lat)&lon=\(lng)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    let jobj = SwiftyJSON.JSON(json)[RESPONSE_TYPE_ARRAY_KEY]
                    let branches = BranchInfoDTO.branchArrayFromJson(jobj)
                    seal.fulfill(branches)
                }
                .catch { error in
                    print("Error when request get promotion redeem info: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func preparePromotionRedeemTransaction(_ promotionId: Int64) -> Promise<PromotionRedeemDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/preparePromoRedeem?promoId=\(promotionId)"
            self.execute(.post, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to prepare promotion transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let redeemDto = PromotionRedeemDTO(json: jobj) {
                        seal.fulfill(redeemDto)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request prepare promotion redeem transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func sendSignedPromotionRedeemTransaction(_ promotionRedeemDTO: PromotionRedeemDTO) -> Promise<IntermediaryTransactionDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/signPromoRedeem"
            let param = promotionRedeemDTO.toJSON()
            self.execute(.post, url: url, parameters: param)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to send signed promotion redeem transaction, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    let tx = IntermediaryTransactionDTO(json: jobj)
                    seal.fulfill(tx!)
                }
                .catch { error in
                    //Handle error or give feedback to the user
                    let err = error as! ConnectionError
                    print("Error when request send signed promotion redeem transaction: " + error.localizedDescription)
                    seal.reject(err)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    /// Call API to get promotion transaction status from a transaction hash.
    ///
    /// - Parameters:
    ///   - hash: the transaction hash
    public func getPromoTxHash(hash: String) -> Promise<SwiftyJSON.JSON> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getPromoTxHash/v1?txHash=\(hash)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion tx status, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    seal.fulfill(jobj)
                }
                .catch { error in
                    print("Error when request get promotion tx status: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getPromotionPaidDetail(promotionId: Int64) -> Promise<PromotionPaidDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getPromoPaidDetail/v1?promoId=\(promotionId)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion paid, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = PromotionPaidDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion paid: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getPromotionPaidDetailByCode(_ promotionCode: String) -> Promise<PromotionPaidDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getPromoPaidDetailByCode/v1?promoCode=\(promotionCode)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion paid, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = PromotionPaidDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion paid: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    public func getPromotionPaidHistoryDetail(_ id: Int64) -> Promise<PromotionPaidDTO> {
        return Promise { seal in
            let url = Configuration.BASE_STORE_URL + SHOPPER_PROMOTION_RESOURCE_API_PATH + "/getPromoPaidHistoryDetail/v1?idPaidPromoDetail=\(id)"
            self.execute(.get, url: url)
                .done { json -> Void in
                    // JSON info
                    print("Finish request to get promotion paid history detail, json response: \(json)")
                    let jobj = SwiftyJSON.JSON(json)
                    if let result = PromotionPaidDTO(json: jobj) {
                        seal.fulfill(result)
                    } else {
                        seal.reject(ConnectionError.systemError)
                    }
                }
                .catch { error in
                    print("Error when request get promotion paid history detail: " + error.localizedDescription)
                    seal.reject(error)
                }
                .finally {
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
