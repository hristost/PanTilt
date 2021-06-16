//
//  ZoomFit.swift
//  PanTilt
//
//  Created by Hristo Staykov on 11.01.19.
//

extension CGRect {
    /// The smallest rectangle containing all given points
    init(containingPoints points: [CGPoint]) {
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        if let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() {
            self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            self = .zero
        }
    }
}

public extension ZoomTransform {

    /// How to deal with rotation when we try to fit the canvas inside a view
    enum FitRotation {
        /// Keep the rotation as it is
        case keep
        /// Rotate to a specified angle
        case rotate(CGFloat)
        /// Rotate in such a way that the visible area is maximized. This rotates the canvas at a multiple of π/2
        case maximizeArea
    }

    /// Scale and position the canvas so it is fully visible and fills as much of the view as possible
    /// - Parameters:
    ///     - canvasSize: Size of the canvas
    ///     - viewSize: Size of the view
    ///     - contentInset: Edges of the view obscured by other views. The canvas won't occupy those areas
    ///     - rotation: Whether to rotate the canvas to maximize area
    func zoomToFit(canvasSize: CGSize, viewSize: CGSize, contentInset: UIEdgeInsets, rotation: FitRotation) -> ZoomTransform {
        let displayRect = CGRect(origin: .zero, size: viewSize).inset(by: contentInset)
        let result = ZoomTransform(copying: self)
        switch rotation {
        case .keep:
            ()
        case .rotate(let angle):
            result.angle = angle
        case .maximizeArea:
            // To display as much as possible, rotate to either 0º, 90º, 180º, or 270º
            // We keep the canvas at 0º or 180º if:
            //     1) the canvas is landscape and the view rect is landscape or
            //     2) the canvas is portrait and the view rect is portrait
            // TODO: Handle case of square canvas / view
            let horizontal = (displayRect.width - displayRect.height) * (canvasSize.width - canvasSize.height) > 0
            result.angle = horizontal ? (angle < .pi/2 || angle > 3 * .pi/2) ? 0 : .pi : (angle < .pi) ? .pi/2 : 3 * .pi/2
        }

        let (w, h) = (canvasSize.width, canvasSize.height)
        let rectangleCorners = [CGPoint(x: 0, y: 0), CGPoint(x: w, y: 0), CGPoint(x: 0, y: h), CGPoint(x: w, y: h)].map {
            $0.applying(result.canvasToView(bounds: viewSize))
        }

        let canvasRect = CGRect(containingPoints: rectangleCorners)

        return result.zoomToFit(rectangle: canvasRect, viewSize: viewSize, contentInset: contentInset)
    }
    /// Scale, rotate, and position the canvas so the given rectangle is fully visible and fills as much of
    /// the view as possible
    /// - Parameters:
    ///     - rectangle: Rectangle that should be shown
    ///     - rotation: Rotation of the rectangle relative to its origin
    ///     - viewSize: Size of the view
    ///     - contentInset: Edges of the view obscured by other views. The canvas won't occupy those areas
    func zoomToFit(rectangle rect: CGRect, withRotation rotation: CGFloat, viewSize: CGSize, contentInset: UIEdgeInsets) -> ZoomTransform {
        let rotationTransform = CGAffineTransform(rotationAngle: rotation)
        let points = [CGPoint(x: 0, y: 0),
                      CGPoint(x: rect.width, y: 0),
                      CGPoint(x: rect.width, y: rect.height),
                      CGPoint(x: 0, y: rect.height)].map {
                        $0.applying(rotationTransform) + rect.origin
                      }

        let result = ZoomTransform(copying: self)
        result.angle = rotation

        let rectangleCorners = points.map {
            $0.applying(result.canvasToView(bounds: viewSize))
        }

        let canvasRect = CGRect(containingPoints: rectangleCorners)

        return result.zoomToFit(rectangle: canvasRect, viewSize: viewSize, contentInset: contentInset)
    }

    /// Scale and position the canvas so the given rectangle is fully visible and fills as much of
    /// the view as possible
    /// - Parameters:
    ///     - rectangle: Rectangle that should be shown
    ///     - viewSize: Size of the view
    ///     - contentInset: Edges of the view obscured by other views. The canvas won't occupy those areas
    func zoomToFit(rectangle canvasRect: CGRect, viewSize: CGSize, contentInset: UIEdgeInsets) -> ZoomTransform {
        let result = ZoomTransform(copying: self)

        let displayRect = CGRect(origin: .zero, size: viewSize).inset(by: contentInset)
        var newCanvasRect = canvasRect
        newCanvasRect.size = canvasRect.size.aspectFit(to: displayRect.size)
        newCanvasRect.origin.x = (displayRect.size - newCanvasRect.size).width / 2 + displayRect.minX
        newCanvasRect.origin.y = (displayRect.size - newCanvasRect.size).height / 2 + displayRect.minY
        // Modify zoom to match newCanvasRect
        let origin = CGPoint(x: canvasRect.minX, y: canvasRect.minY).applying(result.viewToCanvas(bounds: viewSize))
        let dest = CGPoint(x: newCanvasRect.minX, y: newCanvasRect.minY).applying(result.viewToCanvas(bounds: viewSize))
        let translation = dest - origin
        let scale = newCanvasRect.width / canvasRect.width
        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -origin.x, y: -origin.y))
        matrix = matrix.concatenating(CGAffineTransform(translationX: -translation.x, y: -translation.y))
        matrix = matrix.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        matrix = matrix.concatenating(CGAffineTransform(translationX: origin.x, y: origin.y))
        result.scale = result.scale * scale
        result.center = result.center.applying(matrix)
        return result
    }


}

