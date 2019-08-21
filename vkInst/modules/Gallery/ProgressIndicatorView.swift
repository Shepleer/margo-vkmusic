//
//  progressIndicatorView.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/18/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

@IBDesignable class ProgressIndicatorView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = rect.width / 2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2, y: rect.height / 2), radius: (rect.width - 1.5) / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 3.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    private var basic: Float = 0
    private var isAnimating = false
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        if isAnimating == false {
            isAnimating = true
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = basic
            animation.toValue = value
            basic = value
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            progressLayer.strokeEnd = CGFloat(value)
            progressLayer.add(animation, forKey: "animateprogress")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                self.isAnimating = false
            }
        }
    }
    
    func rotate() {
        if layer.animation(forKey: "viewRotation") == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = 1.5
            rotationAnimation.repeatCount = Float.infinity
            layer.add(rotationAnimation, forKey: "viewRotation")
        }
    }
}
