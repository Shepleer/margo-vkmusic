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
        guard let name = data.name,
            let text = data.text else { return }
        commentLabel.text = "\(name) \(text)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
