//
//  ViewController.swift
//  margo-telegram
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import WebKit

protocol LogInViewControllerProtocol {
    
}


class LogInViewController: UIViewController {

    var presenter: LogInPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        ConfigureUI()
    }
    @IBAction func LogInButton(_ sender: UIButton) {
        presenter?.LogIn()
        
    }
}

private extension LogInViewController {
    func ConfigureUI() {
        self.view.setGradientBackground(firstColor: UIColor.darkGray, secondColor: UIColor.lightGray)
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension LogInViewController: LogInViewControllerProtocol {
    
}


