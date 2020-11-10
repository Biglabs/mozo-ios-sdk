//
//  TouchOverImageView.swift
//  Shopper
//
//  Created by Vu Nguyen on 8/30/20.
//  Copyright © 2020 Vu Nguyen. All rights reserved.
//

import Foundation
import UIKit

public class TouchOverImageView: UIImageView {
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -15, dy: -15).contains(point)
    }
}
