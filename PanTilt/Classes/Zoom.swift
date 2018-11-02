//
//  Zoom.swift
//  PanTilt
//
//  Created by Hristo Staykov on 1.11.18.
//

import SwifterSwift

/// Describes the position of the canvas in reference to the view it is in
public struct CanvasZoom {
    /// Which point of the canvas is in the center of the view
    public var center: CGPoint = .zero
    /// Zoom level: how many pixels on the view coresspond to a pixel in the canvas
    public var scale: CGFloat = 1
    /// The angle of the canvas in the containing view.
    /// * `0` means the canvas is not rotated
    /// * `π/2` means it's been rotated 90º clockwise
    /// * `π` means it's been rotated 180º
    public var angle: CGFloat = 0

    public init() {

    }

    /// The matrix which transforms points from canvas to view coordinates, where the center of the view is at `(0, 0)`
    public func canvasToView() -> CGAffineTransform {
        var t = CGAffineTransform.identity
        t = t.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        t = t.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        t = t.concatenating(CGAffineTransform(rotationAngle: angle))
        return t
    }
    /// The matrix which transforms points from canvas to view coordinates
    public func canvasToView(bounds: CGSize) -> CGAffineTransform {
        return canvasToView().concatenating(CGAffineTransform(translationX: bounds.width/2, y: bounds.height/2))
    }
    /// The matrix which transforms points from normalised view to canvas coordinates
    public func viewToCanvas() -> CGAffineTransform {
        var t = CGAffineTransform(rotationAngle: -angle)
        t = t.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        t = t.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        return t
    }
    /// The matrix which transforms points from view to canvas coordinates
    public func viewToCanvas(bounds: CGSize) -> CGAffineTransform {
        return CGAffineTransform(translationX: -bounds.width/2, y: -bounds.height/2).concatenating(self.viewToCanvas())
    }
}

public protocol ZoomableView where Self: UIView {
    /// The current zoom level of the view
    var zoom: CanvasZoom { get set }
    /// Acceptable zoom range
    var zoomRange: ClosedRange<CGFloat> { get set }
    /// The size of the canvas being zoomed
    var canvasSize: CGSize { get set }
}
