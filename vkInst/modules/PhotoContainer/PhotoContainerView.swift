//
//  PhotoContainerView.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/26/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol DownloadMediaProtocol: class {
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
}

protocol PhotoContainerViewProtocol: class {
    func setMediaContent(mediaFile: Gif)
    func setMediaContent(mediaFile: Image)
}

class PhotoContainerView: UIView {
    
    @IBOutlet weak var progressView: ProgressIndicatorView!
    @IBOutlet weak var photoView: UIImageView!
    
    var url: String?
    weak var vc: DownloadMediaProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        configureView()
        progressView.rotate()
    }
}

extension PhotoContainerView: PhotoContainerViewProtocol {
    func setMediaContent(mediaFile: Image) {
        if let image = mediaFile.img {
            photoView.image = image
        } else {
            guard let url = mediaFile.url else { return }
            self.url = url
            downloadPhoto(withUrl: url, progress: { [weak self] (progress) in
                guard let self = self else { return }
                self.progressView.setProgressWithAnimation(value: progress)
            }) { [weak self] (image, url) in
                guard let self = self else { return }
                self.photoView.image = image
                self.progressView.layer.removeAnimation(forKey: "animateProgress")
                UIView.animate(withDuration: 0.1, animations: {
                    self.photoView.alpha = 1
                })
                self.photoView.startAnimating()
                self.progressView.isHidden = true
            }
        }
    }
    
    func setMediaContent(mediaFile: Gif) {
        if let gif = mediaFile.gif {
            photoView.image = gif
        } else {
            guard let url = mediaFile.url else { return }
            self.url = url
            downloadGif(withUrl: url, progress: { [weak self] (progress) in
                guard let self = self else { return }
                self.progressView.setProgressWithAnimation(value: progress)
            }) { [weak self] (image, url) in
                guard let self = self else { return }
                if self.url == url {
                    self.photoView.image = image
                    UIView.animate(withDuration: 0.1, animations: {
                        self.photoView.alpha = 1
                    })
                    self.photoView.startAnimating()
                }
            }
        }
    }
    
    func getMediaHeight() -> CGFloat {
        if let image = photoView.image {
            return image.size.height
        }
        return 400
    }
}

private extension PhotoContainerView {
    func configureView() {
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        photoView.image = UIImage(named: "placeholder")
    }
    
    func downloadPhoto(withUrl url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        vc?.downloadPhoto(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(withUrl url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        vc?.downloadGif(url: url, progress: progress, completion: completion)
    }
}
