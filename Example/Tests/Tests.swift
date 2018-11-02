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

class ZoomTest: QuickSpec {
    override func spec() {
        describe("matrix") {
            it("identity") {
                // Any point on the canvas should remain the same after being converted to view coordinates and back
                // Any point on the view should remain the same after being converted to canvas coordinates and back
                var zoom = CanvasZoom()
                for _ in 1...100 {
                    zoom.scale = CGFloat(Float.random(in: 0.1...10))
                    zoom.angle = CGFloat(Float.random(in: -10...10))
                    zoom.center = CGPoint(x: CGFloat(Float.random(in: -100...1000)), y: CGFloat(Float.random(in: -100...1000)))

                    expect(zoom.canvasToView().concatenating(zoom.viewToCanvas())).to(beCloseTo(.identity))
                    expect(zoom.viewToCanvas().concatenating(zoom.canvasToView())).to(beCloseTo(.identity))
                }
            }
            it("scale") {
                var zoom = CanvasZoom()
                for _ in 1...100 {
                    zoom.scale = CGFloat(Float.random(in: 0.1...10))
                    zoom.angle = CGFloat(Float.random(in: -10...10))
                    zoom.center = CGPoint(x: CGFloat(Float.random(in: -100...1000)), y: CGFloat(Float.random(in: -100...1000)))
                    let a = CGPoint(x: 0, y: 100)
                    let b = CGPoint(x: 0, y: 200)
                    let d = (a.applying(zoom.viewToCanvas()) - b.applying(zoom.viewToCanvas()))
                    expect(d.length).to(beCloseTo((a-b).length / zoom.scale))
                }
            }
        }
    }
}
