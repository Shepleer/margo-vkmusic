//
//  progressIndicatorView.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/18/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

@IBDesignable class ProgressIndicatorView: UIView {
    private struct Constants {
        static let progressAnimationKeyPath = "strokeEnd"
        static let progressAnimationKey = "animateProgress"
        static let rotateAnimationKeyPath = "transform.rotation"
        static let rotateAnimationKey = "viewRotation"
        static let lineWidth = CGFloat(8)
        static let animationDuration = 0.2
        static let rotateAnimationDuration = 1.5
        static let rotateAnimationToValueMultiplier = Float(2.0)
        static let radiusMultiplier = CGFloat(1.5)
        static let startAngleMultiplier = CGFloat(-0.5)
        static let endAngleMultiplier = CGFloat(1.5)
    }
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = frame.width / 2
        self.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2,
                                                        y: rect.height / 2),
                                                        radius: (rect.width - Constants.radiusMultiplier) / 2,
                                                        startAngle: CGFloat(Constants.startAngleMultiplier * .pi),
                                                        endAngle: CGFloat(Constants.endAngleMultiplier * .pi),
                                                        clockwise: true)
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = Constants.lineWidth
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    private var nextValue: Float? = nil
    private var basic: Float = 0
    private var isAnimating = false
    func setProgressWithAnimation(value: Float) {
        if isAnimating == false {
            isAnimating = true
            rotate()
            let animation = createProgressAnimation()
            animation.fromValue = basic
            animation.toValue = value
            basic = value
            progressLayer.add(animation, forKey: Constants.progressAnimationKey)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.animationDuration) { [weak self] in
                guard let self = self else { return }
                self.isAnimating = false
                if value == 1.0 {
                    self.setDefaultProgress()
                }
                if let nextValue = self.nextValue {
                    let value = nextValue
                    self.nextValue = nil
                    self.setProgressWithAnimation(value: value)
                }
            }
        } else {
            nextValue = value
        }
    }
    
    func setDefaultProgress() {
        nextValue = nil
        basic = 0
        progressLayer.strokeEnd = 0.0
        self.isHidden = false
    }
    
    private func createProgressAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: Constants.progressAnimationKeyPath)
        animation.duration = Constants.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    func rotate() {
        if layer.animation(forKey: Constants.rotateAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: Constants.rotateAnimationKeyPath)
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * Constants.rotateAnimationToValueMultiplier
            rotationAnimation.duration = Constants.rotateAnimationDuration
            rotationAnimation.repeatCount = Float.infinity
            layer.add(rotationAnimation, forKey: Constants.rotateAnimationKey)
        }
    }
}
