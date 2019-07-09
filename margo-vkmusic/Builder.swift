//
//  Builder.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit


class Builder {
    
    static let shared = Builder()
    private init(){}
    
    func BuildLogInScreen() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        let nav = UINavigationController(rootViewController: vc)
        let presenter = LogInPresenter()
        let router = LogInRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        router.vc = vc
        return nav
    }
    
    func BuildConformWebView() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebVC") as! ConformViewController
        let presenter = ConformPresenter()
        let router = ConformRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        return vc
    }
    
    func BuildAPIService() -> APIService {
        let manager = APIService()
        let builder = APIBuilder()
        let parser = APIParser()
        let runner = APIRunner()
        manager.builder = builder
        manager.parser = parser
        manager.runner = runner
        return manager
    }
    
    func createMusicPlayerVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesViewController
        let service = APIService()
        let requestBuilder = APIBuilder()
        let runner = APIRunner()
        let parser = APIParser()
        let presenter = ImagePresenter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.service = service
        service.builder = requestBuilder
        service.runner = runner
        service.parser = parser
        return vc
    }
    
    
}
