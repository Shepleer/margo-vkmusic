//
//  GradientBackgroudView.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit

class GradientBackgroundView: UIView {
    
    var gradientLayer: CAGradientLayer?
    var firstColor: CGColor?
    var secondColor: CGColor?
    var needReverse: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {

    }
    
    func setGradientBackground(firstColor: UIColor, secondColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        self.firstColor = firstColor.cgColor
        self.secondColor = secondColor.cgColor
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
        setGradientAnimation(toColors: [secondColor.cgColor, firstColor.cgColor])
        self.gradientLayer = gradientLayer
        needReverse = true
    }
    
    private func setGradientAnimation(toColors: [CGColor]) {
        let fromColors = self.gradientLayer?.colors
        self.gradientLayer?.colors = toColors
        guard let gradient = layer.sublayers?.first as? CAGradientLayer else { return }
        gradient.colors = toColors
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 10
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        layer.sublayers?.first?.add(animation, forKey: "animateGradient")
    }
}

extension GradientBackgroundView {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let secondColor = secondColor, let firstColor = firstColor else { return }
        if needReverse {
            setGradientAnimation(toColors: [firstColor, secondColor])
            needReverse = false
        } else {
            setGradientAnimation(toColors: [secondColor, firstColor])
            needReverse = true
        }
    }
}
