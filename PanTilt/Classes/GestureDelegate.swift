//
//  GestureDelegate.swift
//  PanTilt
//
//  Created by Hristo Staykov on 3.11.18.
//

import Foundation

/// Extension of `UIGestureRecognizerDelegate` which allows the delegate to receive messages when the pan gesture
/// recognizer starts, updates, cancels, and finishes. The `delegate` property can be set to a class implementing
/// `PanTiltGestureRecognizerDelegate` and it will receive these messages.
@objc public protocol PanTiltGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    /// Called when the pan gesture recognizer starts, that is, zoom mode has been engaged
    @objc optional func panTiltGestureRecognizer(didStart gestureRecognizer: PanTiltGestureRecognizer)
    /// Called when the pan gesture recognizer updates
    @objc optional func panTiltGestureRecognizer(didUpdate gestureRecognizer: PanTiltGestureRecognizer)
    /// Called when the pan gesture recognizer cancels
    @objc optional func panTiltGestureRecognizer(didCancel gestureRecognizer: PanTiltGestureRecognizer)
    /// Called when the pan gesture recognizer ends
    @objc optional func panTiltGestureRecognizer(didEnd gestureRecognizer: PanTiltGestureRecognizer)
}

/// Methods used to restrict and fine-tune the zoom transformation as the user changing it
public protocol PanTiltGestureRecognizerZoomDelegate {
    /// Change the zoom transform if it does not fall into the accepted range for scale, center, etc.
    /// - Returns: true if the zoom transformation was changed, false if otherwise
    @discardableResult func restrictZoom(gesture: PanTiltGestureRecognizer, center gestureCenter: CGPoint) -> Bool

    /// Change the zoom transform so it snaps to a certain rotation, scale or position. Although the zoom displayed on
    /// screen may have changed, the gesture will continue operation as if it has not been changed
    /// - Returns: true if the zoom transformation was changed, false if otherwise
    @discardableResult func snapZoom(gesture: PanTiltGestureRecognizer, center gestureCenter: CGPoint) -> Bool

    /// Change the zoom transform after the gesture ends
    /// - Returns: true if the zoom transformation was changed, false if otherwise
    @discardableResult func endZoom(gesture: PanTiltGestureRecognizer, center gestureCenter: CGPoint) -> Bool
}
