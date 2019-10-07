//
//  PhotoContainerView.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/26/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol DownloadMediaProtocol: class {
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion)
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion)
}

protocol PhotoContainerViewProtocol: class {
    func setMediaContent(mediaFile: Gif)
    func setMediaContent(mediaFile: Image)
}

class PhotoContainerView: UIView {
    private struct Constants {
        static let mediaApperanceAnimationDuration = 0.1
        static let mediaDefaultHeight = CGFloat(600)
        static let progressAnimationKey = "animateProgress"
    }
    
    @IBOutlet weak var progressView: ProgressIndicatorView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var imageWidthAnchor: NSLayoutConstraint!
    
    var url: String?
    weak var cell: DownloadMediaProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.photoView.image = image
                    self.progressView.layer.removeAnimation(forKey: Constants.progressAnimationKey)
                    UIView.animate(withDuration: Constants.mediaApperanceAnimationDuration, animations: {
                        self.photoView.alpha = 1
                    })
                    self.photoView.startAnimating()
                    self.progressView.isHidden = true
                }
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
            }) { [weak self] (gif, url) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.url == url {
                        self.photoView.image = gif
                        UIView.animate(withDuration: Constants.mediaApperanceAnimationDuration, animations: {
                            self.photoView.alpha = 1
                        })
                        self.photoView.startAnimating()
                    }
                }
            }
        }
    }
    
    func getMediaHeight() -> CGFloat {
        if let image = photoView.image {
            return image.size.height
        }
        return Constants.mediaDefaultHeight
    }
}

private extension PhotoContainerView {
    func downloadPhoto(withUrl url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        cell?.downloadPhoto(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(withUrl url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        cell?.downloadGif(url: url, progress: progress, completion: completion)
    }
}
