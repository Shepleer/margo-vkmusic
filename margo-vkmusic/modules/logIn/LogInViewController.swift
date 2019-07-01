//
//  ViewController.swift
//  margo-telegram
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol LogInViewControllerProtocol {
    
}


class LogInViewController: UIViewController, LogInViewControllerProtocol {

    var presenter: LogInPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
}

