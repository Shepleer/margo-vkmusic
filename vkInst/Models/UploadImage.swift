//
//  UploadImage.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/22/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import Photos


struct UploadImage {
    var id: Int?
    var asset: PHAsset
    var fileName: String
    var progress: Float = 0
    var isUploaded: Bool = false
    
    init(asset: PHAsset) {
        self.asset = asset
        self.fileName = UUID().uuidString
    }
}
