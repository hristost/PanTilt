//
//  ZoomInterpolation.swift
//  PanTilt
//
//  Created by Hristo Staykov on 3.11.18.
//

import Foundation
import SwifterSwift

public extension ZoomTransform {
    /// A zoom transform that is an interpolation between the current one and the given `target`
    /// - Parameters:
    ///   - target: the target zoom transform that is to be reached
    ///   - ratio: a value between `0.0` and `1.0` that defines whether the resulting transform is closer to the intial
    ///            (`0.0`) or the final target (`1.0`)
    public func interpolation(to target: ZoomTransform, ratio: CGFloat) -> ZoomTransform {
        // Interpolate transformation angle
        // Make sure both angles are in `[0, 2π)`
        let startAngle = self.angle.truncatingRemainder(dividingBy: .pi * 2)
        let endAngle = target.angle.truncatingRemainder(dividingBy: .pi * 2)
        // Find the shortest delta between the angles -- this is not necessarily their difference.
        // Example: If interpolating between `π/6` and `11/6π`, the middle value should be `2π` or `0`
        // https://stackoverflow.com/a/14498790/1646862
        let shortestAngle = ((endAngle-startAngle) + .pi).truncatingRemainder(dividingBy: .pi * 2) - .pi
        // Interpolate zoom scale and center (simple linear interpolation)
        var newZoom = self
        newZoom.scale += ratio * (target.scale - self.scale)
        newZoom.center += ratio * (target.center - self.center)
        newZoom.angle += shortestAngle * ratio
        return newZoom
    }
}
