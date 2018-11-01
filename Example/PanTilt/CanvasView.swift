//
//  CanvasView.swift
//  PanTilt_Example
//
//  Created by Hristo Staykov on 1.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import PanTilt

class CanvasView: UIView, ZoomableView {
    var canvasSize = CGSize(width: 400, height: 300)
    var zoom = CanvasZoom()
    var zoomRange: ClosedRange<CGFloat> = 0.5...8

    override func draw(_ rect: CGRect) {
        // Drawing code
        if let context = UIGraphicsGetCurrentContext() {
            let centerTransformation = CGAffineTransform(translationX: self.frame.width/2, y: self.frame.height/2)
            context.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
            context.fill(rect)
            let transform = zoom.canvasToView().concatenating(centerTransformation)
            let img = #imageLiteral(resourceName: "canvas")
            context.concatenate(transform)
            context.draw(img.cgImage!, in: CGRect(origin: .zero, size: canvasSize))
        }
    }

}
