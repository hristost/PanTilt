//
//  Zoom.swift
//  PanTilt
//
//  Created by Hristo Staykov on 1.11.18.
//

/// Describes the position of the canvas in reference to the view it is in
@objc public class ZoomTransform: NSObject {
    /// Which point of the canvas is in the center of the view
    @objc public var center: CGPoint = .zero
    /// Zoom level: how many pixels on the view corespond to a pixel in the canvas
    @objc public var scale: CGFloat = 1
    /// The angle of the canvas in the containing view.
    /// * `0` means the canvas is not rotated
    /// * `π/2` means it's been rotated 90º clockwise
    /// * `π` means it's been rotated 180º
    /// - Invariant: `0 <= angle < 2π`
    @objc public var angle: CGFloat = 0 {
        didSet {
            // Whenever the angle is set, make sure it lies between 0 and 2π
            var remainder = angle.remainder(dividingBy: 2 * .pi)
            while remainder < 0 {
                remainder += 2 * .pi
            }
            angle = remainder
        }
    }

    override public init() {

    }

    /// A new zoom transformation
    /// - Parameters:
    ///     - center: which point of the canvas is in the center of the view, in canvas coordinates
    ///     - scale: how many pixels on the view corespond to a pixel in the canvas
    ///     - angle: the angle of the canvas in the containing view
    public init(center: CGPoint, scale: CGFloat, angle: CGFloat) {
        self.center = center
        self.scale = scale
        self.angle = angle
    }

    /// A copy of an existing zoom transformation
    /// - Parameters:
    ///     - zoom: the transformation to copy
    public convenience init(copying zoom: ZoomTransform) {
        self.init(center: zoom.center, scale: zoom.scale, angle: zoom.angle)
    }


    /// The matrix which transforms points from canvas to view coordinates
    /// - Parameters:
    ///     - bounds: the bounds of the view
    @objc public func canvasToView(bounds: CGSize) -> CGAffineTransform {
        var t = CGAffineTransform.identity
        t = t.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
        t = t.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        t = t.concatenating(CGAffineTransform(rotationAngle: angle))
        return t.concatenating(CGAffineTransform(translationX: bounds.width/2, y: bounds.height/2))
    }
    
    /// The matrix which transforms points from view to canvas coordinates
    /// - Parameters:
    ///     - bounds: the bounds of the view
    @objc public func viewToCanvas(bounds: CGSize) -> CGAffineTransform {
        var t = CGAffineTransform(rotationAngle: -angle)
        t = t.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        t = t.concatenating(CGAffineTransform(translationX: center.x, y: center.y))
        return CGAffineTransform(translationX: -bounds.width/2, y: -bounds.height/2).concatenating(t)
    }
}
