//
//  SettingsPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/21/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol SettingsPresenterProtocol {
    func exitFromAccount()
}

class SettingsPresenter {
    weak var vc: SettingsTableViewController?
    var router: SettingsRouterProtocol!
}

extension SettingsPresenter: SettingsPresenterProtocol {
    func exitFromAccount() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "lifetime")
        router.moveToLogInScreen()
    }
}
