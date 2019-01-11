// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import PanTilt
import SwifterSwift

private extension CGPoint {
    var length: CGFloat {
        return self.distance(from: .zero)
    }
}
private func beCloseTo(_ expectedValue: CGAffineTransform, within delta: CGFloat = 0.01) -> Predicate<CGAffineTransform> {
    return Predicate.define { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
        return PredicateResult(
            bool: actualValue != nil &&
                abs(actualValue!.a - expectedValue.a) < delta &&
                abs(actualValue!.b - expectedValue.b) < delta &&
                abs(actualValue!.c - expectedValue.c) < delta &&
                abs(actualValue!.d - expectedValue.d) < delta &&
                abs(actualValue!.tx - expectedValue.tx) < delta &&
                abs(actualValue!.ty - expectedValue.ty) < delta,
            message: .expectedCustomValueTo(errorMessage, "<\(stringify(actualValue))>")
        )
    }
}
private extension ZoomTransform {
    static func random() -> ZoomTransform {
        let zoom = ZoomTransform()
        zoom.scale = CGFloat(Float.random(in: 0.1...10))
        zoom.angle = CGFloat(Float.random(in: -10...10))
        zoom.center = CGPoint(x: CGFloat(Float.random(in: -100...1000)), y: CGFloat(Float.random(in: -100...1000)))
        return zoom
    }
}

class ZoomTest: QuickSpec {
    override func spec() {
        it("copy") {
            let zoom = ZoomTransform.random()
            let copy: ZoomTransform = ZoomTransform(copying: zoom)
            expect(zoom.angle).to(equal(copy.angle))
            expect(zoom.scale).to(equal(copy.scale))
            expect(zoom.center).to(equal(copy.center))

        }
        context("matrix") {
            it("identity") {
                // Any point on the canvas should remain the same after being converted to view coordinates and back
                // Any point on the view should remain the same after being converted to canvas coordinates and back
                for _ in 1...100 {
                    let zoom = ZoomTransform.random()
                    let bounds = CGSize(width: CGFloat(Float.random(in: 0...1000)),
                                        height: CGFloat(Float.random(in: 0...1000)))
                    let a = zoom.canvasToView(bounds: bounds)
                    let b = zoom.viewToCanvas(bounds: bounds)
                    expect(a.concatenating(b)).to(beCloseTo(.identity))
                    expect(b.concatenating(a)).to(beCloseTo(.identity))
                }
            }
            it("scale") {
                for _ in 1...100 {
                    let zoom = ZoomTransform.random()
                    let a = CGPoint(x: 0, y: 100)
                    let b = CGPoint(x: 0, y: 200)
                    let d = (a.applying(zoom.viewToCanvas(bounds: .zero)) - b.applying(zoom.viewToCanvas(bounds: .zero)))
                    expect(d.length).to(beCloseTo((a-b).length / zoom.scale))
                }
            }
        }
        it("angle range") {
            let zoom = ZoomTransform.random()
            zoom.angle = CGFloat(-30).degreesToRadians
            expect(zoom.angle.radiansToDegrees).to(beCloseTo(330))
            zoom.angle = CGFloat(380).degreesToRadians
            expect(zoom.angle.radiansToDegrees).to(beCloseTo(20))

        }
        context("interpolation") {
            it("zero and one") {
                let a = ZoomTransform.random()
                let b = ZoomTransform.random()
                expect(a.interpolation(to: b, ratio: 0).angle).to(equal(a.angle))
                expect(a.interpolation(to: b, ratio: 1).angle).to(equal(b.angle))
                expect(a.interpolation(to: b, ratio: 0).scale).to(equal(a.scale))
                expect(a.interpolation(to: b, ratio: 1).scale).to(equal(b.scale))
                // The center of the interpolation depends on the scale, test it only when a and b have the same scale
                a.scale = b.scale
                expect(a.interpolation(to: b, ratio: 0).center).to(equal(a.center))
                expect(a.interpolation(to: b, ratio: 1).center).to(equal(b.center))
            }
            it("angle") {
                let a = ZoomTransform.random()
                a.angle = 0.1
                let b = ZoomTransform.random()
                b.angle = -0.1
                expect(a.interpolation(to: b, ratio: 0.5).angle).to(beCloseTo(0))
                b.angle = .pi * 2 - 0.1
                expect(a.interpolation(to: b, ratio: 0.5).angle).to(beCloseTo(0))
                b.angle = -0.1
                a.angle = 0.1
                expect(a.interpolation(to: b, ratio: 0.5).angle).to(beCloseTo(0))
                a.angle = 1
                b.angle = 2
                expect(a.interpolation(to: b, ratio: 0.5).angle).to(beCloseTo(1.5))
            }
        }


        it("zoom-to-fit") {
            let viewSize = CGSize(width: 1024, height: 768)
            let contentInset = UIEdgeInsets(top: 100, left: 90, bottom: 80, right: 70)
            let canvasSize = CGSize(width: CGFloat(Float.random(in: 100...1000)), height: CGFloat(Float.random(in: 100...1000)))
            let zoom = ZoomTransform.random()
            let fit = zoom.zoomToFit(canvasSize: canvasSize, viewSize: viewSize, contentInset: contentInset, rotation: .maximizeArea)

            // Make sure that the canvas does not go outside the safe area
            let (w, h) = (canvasSize.width, canvasSize.height)
            let rectangleCorners = [CGPoint(x: 0, y: 0), CGPoint(x: w, y: 0), CGPoint(x: 0, y: h), CGPoint(x: w, y: h)].map {
                $0.applying(fit.canvasToView(bounds: viewSize))
            }
            let canvasRect = CGRect(containingPoints: rectangleCorners)!
            let safeRect = CGRect(origin: .zero, size: viewSize).inset(by: contentInset)
            expect(safeRect.insetBy(dx: -0.5, dy: -0.5).contains(canvasRect)).to(equal(true))

            // Make sure that the canvas occupies as much as possible of the safe area, that is, the bounding rect of
            // the canvas matches either the width or height of the safe area
            expect(min(abs(safeRect.width-canvasRect.width), abs(safeRect.height-canvasRect.height))).to(beCloseTo(0))

        }
    }
}
