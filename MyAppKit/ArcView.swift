//
//  ArcView.swift
//  MyAppKit
//
//  Created by Robert Ryan on 2/16/21.
//

import UIKit

@IBDesignable
public class ArcView: UIView {
    @IBInspectable
    public var lineWidth: CGFloat = 7 { didSet { updatePaths() } }

    @IBInspectable
    public var progress: CGFloat = 0 { didSet { updatePaths() } }

    private var arcCenter: CGPoint = .zero
    private var startAngle: CGFloat = 0
    private var endAngle: CGFloat = 0

    private lazy var currentPositionDotLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        let rect = CGRect(x: 0, y: 0, width: lineWidth * 3, height: lineWidth * 3)
        layer.frame = rect

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.type = .radial
        gradientLayer.frame = rect
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.5, 1]

        layer.mask = gradientLayer

        return layer
    }()

    private lazy var progressShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return shapeLayer
    }()

    private lazy var totalShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineCap = .round
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.9439327121, green: 0.5454334617, blue: 0.6426400542, alpha: 1)
        return shapeLayer
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        progress = 0.35
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateProgress(for: touches.first)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateProgress(for: touches.first)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateProgress(for: touches.first)
    }
}

// MARK: - Private utility methods

private extension ArcView {

    func updateProgress(for touch: UITouch?) {
        guard let touch = touch else { return }
        let point = touch.location(in: self)

        let angle = atan2(point.y - arcCenter.y, point.x - arcCenter.x) + 2 * .pi

        let percent = (angle - startAngle) / (endAngle - startAngle)

        progress = max(0, min(1, percent))
    }

    func configure() {
        layer.addSublayer(totalShapeLayer)
        layer.addSublayer(progressShapeLayer)
        layer.addSublayer(currentPositionDotLayer)
    }

    func updatePaths() {
        let rect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        let halfWidth = rect.width / 2
        let height = rect.height
        let theta = atan(halfWidth / height)
        let radius = sqrt(halfWidth * halfWidth + height * height) / 2 / cos(theta)
        arcCenter = CGPoint(x: rect.midX, y: rect.minY + radius)
        let delta = (.pi / 2 - theta) * 2
        startAngle = .pi * 3 / 2 - delta
        endAngle = .pi * 3 / 2 + delta

        let path = UIBezierPath(arcCenter: arcCenter,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        progressShapeLayer.path = path.cgPath // white arc
        totalShapeLayer.path = path.cgPath    // pink arc
        progressShapeLayer.strokeEnd = progress

        let currentAngle = (endAngle - startAngle) * progress + startAngle
        let dotCenter = CGPoint(x: arcCenter.x + radius * cos(currentAngle),
                                y: arcCenter.y + radius * sin(currentAngle))
        currentPositionDotLayer.position = dotCenter

        CATransaction.commit()
    }
}
