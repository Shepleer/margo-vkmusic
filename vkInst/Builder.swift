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
    private init() {}
    
    func buildLogInScreen() -> UIViewController {
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
    
    func buildConformWebView() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebVC") as! ConformViewController
        let presenter = ConformPresenter()
        let router = ConformRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        return vc
    }
    
    func createGalleryVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagesVC") as! ImagesViewController
        let nav = UINavigationController(rootViewController: vc)
        let requestService = buildAPIService()
        let presenter = ImagePresenter()
        let router = ImagesRouter()
        let downloadService = buildDownloadService()
        let userService = UserService()
        let pageService = PageService()
        router.vc = vc
        userService.requestService = requestService
        pageService.requestService = requestService
        presenter.userService = userService
        presenter.pageService = pageService
        presenter.downloadService = downloadService
        presenter.service = requestService
        presenter.vc = vc
        vc.presenter = presenter
        vc.router = router
        presenter.router = router
        return nav
    }
    
    func buildDetailPhotoScreen(data: Image, profile: User) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailPhotoViewController
        let presenter = DetailPhotoPresenter()
        let router = DetailPhotoRouter()
        let requestService = buildAPIService()
        let pagingService = CommentsPageService()
        let userService = UserService()
        vc?.presenter = presenter
        vc?.imageData = data
        vc?.profile = profile
        presenter.vc = vc
        presenter.userService = userService
        presenter.pagingService = pagingService
        presenter.router = router
        pagingService.requestService = requestService
        userService.requestService = requestService
        return vc!
    }
    
    func buildAPIService() -> APIService {
        let manager = APIService()
        let builder = APIBuilder()
        let parser = APIParser()
        let runner = APIRunner()
        manager.builder = builder
        manager.parser = parser
        manager.runner = runner
        return manager
    }
    
    func buildDownloadService() -> DownloadService {
        let downloadService = DownloadService()
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache.shared
        configuration.requestCachePolicy = .useProtocolCachePolicy
        downloadService.session = URLSession(configuration: .default, delegate: downloadService, delegateQueue: nil)
        return downloadService
    }
}
