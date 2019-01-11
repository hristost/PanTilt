//
//  ViewController.swift
//  PanTilt
//
//  Created by hristost on 11/01/2018.
//  Copyright (c) 2018 hristost. All rights reserved.
//

import UIKit
import PanTilt
import SwifterSwift

class ViewController: UIViewController {

    var canvasView: CanvasView!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView = CanvasView(frame: self.view.frame)
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(canvasView)

        let zoomGesture = PanTiltGestureRecognizer(view: canvasView)
        zoomGesture.zoomSnap = CanvasViewZoomControl()
        zoomGesture.zoomSnap?.endZoom(gesture: zoomGesture, center: .zero)

        canvasView.addGestureRecognizer(zoomGesture)
        canvasView.isUserInteractionEnabled = true
        canvasView.zoomToFit(rotation: .rotate(0), animate: false)

        let displayLink = CADisplayLink(target: self, selector: #selector(refresh(_:)))
        displayLink.isPaused = false
        displayLink.add(to: .current, forMode: .default)
    }

    @objc func refresh(_ link: CADisplayLink) {
        canvasView.setNeedsDisplay()

    }

    @IBAction func zoomToFitTapped(_ sender: Any) {
        canvasView.zoomToFit(rotation: .maximizeArea, animate: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CanvasViewZoomControl: PanTiltGestureRecognizerZoomDelegate {
    /// Acceptable zoom scale range
    var zoomRange: ClosedRange<CGFloat> = 0...8
    func restrictZoom(gesture: PanTiltGestureRecognizer, center gestureCenter: CGPoint) -> Bool {
        let zoom = gesture.zoomableView.zoom
        var scale: CGFloat = 1
        let angle: CGFloat = 0
        if zoom.scale < self.zoomRange.lowerBound {
            scale = self.zoomRange.lowerBound / zoom.scale
        } else if zoom.scale > self.zoomRange.upperBound {
            scale = self.zoomRange.upperBound / zoom.scale
        } else {
            return false
        }

        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -gestureCenter.x, y: -gestureCenter.y))
        matrix = matrix.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        matrix = matrix.concatenating(CGAffineTransform(rotationAngle: angle))
        matrix = matrix.concatenating(CGAffineTransform(translationX: gestureCenter.x, y: gestureCenter.y))
        zoom.scale = scale * zoom.scale
        zoom.center = zoom.center.applying(matrix)
        gesture.zoomableView.setZoom(zoom, animated: false)
        return true
    }

    func snapZoom(gesture: PanTiltGestureRecognizer, center gestureCenter: CGPoint) -> Bool {
        return false
    }

    func endZoom(gesture: PanTiltGestureRecognizer, center: CGPoint) -> Bool {
        let view = gesture.zoomableView
        var zoom = ZoomTransform(copying: view.zoom)
        let scaled = snapScale(view: view, zoom: &zoom, gestureCenter: center)
        let rotated = snapRotation(view: view, zoom: &zoom, gestureCenter: center)
        let moved =  moveBounds(view: view, zoom: &zoom)
        if scaled || rotated || moved {
            view.setZoom(zoom, animated: true)
            return true
        } else  {
            return false
        }
    }
    internal func snapScale(view: UIView & ZoomableView, zoom: inout ZoomTransform, gestureCenter: CGPoint) -> Bool {
        var scale: CGFloat = 1
        let zoomSnap: [CGFloat] = [1.0, 2.0, 4.0]
        for t in zoomSnap {
            let e: CGFloat = 0.05
            if zoom.scale < t + e && zoom.scale > t - e {
                scale = t / zoom.scale
            }
        }
        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -gestureCenter.x, y: -gestureCenter.y))
        matrix = matrix.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        matrix = matrix.concatenating(CGAffineTransform(translationX: gestureCenter.x, y: gestureCenter.y))
        zoom.scale = scale * zoom.scale
        zoom.center = zoom.center.applying(matrix)
        return scale != 1
    }
    internal func snapRotation(view: UIView & ZoomableView, zoom: inout ZoomTransform, gestureCenter: CGPoint) -> Bool {
        var angle: CGFloat = 0
        let rotationSnap: [(angle: CGFloat, delta: CGFloat)] = [(0, 7), (90, 7), (180, 7), (270, 7)]
        for (target, delta) in rotationSnap {
            let maxAngle = (target + delta).degreesToRadians
            let minAngle = (target - delta).degreesToRadians
            if zoom.angle < maxAngle && zoom.angle > minAngle {
                angle = target.degreesToRadians - zoom.angle
            }
        }
        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -gestureCenter.x, y: -gestureCenter.y))
        matrix = matrix.concatenating(CGAffineTransform(rotationAngle: angle))
        matrix = matrix.concatenating(CGAffineTransform(translationX: gestureCenter.x, y: gestureCenter.y))
        zoom.center = zoom.center.applying(matrix)
        zoom.angle += angle
        return false
    }

    internal func moveBounds(view: UIView & ZoomableView, zoom: inout ZoomTransform) -> Bool {
        let (w, h) = (view.canvasSize.width, view.canvasSize.height)
        let rectangleCorners = [CGPoint(x: 0, y: 0), CGPoint(x: w, y: 0), CGPoint(x: 0, y: h), CGPoint(x: w, y: h)].map {
            $0.applying(zoom.canvasToView(bounds: view.bounds.size))
        }
        let xes = rectangleCorners.map { $0.x }
        let yes = rectangleCorners.map { $0.y }
        guard let minX = xes.min(), let maxX = xes.max(), let minY = yes.min(), let maxY = yes.max() else {
            return false
        }
        let canvasRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        let insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        } else {
            insets = view.layoutMargins
        }
        let displayRect = view.bounds.inset(by: insets)

        var newCanvasRect = canvasRect
        if newCanvasRect.width < displayRect.width && newCanvasRect.height < displayRect.height {
            newCanvasRect.size = canvasRect.size.aspectFit(to: displayRect.size)
        }
        if newCanvasRect.minX > displayRect.minX {
            newCanvasRect.origin.x = displayRect.minX
        } else if newCanvasRect.maxX < displayRect.maxX {
            newCanvasRect.origin.x = displayRect.maxX - newCanvasRect.size.width
        }
        if newCanvasRect.minY > displayRect.minY {
            newCanvasRect.origin.y = displayRect.minY
        } else if newCanvasRect.maxY < displayRect.maxY {
            newCanvasRect.origin.y = displayRect.maxY - newCanvasRect.size.height
        }
        if newCanvasRect.width <= displayRect.width {
            newCanvasRect.origin.x = (displayRect.size - newCanvasRect.size).width / 2 + displayRect.minX
        }
        if newCanvasRect.height <= displayRect.height {
            newCanvasRect.origin.y = (displayRect.size - newCanvasRect.size).height / 2 + displayRect.minY
        }
        // Modify zoom to match newCanvasRect
        let origin = CGPoint(x: canvasRect.minX, y: canvasRect.minY).applying(zoom.viewToCanvas(bounds: view.bounds.size))
        let dest = CGPoint(x: newCanvasRect.minX, y: newCanvasRect.minY).applying(zoom.viewToCanvas(bounds: view.bounds.size))
        let translation = dest - origin
        let scale = newCanvasRect.width / canvasRect.width
        var matrix = CGAffineTransform.identity
        matrix = matrix.concatenating(CGAffineTransform(translationX: -origin.x, y: -origin.y))
        matrix = matrix.concatenating(CGAffineTransform(translationX: -translation.x, y: -translation.y))
        matrix = matrix.concatenating(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        matrix = matrix.concatenating(CGAffineTransform(translationX: origin.x, y: origin.y))
        zoom.scale = zoom.scale * scale
        zoom.center = zoom.center.applying(matrix)
        return newCanvasRect != canvasRect
    }

}
