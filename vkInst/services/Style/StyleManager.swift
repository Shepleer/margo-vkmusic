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
        case .Dark: return DarkPallete.white
        case .Secret: return SecretPallete.violet
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .Light: return LightPalette.gray
        case .Dark: return DarkPallete.gray
        case .Secret: return SecretPallete.violetLight
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .Light: return LightPalette.white
        case .Dark: return DarkPallete.lightBlack
        case .Secret: return SecretPallete.purpleDark
        }
    }
    
    var secondaryBackgroundColor: UIColor {
        switch self {
        case .Light: return LightPalette.lightGray
        case .Dark: return DarkPallete.black
        case .Secret: return SecretPallete.purpleDark
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
        
        let primary = theme.primaryColor
        let secondaryBackground = theme.secondaryBackgroundColor
        
        UINavigationBar.appearance().barTintColor = secondaryBackground
        UINavigationBar.appearance().tintColor    = primary
        
        UIToolbar.appearance().tintColor          = primary
        UIToolbar.appearance().backgroundColor    = secondaryBackground
    }
}

private struct LightPalette {
    static var black: UIColor { return UIColor.black }
    static var white: UIColor { return UIColor.white }
    static var gray: UIColor { return UIColor.darkGray }
    static var red: UIColor { return UIColor(red: 235/255, green: 74/255, blue: 92/255, alpha: 1) }
    static var darkBlue: UIColor { return UIColor(red: 22/255, green: 140/255, blue: 200/255, alpha: 1) }
    static var lightGray: UIColor { return UIColor.lightGray }
}

private struct DarkPallete {
    static var black: UIColor { return UIColor(red: 19/255, green: 19/255, blue: 22/255, alpha: 1) }
    static var lightBlack: UIColor { return UIColor(red: 24/255, green: 24/255, blue: 31/255, alpha: 1) }
    static var dark: UIColor { return UIColor(red: 45/255, green: 56/255, blue: 53/255, alpha: 1) }
    static var red: UIColor { return UIColor(red: 235/255, green: 74/255, blue: 92/255, alpha: 1) }
    static var white: UIColor { return UIColor.white }
    //static var darkGray: UIColor { return UIColor(red: 222/255, green: 233/255, blue: 235/255, alpha: 1) }
    static var gray: UIColor { return UIColor(red: 167/255, green: 167/255, blue: 169/255, alpha: 1) }
}

private struct SecretPallete {
    static var purpleDark: UIColor { return UIColor(red: 69/255, green: 28/255, blue: 119/255, alpha: 1) }
    static var purpleLight: UIColor { return UIColor(red: 146/255, green: 33/255, blue: 241/255, alpha: 1 ) }
    static var violetLight: UIColor { return UIColor(red: 245/255, green: 117/255, blue: 241/255, alpha: 1) }
    static var violet: UIColor { return UIColor(red: 175/255, green: 36/255, blue: 121/255, alpha: 1) }
}
