//
//  CaptchaPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/25/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

protocol CaptchaPresenterProtocol {
    
}

enum MethodType {
    case likesSet
    case likesDelete
    case createComment
}

class CaptchaPresenter {
    private struct Constants {
        static let captchaUrlTemplate = "&captcha_sid=[captchaSid]&captcha_key=[key]"
    }
    
    var requestService: APIService?
    var view: CaptchaViewProtocol?
}

extension CaptchaPresenter: CaptchaPresenterProtocol {
    func sendRequestWithCaptchaCode(with originUrl: String, key: String, captchaSid: Int, requestType: MethodType) {
        var url = "\(originUrl)\(Constants.captchaUrlTemplate)"
            .replacingOccurrences(of: "[captchaSid]", with: "\(captchaSid)")
            .replacingOccurrences(of: "[key]", with: "\(key)")
        
    }
}
