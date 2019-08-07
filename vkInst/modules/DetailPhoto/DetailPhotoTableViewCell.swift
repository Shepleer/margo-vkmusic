//
//  DetailPhotoTableViewCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/5/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class DetailPhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(data: Comment) {
        commentLabel.text = data.text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
