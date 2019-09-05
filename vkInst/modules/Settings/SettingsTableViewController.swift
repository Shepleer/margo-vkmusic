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
    
    var presenter: SettingsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
    }
}
