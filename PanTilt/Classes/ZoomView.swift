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
    /// Set the current zoom level as indicated by the gesture recognizer
    func setZoom(_ zoom: ZoomTransform, animated: Bool)
}
