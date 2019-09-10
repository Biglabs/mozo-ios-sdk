//
//  CountryDisplayItem.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 1/5/19.
//  Copyright © 2019 Hoang Nguyen. All rights reserved.
//

import Foundation

public struct CountryDisplayItem {
    public let country: String
    public let countryCode: String
    public let isoCode: String
    public let urlImage: String
     
    public init(item: CountryCodeDTO) {
        country = item.country ?? ""
        countryCode = item.countryCode ?? ""
        isoCode = item.isoCode ?? ""
        urlImage = item.urlImage ?? ""
    }
}
