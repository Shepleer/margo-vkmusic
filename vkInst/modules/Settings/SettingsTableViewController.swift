//
//  SettingsTableViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/21/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var exitFromAccountCell: UITableViewCell!
    
    @IBOutlet weak var secretModePreviewView: ThemePresentationView!
    @IBOutlet weak var darkModePreviewView: ThemePresentationView!
    @IBOutlet weak var lightModePreviewView: ThemePresentationView!
    
    @IBOutlet weak var themeSelectionCell: UITableViewCell!
    @IBOutlet weak var emptyCell: UITableViewCell!
    
    var presenter: SettingsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUIRepresentation()
    }
    
    
    @IBAction func lightModeButtonTapped(_ sender: UIButton) {
        if ThemeService.currentTheme() != .Light {
            setActiveNewTheme(theme: Theme.Light)
        }
    }
    
    
    @IBAction func darkModeButtonTapped(_ sender: UIButton) {
        if ThemeService.currentTheme() != .Dark {
            setActiveNewTheme(theme: Theme.Dark)
        }
    }
    
    @IBAction func secretModeButtonTapped(_ sender: UIButton) {
        if ThemeService.currentTheme() != .Secret {
            setActiveNewTheme(theme: Theme.Secret)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 1) {
            confirmExit()
        }
    }
}

private extension SettingsTableViewController {
    func confirmExit() {
        let alert = UIAlertController(title: "Exit", message: "Are you sure want to sign out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Leave", style: .destructive) { (alert) in
            self.presenter?.exitFromAccount()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureUI() {
        navigationController?.isNavigationBarHidden = false
        secretModePreviewView.configureView(with: Theme.Secret)
        darkModePreviewView.configureView(with: Theme.Dark)
        lightModePreviewView.configureView(with: Theme.Light)
        tableView.tableFooterView = UIView()
        let currentTheme = ThemeService.currentTheme()
        updateThemePresentation(currentTheme: currentTheme)
    }
    
    
    func setActiveNewTheme(theme: Theme) {
        updateThemePresentation(currentTheme: theme)
        ThemeService.applyTheme(theme: theme)
        updateUIRepresentation()
    }
    
    func updateThemePresentation(currentTheme: Theme) {
        switch currentTheme {
        case .Light:
            lightModePreviewView.setActive()
            darkModePreviewView.disActive()
            secretModePreviewView.disActive()
        case .Dark:
            lightModePreviewView.disActive()
            darkModePreviewView.setActive()
            secretModePreviewView.disActive()
        case .Secret:
            lightModePreviewView.disActive()
            darkModePreviewView.disActive()
            secretModePreviewView.setActive()
        }
    }
    
    func updateUIRepresentation() {
        let currentTheme = ThemeService.currentTheme()
        navigationController?.navigationBar.barTintColor = currentTheme.secondaryBackgroundColor
        navigationController?.navigationBar.tintColor = currentTheme.primaryColor
        view.backgroundColor = currentTheme.backgroundColor
        themeSelectionCell.backgroundColor = currentTheme.backgroundColor
        emptyCell.backgroundColor = currentTheme.backgroundColor
        exitFromAccountCell.backgroundColor = currentTheme.backgroundColor
        lightModePreviewView.updatePresentation()
        darkModePreviewView.updatePresentation()
        secretModePreviewView.updatePresentation()
    }
}
