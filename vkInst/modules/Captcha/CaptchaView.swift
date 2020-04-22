//
//  CaptchaView.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/25/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol CaptchaViewProtocol {
    
}

class CaptchaView: UIView {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var captchaImageView: UIImageView!
    @IBOutlet weak var captchaTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var presenter: CaptchaPresenterProtocol?
    var originUrl: String?
    var error: VkApiRequestError?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        
    }
    
    func configureView(with error: RequestError, url: String) {
        guard let apiError = error.apiError else { return }
        originUrl = url
        self.error = apiError
    }
    
    @IBAction func doneButtonDidPressed(_ sender: UIButton) {
        
    }
}

extension CaptchaView: CaptchaViewProtocol {
    
}

private extension CaptchaView {
    
}
