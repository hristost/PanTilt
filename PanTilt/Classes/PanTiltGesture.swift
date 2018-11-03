//
//  PanTiltGesture.swift
//  PanTilt
//
//  Created by Hristo Staykov on 1.11.18.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass
import SwifterSwift

private extension CGPoint {
    var length: CGFloat {
        return self.distance(from: .zero)
    }
}
/// A two finger zoom and pan gesture recognizer to be attached to views that conform to `HSZoomableView`
public class ZoomPanGestureRecognizer: UIGestureRecognizer {
    /// The drawing view
    public var canvasView: UIView & ZoomableView
    public init(view: UIView & ZoomableView) {
        self.canvasView = view
        super.init(target: nil, action: nil)
    }
    /// The touches that triggered zoom
    var touchA, touchB: UITouch?
    /// The current zoom matrix at the time the gesture began
    var initialZoom: CanvasZoom = CanvasZoom()
    /// The location of the first touch at the time the gesture started, in canvas coordinates
    var initialTouchA: CGPoint = .zero
    /// The location of the second touch at the time the gesture started, in canvas coordinates
    var initialTouchB: CGPoint = .zero


    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Activate the gesture if we have collected two touches with a small radius
        for touch in touches where touch.majorRadius < 100 {
            if touchA == nil {
                touchA = touch
            } else if touchB == nil {
                touchB = touch
            }
        }
        if state == .possible, let a = touchA, let b = touchB {
            state = .began

            let A, B: CGPoint
            if #available(iOS 9.1, *) {
                A = a.preciseLocation(in: canvasView)
                B = b.preciseLocation(in: canvasView)
            } else {
                A = a.location(in: canvasView)
                B = b.location(in: canvasView)
            }

            self.initialZoom = canvasView.zoom
            initialTouchA = A.applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
            initialTouchB = B.applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {

        touches.forEach({
            if touchA == $0 {
                touchA = nil
            } else if touchB == $0 {
                touchB = nil
            }
        })
        if touchA == nil || touchB == nil {
            touchA = nil
            touchB = nil
            state = .ended
//            canvasView.setZoom(initialZoom, animated: true)
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        // We only care when the two touches for zooming were moved
        guard let a = touchA, let b = touchB else { return }
        let A, B: CGPoint
        if #available(iOS 9.1, *) {
            A = a.preciseLocation(in: canvasView).applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
            B = b.preciseLocation(in: canvasView).applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
        } else {
            A = a.location(in: canvasView).applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
            B = b.location(in: canvasView).applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
        }
        let v1 = A - B
        let v2 = initialTouchA - initialTouchB
        let angle = atan2(v2.y, v2.x) - atan2(v1.y, v1.x)
        let scale = v1.length / v2.length
        let initialTouchCenter = (initialTouchA + initialTouchB) * 0.5// - initialZoom.center
        let newTouchCenter = (A + B) * 0.5
        let translation = newTouchCenter - initialTouchCenter
        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -initialTouchCenter.x, y: -initialTouchCenter.y))
        matrix = matrix.concatenating(CGAffineTransform(translationX: -translation.x, y: -translation.y))
        matrix = matrix.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        matrix = matrix.concatenating(CGAffineTransform(rotationAngle: angle))
        matrix = matrix.concatenating(CGAffineTransform(translationX: initialTouchCenter.x, y: initialTouchCenter.y))

        var zoom = initialZoom

        zoom.scale = scale * initialZoom.scale
        zoom.center = zoom.center.applying(matrix)
        zoom.angle = zoom.angle - angle
        canvasView.setZoom(zoom, animated: false)
//        if canvasView.correctZoom(gestureCenter: initialTouchCenter) {
//            //            self.initialZoom = canvasView.zoom
//            //            initialTouchA = A.applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
//            //            initialTouchB = B.applying(initialZoom.viewToCanvas(bounds: canvasView.bounds.size))
//        }
//                canvasView.snapZoom(gestureCenter: initialTouchCenter)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.touchesEnded(touches, with: event)
    }

    override public func reset() {
        touchA = nil
        touchB = nil
    }
}
