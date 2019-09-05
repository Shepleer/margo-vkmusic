//
//  StyleManager.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit

enum AppColorScheme: String {
    case primary          = "Primary"
    case secondary        = "Secondary"
    case background       = "Background"
    
    var color: UIColor {
        switch self {
        case .primary: return ThemeService.currentTheme().primaryColor
        case .secondary: return ThemeService.currentTheme().secondaryColor
        case .background: return ThemeService.currentTheme().backgroundColor
        }
    }
}

enum Theme: Int {
    case Light
    case Dark
    case Secret
    
    var primaryColor: UIColor {
        switch self {
        case .Light: return LightPalette.black
        case .Dark: return DarkPallete.gray
        case .Secret: return LightPalette.red
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .Light: return LightPalette.black
        case .Dark: return DarkPallete.gray
        case .Secret: return LightPalette.red
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .Light: return LightPalette.white
        case .Dark: return DarkPallete.darkGray
        case .Secret: return LightPalette.white
        }
    }
}

fileprivate let selectedThemeKey = "SelectedTheme"

struct ThemeService {
    static func currentTheme() -> Theme {
        guard let storedTheme = Theme(rawValue: UserDefaults.standard.integer(forKey: selectedThemeKey)) else { return .Light }
        return storedTheme
    }
    
    static func applyTheme(theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: selectedThemeKey)
        UserDefaults.standard.synchronize()
    }
}

private struct LightPalette {
    static var black: UIColor { return UIColor.black }
    static var white: UIColor { return UIColor.white }
    static var gray: UIColor { return UIColor(red: 167, green: 167, blue: 169, alpha: 1) }
    static var red: UIColor { return UIColor(red: 235, green: 74, blue: 92, alpha: 1) }
    static var darkBlue: UIColor { return UIColor(red: 22, green: 140, blue: 200, alpha: 1) }
}

private struct DarkPallete {
    static var black: UIColor { return UIColor(red: 19, green: 19, blue: 22, alpha: 1) }
    static var lightBlack: UIColor { return UIColor(red: 24, green: 24, blue: 31, alpha: 1) }
    static var dark: UIColor { return UIColor(red: 45, green: 56, blue: 53, alpha: 1) }
    static var red: UIColor { return UIColor(red: 235, green: 74, blue: 92, alpha: 1) }
    static var white: UIColor { return UIColor.white }
    static var darkGray: UIColor { return UIColor(red: 222, green: 233, blue: 235, alpha: 1) }
    static var gray: UIColor { return UIColor(red: 167, green: 167, blue: 169, alpha: 1) }
}

private struct SecretPallete {
    
}
