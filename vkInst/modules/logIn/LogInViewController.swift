//
//  ViewController.swift
//  margo-telegram
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import WebKit

class LogInViewController: UIViewController {

    
    @IBOutlet var contentGradientView: GradientBackgroundView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    
    var presenter: LogInPresenter?
    let currentTheme = ThemeService.currentTheme()
    let aperture = UIImage(named: "Aperture")?.withRenderingMode(.alwaysTemplate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConfigureUI()
    }
    
    @IBAction func LogInButtonPressed(_ sender: UIButton) {
        presenter?.LogIn()
    }
}

private extension LogInViewController {
    func ConfigureUI() {
        self.navigationController?.navigationBar.isHidden = true
        let primary = currentTheme.primaryColor
        let secondary = currentTheme.secondaryColor
        let backgroud = currentTheme.backgroundColor
        contentGradientView.setGradientBackground(firstColor: secondary, secondColor: backgroud)
        appNameLabel.textColor = primary
        logInButton.layer.cornerRadius = 14
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = primary.cgColor
        logInButton.setTitleColor(primary, for: .normal)
        iconImageView.tintColor = currentTheme.primaryColor
        iconImageView.image = aperture
    }
}



