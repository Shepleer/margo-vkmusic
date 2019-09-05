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
    
    func buildLogInScreen() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "LogInVC") as? LogInViewController else { return nil }
        let nav = UINavigationController(rootViewController: vc)
        let presenter = LogInPresenter()
        let router = LogInRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        router.vc = vc
        return nav
    }
    
    func buildConformWebView() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "WebVC") as? ConformViewController else { return nil }
        let presenter = ConformPresenter()
        let router = ConformRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        return vc
    }
    
    func createGalleryVC() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ImagesVC") as? ImagesViewController else { return nil }
        let nav = UINavigationController(rootViewController: vc)
        let presenter = ImagePresenter()
        let router = ImagesRouter()
        let downloadService = buildDownloadService()
        let userService = UserService(requestService: buildAPIService())
        let pageService = PageService(requestService: buildAPIService())
        router.vc = vc
        presenter.userService = userService
        presenter.pageService = pageService
        presenter.downloadService = downloadService
        presenter.service = buildAPIService()
        presenter.vc = vc
        vc.presenter = presenter
        presenter.router = router
        return nav
    }
    
    func buildDetailPhotoScreen(data: Post, profile: User) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailPhotoViewController else { return nil }
        vc.configureController(postData: data, profile: profile)
        let presenter = DetailPhotoPresenter()
        let router = DetailPhotoRouter()
        let pagingService = CommentsPageService(requestService: buildAPIService())
        let userService = UserService(requestService: buildAPIService())
        vc.presenter = presenter
        presenter.vc = vc
        presenter.userService = userService
        presenter.pagingService = pagingService
        presenter.downloadService = buildDownloadService()
        presenter.router = router
        return vc
    }
    
    func buildUploadPostScreen() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "uploadPostVC") as? UploadPostViewController else { return nil }
        let presenter = UploadPostPresenter()
        let uploadService = buildUploadService()
        let router = UploadPostRouter()
        let userService = UserService(requestService: buildAPIService())
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        presenter.uploadService = uploadService
        presenter.userService = userService
        router.vc = vc
        return vc
    }
    
    func buildExternalGalleryViewController() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "externalGalleryVC") as? ExternalPickerCollectionViewController else { return nil }
        let presenter = ExternalPickerPresenter()
        let router = ExternalPickerRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        router.vc = vc
        return vc
    }
    
    func buildSettingsScreen() -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "settingsVC") as? SettingsTableViewController else { return nil }
        let presenter = SettingsPresenter()
        let router = SettingsRouter()
        vc.presenter = presenter
        presenter.vc = vc
        presenter.router = router
        router.vc = vc
        return vc
    }
    
    func buildAPIService() -> APIService {
        let builder = APIBuilder()
        let parser = APIParser()
        let runner = APIRunner()
        let manager = APIService(builder: builder,
                                 runner: runner,
                                 parser: parser)
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
    
    func buildUploadService() -> UploadService {
        let requestService = buildAPIService()
        let uploadService = UploadService(requestService: requestService)
        let configuration = URLSessionConfiguration.background(withIdentifier: "uploadPhotos")
        let session = URLSession(configuration: configuration, delegate: uploadService, delegateQueue: nil)
        uploadService.session = session
        return uploadService
    }
}
