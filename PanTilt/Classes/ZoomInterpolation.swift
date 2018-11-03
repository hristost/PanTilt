//
//  ZoomInterpolation.swift
//  PanTilt
//
//  Created by Hristo Staykov on 3.11.18.
//

import Foundation
import SwifterSwift

public extension CanvasZoom {
    public func interpolation(to end: CanvasZoom, ratio: CGFloat) -> CanvasZoom {
        var newZoom = self

        newZoom.scale += ratio * (end.scale - self.scale)
        newZoom.center += ratio * (end.center - self.center)
        newZoom.angle = newZoom.angle.truncatingRemainder(dividingBy: .pi * 2)
        // Interpolate angle
        // https://stackoverflow.com/a/14498790/1646862
        let shortestAngle = ((end.angle-self.angle) + .pi).truncatingRemainder(dividingBy: .pi * 2) - .pi
        newZoom.angle += shortestAngle * ratio

        return newZoom
    }
}
