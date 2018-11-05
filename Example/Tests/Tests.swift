// https://github.com/Quick/Quick

import Quick
import Nimble
import PanTilt
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
        var zoom = ZoomTransform()
        zoom.scale = CGFloat(Float.random(in: 0.1...10))
        zoom.angle = CGFloat(Float.random(in: -10...10))
        zoom.center = CGPoint(x: CGFloat(Float.random(in: -100...1000)), y: CGFloat(Float.random(in: -100...1000)))
        return zoom
    }
}

class ZoomTest: QuickSpec {
    override func spec() {
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
            var zoom = ZoomTransform.random()
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
                expect(a.interpolation(to: b, ratio: 0).scale).to(equal(a.scale))
                expect(a.interpolation(to: b, ratio: 0).center).to(equal(a.center))
                expect(a.interpolation(to: b, ratio: 1).angle).to(equal(b.angle))
                expect(a.interpolation(to: b, ratio: 1).scale).to(equal(b.scale))
                expect(a.interpolation(to: b, ratio: 1).center).to(equal(b.center))
            }
            it("angle") {
                var a = ZoomTransform.random()
                a.angle = 0.1
                var b = ZoomTransform.random()
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
    }
}
