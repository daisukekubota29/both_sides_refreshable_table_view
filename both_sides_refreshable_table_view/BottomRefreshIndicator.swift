//
//  BottomRefreshIndicator.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

private let size = CGFloat(28)

private let scaleAnimationDuration = CFTimeInterval(0.1)
private let scaleAnimationScale = CGFloat(1.2)
private let rotateAnimationDuration = CFTimeInterval(1.0)

private let defaultCircleColor = UIColor(white: 126 / 255, alpha: 1)

class BottomRefreshIndicator: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.backgroundColor = UIColor.clear
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: size, height: size))
        self.backgroundColor = UIColor.clear
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var color: UIColor = defaultCircleColor

    private var animating: Bool = false

    var isAnimating: Bool {
        return animating
    }

    func startAnimating() {
        if !animating {
            animating = true
            self.layer.removeAllAnimations()
            setNeedsDisplay()
        }

    }

    func stopAnimating() {
        if animating {
            animating = false
            stopAnimation()
        }
    }

    var percent: CGFloat = 0.0 {
        didSet {
            if percent != oldValue, !isAnimating {
                setNeedsDisplay()
            }
        }
    }
}

extension BottomRefreshIndicator {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if animating {
            animateLayer(rect: rect)
        } else {
            layer.sublayers = nil
            let circleLayer = CircleLayer(circleType: .percent(percent))
            circleLayer.color = color
            circleLayer.frame = self.layer.bounds
            layer.addSublayer(circleLayer)
            circleLayer.display()
        }
    }

    private func animateLayer(rect: CGRect) {
        let circleLayer = CircleLayer(circleType: .percent(1))
        circleLayer.frame = self.layer.bounds
        self.layer.addSublayer(circleLayer)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = scaleAnimationDuration
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = scaleAnimationScale
        scaleAnimation.isRemovedOnCompletion = true

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if self.animating {
                self.layer.sublayers = nil
                self.startRotateAnimation()
            }
        }
        circleLayer.add(scaleAnimation, forKey: "scale")
        CATransaction.commit()
    }

    private func startRotateAnimation() {
        let shapeLayer = CircleLayer(circleType: .rotate)
        shapeLayer.color = color
        shapeLayer.frame = self.layer.bounds
        self.layer.addSublayer(shapeLayer)
        shapeLayer.display()

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = rotateAnimationDuration
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = scaleAnimationDuration
        scaleAnimation.fromValue = scaleAnimationScale
        scaleAnimation.toValue = 1.0
        scaleAnimation.isRemovedOnCompletion = true

        shapeLayer.add(scaleAnimation, forKey: "scale")
        shapeLayer.add(animation, forKey: "rotate")
    }

    private func stopAnimation() {
        self.layer.sublayers = nil
        self.layer.removeAllAnimations()
    }

    private func position(center: CGPoint, radius: CGFloat, angle: Int) -> CGPoint {
        let angle = CGFloat(angle % 360)
        switch angle {
        case 0..<90:
            return CGPoint(x: center.x + sin(toRadius(angle: angle)) * radius,
                           y: center.y - cos(toRadius(angle: angle)) * radius)
        case 90..<180:
            return CGPoint(x: center.x + cos(toRadius(angle: angle - 90)) * radius,
                           y: center.y + sin(toRadius(angle: angle - 90)) * radius)
        case 180..<270:
            return CGPoint(x: center.x - sin(toRadius(angle: angle - 180)) * radius,
                           y: center.y + cos(toRadius(angle: angle - 180)) * radius)
        case 270..<360:
            return CGPoint(x: center.x - cos(toRadius(angle: angle - 270)) * radius,
                           y: center.y - sin(toRadius(angle: angle - 270)) * radius)
        default:
            fatalError()
        }
    }

    private func toRadius(angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
}


class CircleLayer: CALayer {
    private static let lineCount = 12
    private static let lineHeight = CGFloat(8)

    enum CircleType {
        case rotate
        case percent(CGFloat)
    }

    var color: UIColor = defaultCircleColor
    private var circleType: CircleType

    init(circleType: CircleType) {
        self.circleType = circleType
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        ctx.clear(self.bounds)
        super.draw(in: ctx)
        ctx.setLineWidth(2)
        ctx.setLineCap(.round)
        switch circleType {
        case .percent(let percent):
            drawPercentCirle(ctx: ctx, percent: percent)
        case .rotate:
            drawRotateCircle(ctx: ctx)
        }

    }

    private func drawPercentCirle(ctx: CGContext, percent: CGFloat) {
        let radius = size / 2
        let shortRadius = radius - CircleLayer.lineHeight
        let end = Int(CGFloat(CircleLayer.lineCount) * percent)
        ctx.setStrokeColor(color.cgColor)
        (0..<end).forEach {
            ctx.beginPath()
            ctx.move(to: position(center: center, radius: radius, angle: $0 * 30))
            ctx.addLine(to: position(center: center, radius: shortRadius, angle: $0 * 30))
            ctx.strokePath()
        }
    }

    private func drawRotateCircle(ctx: CGContext) {
        let lineCount = CircleLayer.lineCount
        let radius = size / 2
        let shortRadius = radius - CircleLayer.lineHeight
        (0..<lineCount).forEach {
            ctx.beginPath()
            ctx.setStrokeColor(color.withAlphaComponent(CGFloat(lineCount - $0) / CGFloat(lineCount) * 0.8 + 0.2).cgColor)
            ctx.move(to: position(center: center, radius: radius, angle: $0 * 30))
            ctx.addLine(to: position(center: center, radius: shortRadius, angle: $0 * 30))
            ctx.strokePath()
        }
    }

    private var center: CGPoint {
        let size = self.size
        return CGPoint(x: size / 2, y: size / 2)
    }

    private var size: CGFloat { self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height : self.bounds.size.width }

    private func position(center: CGPoint, radius: CGFloat, angle: Int) -> CGPoint {
        let angle = CGFloat(angle % 360)
        switch angle {
        case 0..<90:
            return CGPoint(x: center.x + sin(toRadius(angle: angle)) * radius,
                           y: center.y - cos(toRadius(angle: angle)) * radius)
        case 90..<180:
            return CGPoint(x: center.x + cos(toRadius(angle: angle - 90)) * radius,
                           y: center.y + sin(toRadius(angle: angle - 90)) * radius)
        case 180..<270:
            return CGPoint(x: center.x - sin(toRadius(angle: angle - 180)) * radius,
                           y: center.y + cos(toRadius(angle: angle - 180)) * radius)
        case 270..<360:
            return CGPoint(x: center.x - cos(toRadius(angle: angle - 270)) * radius,
                           y: center.y - sin(toRadius(angle: angle - 270)) * radius)
        default:
            fatalError()
        }
    }

    private func toRadius(angle: CGFloat) -> CGFloat {
        return angle * CGFloat.pi / 180
    }
}
