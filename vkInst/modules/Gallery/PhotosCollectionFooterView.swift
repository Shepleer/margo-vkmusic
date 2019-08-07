//
//  PhotosCollectionFooterView.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/6/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class PhotosCollectionFooterView: UICollectionReusableView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func allDownloaded() {
        activityIndicator.stopAnimating()
    }
}
