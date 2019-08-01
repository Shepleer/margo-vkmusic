//
//  LogInPresenter.swift
//  margo-telegram
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol LogInPresenterProtocol {
    func viewDidLoad()
    func LogIn()
}

class LogInPresenter {
    weak var vc: LogInViewController?
    var router: LogInRouter?
}

extension LogInPresenter: LogInPresenterProtocol {
    func viewDidLoad() {
        
    }
    
    func LogIn() {
        router?.presentWebView()
    }
}
