//
//  Downloads.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/17/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

class Download {
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    var task: URLSessionDownloadTask?
    var data: Data?
    var isDownloading = false
    var progress: Float = 0.0
    
}
