//
//  Geometry.swift
//  PanTilt
//
//  Created by Hristo on 16/06/2021.
//

import Foundation

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}


func +(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func -(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func *(x: CGPoint, c: CGFloat) -> CGPoint {
    return CGPoint(x: x.x * c, y: x.y * c)
}

func *(c: CGFloat, x: CGPoint) -> CGPoint {
    return CGPoint(x: x.x * c, y: x.y * c)
}


extension CGPoint {
    var length: CGFloat {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { self / 180 * .pi }
    var radiansToDegrees: CGFloat { self / .pi * 180 }
}

extension CGSize {
    func aspectFit(to bounds: CGSize) -> CGSize {
        let scale = min(bounds.width / width, bounds.height / height)
        return CGSize(width: width * scale, height: height * scale)
    }
}
