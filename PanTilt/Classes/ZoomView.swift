//
//  ZoomView.swift
//  PanTilt
//
//  Created by Hristo Staykov on 3.11.18.
//

@objc public protocol ZoomableView where Self: UIView {
    /// The current zoom level of the view. Do not set this directly, use `setZoom(_, animated:)` instead
    var zoom: ZoomTransform { get }
    /// The size of the canvas being zoomed
    var canvasSize: CGSize { get }
    /// Insets to determine the safe area to display content in
    var contentInset: UIEdgeInsets { get }
    /// Set the current zoom level as indicated by the gesture recognizer
    func setZoom(_ zoom: ZoomTransform, animated: Bool)

}

public extension ZoomableView {
    /// Scale and position the canvas so it is fully visible and fills as much of the view as possible
    /// - Parameters:
    ///     - rotation: Whether to rotate the canvas to maximize area
    ///     - animate: Whether to animate the change
    /// - Note: the `contentInset` property of the view will be used to determine the safe area for the canvas
    public func zoomToFit(rotation: ZoomTransform.FitRotation, animate: Bool) {
        let new = zoom.zoomToFit(canvasSize: canvasSize, viewSize: bounds.size, contentInset: contentInset, rotation: rotation)
        self.setZoom(new, animated: animate)
    }
}
