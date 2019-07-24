//
//  progressIndicatorView.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/18/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ProgressIndicatorView: UIView {
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = rect.width / 2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.width / 2, y: rect.height / 2), radius: (rect.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 3.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
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
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var basic: Float = 0
    var isAnimating = false
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
}
