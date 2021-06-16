//
//  Geometry.swift
//  PanTilt_Example
//
//  Created by Hristo on 16/06/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CoreGraphics


extension CGPoint {
    var length: CGFloat {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
}
