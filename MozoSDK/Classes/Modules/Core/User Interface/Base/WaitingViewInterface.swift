//
//  MozoBasicViewInterface.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 11/29/18.
//

import Foundation
protocol WaitingViewInterface {
    func displayTryAgain(_ error: ConnectionError, forAction: WaitingRetryAction?)
}
