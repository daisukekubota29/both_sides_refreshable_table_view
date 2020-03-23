//
//  BottomRefreshIndicator.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

private let size = CGFloat(28)

class BottomRefreshIndicator: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
//        backgroundColor = UIColor.blue
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: size, height: size))
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var color: UIColor = UIColor.gray

    var hidesWhenStopped: Bool = true

    private var animating: Bool = false

    var isAnimating: Bool {
        return animating
    }

    func startAnimating() {
        if hidesWhenStopped {
            isHidden = false
        }
        animating = true
    }

    func stopAnimating() {
        if hidesWhenStopped {
            isHidden = true
        }
        animating = false
    }

    var percent: CGFloat = 0.0 {
        didSet {
            debugPrint("percent: \(percent)")
            if percent != oldValue, !isAnimating {
                setNeedsDisplay()
            }
        }
    }
}

extension BottomRefreshIndicator {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(rect)
        }
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = size / 2
        let shortRadius = radius - 8
        let end = Int(12 * percent)
        debugPrint(end)
        (0..<end).forEach {
            let path = UIBezierPath()
            path.lineWidth = 2
            let angle = $0 * 30
            color.setStroke()
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            debugPrint(position(center: center, radius: radius, angle: angle))
            path.move(to: position(center: center, radius: radius, angle: angle))
            path.addLine(to: position(center: center, radius: shortRadius, angle: angle))
            path.stroke()
        }
//        path.move(to: CGPoint(x: bounds.size.width / 2 - 1, y: 0))
//        path.addLine(to: CGPoint(x: bounds.size.width / 2 - 1, y: 8))
//        color.setStroke()
//        path.stroke()
//        debugPrint("position: \(position(center: center, radius: 14, angle: 30))")
//        debugPrint("position2: \(position(center: center, radius: 0, angle: 30))")
//        debugPrint("frame: \(self.frame)")
//        path.move(to: position(center: center, radius: self.bounds.size.width / 2, angle: 30))
//        path.addLine(to: position(center: center, radius: 6, angle: 30))
//        path.stroke()
//
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
//        path.stroke()
    }

    private func position(center: CGPoint, radius: CGFloat, angle: Int) -> CGPoint {
        let angle = CGFloat(angle % 360)
        debugPrint("angle: \(angle)")
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
