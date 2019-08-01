//
//  ConformPresenter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol ConformPresenterProtocol {
    func parseUserCredentials(redirectString: String)
    func moveToMusicPlayerVC()
}

class ConformPresenter {
    var router: ConformRouterProtocol?
    weak var vc: ConformViewController?
}

extension ConformPresenter: ConformPresenterProtocol {
    func moveToMusicPlayerVC() {
        router?.moveToMainVC()
    }
    
    func parseUserCredentials(redirectString: String) {
        let token = redirectString.split(separator: "=").map(String.init)[1].split(separator: "&").map(String.init)[0]
        let tokenLifetime = redirectString.split(separator: "=").map(String.init)[2].split(separator: "&").map(String.init)[0]
        let userId = redirectString.split(separator: "=").map(String.init)[3].split(separator: "&").map(String.init)[0]
        let lifetime = NSTimeIntervalSince1970 + Double(tokenLifetime)!
        UserDefaults.standard.set(token, forKey: "accessToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(lifetime, forKey: "lifetime")
    }
}
