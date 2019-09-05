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

    var presenter: LogInPresenter?
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        ConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func LogInButtonPressed(_ sender: UIButton) {
        presenter?.LogIn()
    }
}

private extension LogInViewController {
    func ConfigureUI() {
        let primary = ThemeService.currentTheme().primaryColor
        let secondary = ThemeService.currentTheme().secondaryColor
        guard let view = view as? GradientBackgroundView else { return }
        view.setGradientBackground(firstColor: primary, secondColor: UIColor.white)
        logInButton.layer.cornerRadius = 14
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.black.cgColor
    }
}



