//
//  ThemePresentation.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/5/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ThemePresentationView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gradientBackgroundView: GradientBackgroundView!
    @IBOutlet weak var modeNameLabel: UILabel!
    @IBOutlet weak var checkmarkBackgroundView: UIView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    var presentationTheme: Theme?
    var checkmark = UIImage(named: "Checkmark")?.withRenderingMode(.alwaysTemplate)
    let currentTheme = ThemeService.currentTheme()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureNib()
    }
    
    private func configureNib() {
        Bundle.main.loadNibNamed("ThemePresentationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
    }
    
    override func awakeFromNib() {
        checkmarkBackgroundView.layer.cornerRadius = checkmarkBackgroundView.frame.width / 2
        checkmarkBackgroundView.layer.borderWidth = 1
        checkmarkBackgroundView.layer.borderColor = ThemeService.currentTheme().secondaryColor.cgColor
        checkmarkBackgroundView.backgroundColor = ThemeService.currentTheme().backgroundColor
        checkmarkImage.isHidden = true
        checkmarkBackgroundView.backgroundColor = UIColor.white
        
        gradientBackgroundView.layer.cornerRadius = gradientBackgroundView.frame.width / 10
        gradientBackgroundView.clipsToBounds = true
    }
    
    func configureView(with theme: Theme) {
        presentationTheme = theme
        switch theme {
        case .Light:
            gradientBackgroundView.setGradientBackground(firstColor: Theme.Light.secondaryColor, secondColor: Theme.Light.backgroundColor)
            modeNameLabel.text = "Light"
        case .Dark:
            gradientBackgroundView.setGradientBackground(firstColor: Theme.Dark.secondaryColor, secondColor: Theme.Dark.backgroundColor)
            modeNameLabel.text = "Dark"
        case .Secret:
            let lightGold = UIColor(red: 235/255, green: 201/255, blue: 90/255, alpha: 1)
            let darkGold = UIColor(red: 92/255, green: 72/255, blue: 24/255, alpha: 1)
            gradientBackgroundView.setGradientBackground(firstColor: lightGold, secondColor: darkGold)
            modeNameLabel.text = "Secret"
        }
    }
    
    func setActive() {
        guard let theme = presentationTheme else { return }
        switch theme {
        case .Light:
            checkmarkBackgroundView.backgroundColor = UIColor.black
        case .Dark:
            checkmarkBackgroundView.backgroundColor = UIColor.white
        case .Secret:
            checkmarkBackgroundView.backgroundColor = UIColor.white
        }
    
        checkmarkImage.isHidden = false
        checkmarkImage.tintColor = currentTheme.backgroundColor
        checkmarkImage.image = checkmark
    }
    
    func disActive() {
        checkmarkImage.isHidden = true
        checkmarkBackgroundView.backgroundColor = UIColor.clear
    }
    
    func updatePresentation() {
        let currentTheme = ThemeService.currentTheme()
        modeNameLabel.textColor = currentTheme.primaryColor
        contentView.backgroundColor = currentTheme.backgroundColor
        checkmarkImage.tintColor = currentTheme.backgroundColor
        checkmarkImage.image = checkmark
    }
}
