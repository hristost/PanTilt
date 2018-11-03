//
//  CanvasView.swift
//  PanTilt_Example
//
//  Created by Hristo Staykov on 1.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import PanTilt

enum ZoomAnimation {
    case none
    case progress(target: ZoomTransform, time: Float)
}
class CanvasView: UIView, ZoomableView {
    var canvasSize = CGSize(width: 400, height: 300)
    var zoom = ZoomTransform()
    var zoomRange: ClosedRange<CGFloat> = 0.5...8
    var zoomAnimation: ZoomAnimation = .none

    func setZoom(_ zoom: ZoomTransform, animated: Bool) {
        self.zoomAnimation = .none
        if animated {
            self.zoomAnimation = .progress(target: zoom, time: 100)
        } else {
            self.zoom = zoom
        }
    }
    override func draw(_ rect: CGRect) {
        let timeEllapsed: Float = 1000/60;
        switch zoomAnimation {
        case .none:
            ()
        case .progress(target: let target, time: let time):
            if timeEllapsed > time {
                zoomAnimation = .none
                zoom = target
            } else {
                zoom = zoom.interpolation(to: target, ratio: CGFloat(timeEllapsed / time))
                zoomAnimation = .progress(target: target, time: time - timeEllapsed)
            }
        }
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
