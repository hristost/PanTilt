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
    var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return self.layoutMargins
        }
    }
    var zoom = ZoomTransform()
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
            context.setFillColor(red: 0.05, green: 0.14, blue: 0.2, alpha: 1)
            context.fill(rect)
            let transform = zoom.canvasToView(bounds: self.bounds.size)
            let img = #imageLiteral(resourceName: "canvas")
            context.concatenate(transform)
            context.draw(img.cgImage!, in: CGRect(origin: .zero, size: canvasSize))
        }
    }

}
